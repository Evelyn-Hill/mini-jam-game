package main
/* 
	Unity Main for Hot Reload/Desktop Release.
*/

import "core:c/libc"
import "core:dynlib"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:os"
import "core:os/os2"
import "core:path/filepath"

import game ".."

when ODIN_OS == .Windows {
	LIB_SUFFIX :: ".dll"
} else when ODIN_OS == .Linux {
	LIB_SUFFIX :: ".so"
} else {
	#panic("Not a supported platform! The supported platforms are WINDOWS and LINUX")
}

LIB_DIR :: "build/hot_reload/"
GAME_LIB_PATH :: LIB_DIR + "game" + LIB_SUFFIX

USE_TRACKING_ALLOCATOR :: #config(USE_TRACKING_ALLOCATOR, false)

Game_API :: struct {
	lib:               dynlib.Library,
	init_window:       proc(),
	init:              proc(),
	update:            proc(),
	should_run:        proc() -> bool,
	shutdown:          proc(),
	shutdown_window:   proc(),
	memory:            proc() -> rawptr,
	memory_size:       proc() -> int,
	hot_reloaded:      proc(mem: rawptr),
	force_reload:      proc() -> bool,
	force_restart:     proc() -> bool,
	modification_time: os.File_Time,
	api_version:       int,
}

main :: proc() {
	when ODIN_DEBUG {
		debug_init()
	} else {
		release_init()
	}
}

load_game_api :: proc(api_version: int) -> (api: Game_API, ok: bool) {
	mod_time, mod_time_error := os.last_write_time_by_name(GAME_LIB_PATH)
	if mod_time_error != os.ERROR_NONE {
		fmt.printfln(
			"Failed getting last write time of " + GAME_LIB_PATH + ", error code: {1}",
			mod_time_error,
		)
		return
	}

	game_dll_name := fmt.tprintf(LIB_DIR + "game_{0}" + LIB_SUFFIX, api_version)
	copy_dll(game_dll_name) or_return

	// This proc matches the names of the fields in Game_API to symbols in the
	// game DLL. It actually looks for symbols starting with `game_`, which is
	// why the argument `"game_"` is there.
	_, ok = dynlib.initialize_symbols(&api, game_dll_name, "game_", "lib")
	assert(ok, "Failed to init new symbols!")

	api.api_version = api_version
	api.modification_time = mod_time
	ok = true

	return
}

unload_game_api :: proc(api: ^Game_API) {
	if api.lib != nil {
		if !dynlib.unload_library(api.lib) {
			fmt.printfln("Failed unloading lib: {0}", dynlib.last_error())
		}
	}

	if os.remove(fmt.tprintf(LIB_DIR + "game_{0}" + LIB_SUFFIX, api.api_version)) != nil {
		fmt.printfln(
			"Failed to remove {0}game_{1}" + LIB_SUFFIX + " copy",
			LIB_DIR,
			api.api_version,
		)
	}
}

copy_dll :: proc(to: string) -> bool {
	copy_err := os2.copy_file(to, GAME_LIB_PATH)

	if copy_err != nil {
		fmt.printfln("Failed to copy " + GAME_LIB_PATH + " to {0}: %v", to, copy_err)
		return false
	}

	return true
}


debug_init :: proc() {
	// Set working dir to dir of executable.
	exe_path := os.args[0]
	exe_dir := filepath.dir(string(exe_path), context.temp_allocator)
	os.set_current_directory(exe_dir)

	context.logger = log.create_console_logger()

	default_allocator := context.allocator
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, default_allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)

	reset_tracking_allocator :: proc(a: ^mem.Tracking_Allocator) -> bool {
		err := false

		for _, value in a.allocation_map {
			log.errorf("%v: Leaked %v bytes\n", value.location, value.size)
			err = true
		}

		mem.tracking_allocator_clear(a)
		return err
	}

	game_api_version := 0
	game_api, game_api_ok := load_game_api(game_api_version)

	if !game_api_ok {
		fmt.println("Failed to load Game API")
		return
	}

	game_api_version += 1
	game_api.init_window()
	game_api.init()

	old_game_apis := make([dynamic]Game_API, default_allocator)

	for game_api.should_run() {
		game_api.update()
		force_reload := game_api.force_reload()
		force_restart := game_api.force_restart()
		reload := force_reload || force_restart
		game_dll_mod, game_dll_mod_err := os.last_write_time_by_name(GAME_LIB_PATH)

		if game_dll_mod_err == os.ERROR_NONE && game_api.modification_time != game_dll_mod {
			reload = true
		}

		if reload {
			new_game_api, new_game_api_ok := load_game_api(game_api_version)

			assert(new_game_api_ok, "Could not load new game API!")

			force_restart = force_restart || game_api.memory_size() != new_game_api.memory_size()

			if force_restart {
				// This does a full reset. That's basically like opening and
				// closing the game, without having to restart the executable.
				//
				// You end up in here if the game requests a full reset OR
				// if the size of the game memory has changed. That would
				// probably lead to a crash anyways.

				game_api.shutdown()
				reset_tracking_allocator(&tracking_allocator)

				for &g in old_game_apis {
					unload_game_api(&g)
				}

				clear(&old_game_apis)
				unload_game_api(&game_api)
				game_api = new_game_api
				game_api.init()
			} else {
				// This does the normal hot reload

				// Note that we don't unload the old game APIs because that
				// would unload the DLL. The DLL can contain stored info
				// such as string literals. The old DLLs are only unloaded
				// on a full reset or on shutdown.
				append(&old_game_apis, game_api)
				game_memory := game_api.memory()
				game_api = new_game_api
				game_api.hot_reloaded(game_memory)
			}

			game_api_version += 1
		}

		if len(tracking_allocator.bad_free_array) > 0 {
			for b in tracking_allocator.bad_free_array {
				log.errorf("Bad free at: %v", b.location)
			}

			// This prevents the game from closing without you seeing the bad
			// frees. This is mostly needed because I use Sublime Text and my game's
			// console isn't hooked up into Sublime's console properly.
			libc.getchar()
			panic("Bad free detected")
		}
	}

	free_all(context.temp_allocator)
	game_api.shutdown()
	if reset_tracking_allocator(&tracking_allocator) {
		// This prevents the game from closing without you seeing the memory
		// leaks. This is mostly needed because I use Sublime Text and my game's
		// console isn't hooked up into Sublime's console properly.
		libc.getchar()
	}

	for &g in old_game_apis {
		unload_game_api(&g)
	}

	delete(old_game_apis)

	game_api.shutdown_window()
	unload_game_api(&game_api)
	mem.tracking_allocator_destroy(&tracking_allocator)
}

release_init :: proc() {
	// Set working dir to dir of executable.
	exe_path := os.args[0]
	exe_dir := filepath.dir(string(exe_path), context.temp_allocator)
	os.set_current_directory(exe_dir)

	mode: int = 0
	when ODIN_OS == .Linux || ODIN_OS == .Darwin {
		mode = os.S_IRUSR | os.S_IWUSR | os.S_IRGRP | os.S_IROTH
	}

	logh, logh_err := os.open("log.txt", (os.O_CREATE | os.O_TRUNC | os.O_RDWR), mode)

	if logh_err == os.ERROR_NONE {
		os.stdout = logh
		os.stderr = logh
	}

	logger_alloc := context.allocator
	logger :=
		logh_err == os.ERROR_NONE ? log.create_file_logger(logh, allocator = logger_alloc) : log.create_console_logger(allocator = logger_alloc)
	context.logger = logger

	when USE_TRACKING_ALLOCATOR {
		default_allocator := context.allocator
		tracking_allocator: mem.Tracking_Allocator
		mem.tracking_allocator_init(&tracking_allocator, default_allocator)
		context.allocator = mem.tracking_allocator(&tracking_allocator)
	}

	game.game_init_window()
	game.game_init()

	for game.game_should_run() {
		game.game_update()
	}

	free_all(context.temp_allocator)
	game.game_shutdown()
	game.game_shutdown_window()

	when USE_TRACKING_ALLOCATOR {
		for _, value in tracking_allocator.allocation_map {
			log.errorf("%v: Leaked %v bytes\n", value.location, value.size)
		}

		mem.tracking_allocator_destroy(&tracking_allocator)
	}

	if logh_err == os.ERROR_NONE {
		log.destroy_file_logger(logger, logger_alloc)
	}
}
