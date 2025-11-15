/*
This file is the starting point of your game.

Some important procedures are:
- game_init_window: Opens the window
- game_init: Sets up the game state
- game_update: Run once per frame
- game_should_close: For stopping your game when close button is pressed
- game_shutdown: Shuts down game and frees memory
- game_shutdown_window: Closes window

The procs above are used regardless if you compile using the `build_release`
script or the `build_hot_reload` script. However, in the hot reload case, the
contents of this file is compiled as part of `build/hot_reload/game.dll` (or
.dylib/.so on mac/linux). In the hot reload cases some other procedures are
also used in order to facilitate the hot reload functionality:

- game_memory: Run just before a hot reload. That way game_hot_reload.exe has a
	pointer to the game's memory that it can hand to the new game DLL.
- game_hot_reloaded: Run after a hot reload so that the `g` global
	variable can be set to whatever pointer it was in the old DLL.

NOTE: When compiled as part of `build_release`, `build_debug` or `build_web`
then this whole package is just treated as a normal Odin package. No DLL is
created.
*/

package game

import "core:fmt"
import rl "vendor:raylib"

PIXEL_WINDOW_HEIGHT :: 180

git_file :: #load("../.git/logs/HEAD")

playing: bool = false

click: rl.Sound

Game_Memory :: struct {
	run:      bool,
	entities: Entity_Map,
	music:    rl.Music,
	bpm:      f32,
	pattern:  Rhythm_Pattern,
}

g: ^Game_Memory

commit_hash: string

elapsed: f32
r := rl.Rectangle{20, 20, 25, 25}
b := Bezier{{50, 50}, {150, 50}, {100, 100}}
onQuarter :: proc() {
}

onHalf :: proc() {

}

onWhole :: proc() {
}

onEighth :: proc() {
}


game_camera :: proc() -> rl.Camera2D {
	w := f32(rl.GetScreenWidth())
	h := f32(rl.GetScreenHeight())

	return {zoom = h / PIXEL_WINDOW_HEIGHT, target = [2]f32{}, offset = {w / 2, h / 2}}
}

ui_camera :: proc() -> rl.Camera2D {
	return {zoom = f32(rl.GetScreenHeight()) / PIXEL_WINDOW_HEIGHT}
}

update :: proc(dt: f32) {
	if rl.IsKeyPressed(.ESCAPE) {
		g.run = false
	}

	if playing {
		rl.UpdateMusicStream(g.music)
		g.pattern.time += dt
		if g.pattern.time > pattern_duration(g.pattern, g.bpm) {
			g.pattern.time -= pattern_duration(g.pattern, g.bpm)
		}
	}


	b = Bezier{{50, 50}, {150, 50}, {100, 100}}
	bpos := bezier_lerp(b, 1.0, &elapsed)
	//fmt.println(bpos)
	r.x = bpos.x
	r.y = bpos.y

}

draw :: proc() {
	hash_string := fmt.caprint("Built From: ", commit_hash)
	defer delete(hash_string)


	DrawRemainingTimeString()
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	DrawAnchoredText(.TOP_LEFT, {10, 10}, hash_string, 15, rl.WHITE)

	button_pos := GetAnchoredPosition(.CENTER, {75, 20}, {0, 75})
	button_rect := rl.Rectangle{f32(button_pos.x), f32(button_pos.y), 75, 20}
	if rl.GuiButton(button_rect, "Toggle Music") {
		toggle_music()
	}

	rl.DrawRectangleRec(r, rl.WHITE)
	rl.DrawSplineSegmentBezierQuadratic(b.point_a, b.control, b.point_b, 2, rl.RED)

	//draw_test_bar(g.pattern)

	rl.EndDrawing()
}

toggle_music :: proc() {
	if (playing) {
		rl.StopMusicStream(g.music)
		playing = false
	} else {
		rl.PlayMusicStream(g.music)
		playing = true
		g.pattern.time = 0
	}
}

@(export)
game_update :: proc() {
	dt := rl.GetFrameTime()
	update(dt)
	draw()

	// Everything on tracking allocator is valid until end-of-frame.
	free_all(context.temp_allocator)
}

@(export)
game_init_window :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1280, 720, "Odin + Raylib + Hot Reload template!")
	rl.SetWindowPosition(200, 200)
	rl.SetTargetFPS(60)
	rl.InitAudioDevice()
	rl.SetExitKey(.ESCAPE)
	click = rl.LoadSound("assets/click.wav")
}

@(export)
game_init :: proc() {
	g = new(Game_Memory)

	commit_hash = GitCommitHash(string(git_file))

	game_hot_reloaded(g)
}

@(export)
game_should_run :: proc() -> bool {
	when ODIN_OS != .JS {
		// Never run this proc in browser. It contains a 16 ms sleep on web!
		if rl.WindowShouldClose() {
			return false
		}
	}

	return g.run
}

@(export)
game_shutdown :: proc() {
	free(g)
}

@(export)
game_shutdown_window :: proc() {
	rl.CloseAudioDevice()
	rl.CloseWindow()
}

@(export)
game_memory :: proc() -> rawptr {
	return g
}

@(export)
game_memory_size :: proc() -> int {
	return size_of(Game_Memory)
}

@(export)
game_hot_reloaded :: proc(mem: rawptr) {
	g = (^Game_Memory)(mem)

	g^ = Game_Memory {
		run   = true,
		bpm   = 108,
		music = rl.LoadMusicStream("./assets/save_it_redd.wav"),
	}

	g.pattern.rhythm = {
		Rhythm_Beat{count = 1, subdivision = .QUARTER},
		Rhythm_Beat{count = 1, subdivision = .QUARTER},
		Rhythm_Beat{count = 1, subdivision = .QUARTER},
		Rhythm_Beat{count = 1, subdivision = .QUARTER},
	}

}

@(export)
game_force_reload :: proc() -> bool {
	return rl.IsKeyPressed(.F5)
}

@(export)
game_force_restart :: proc() -> bool {
	return rl.IsKeyPressed(.F6)
}

// In a web build, this is called when browser changes size. Remove the
// `rl.SetWindowSize` call if you don't want a resizable game.
game_parent_window_size_changed :: proc(w, h: int) {
	rl.SetWindowSize(i32(w), i32(h))
}
