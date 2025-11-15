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

import "core:math"
import hm "handle_map"
import rl "vendor:raylib"

git_file :: #load("../.git/logs/HEAD")

click: rl.Sound

Game_State :: enum {
	Playing,
	Debug,
}

Game_Memory :: struct {
	run:           bool,
	entities:      Entity_Map,
	music:         rl.Music,
	bpm:           f32,
	level:         Level,
	level_segment: Level_Segment,
	good_beats:    int,
	state:         Game_State,
}

g: ^Game_Memory

commit_hash: string


quarter_rect := rl.Rectangle{10, 20, 20, 20}
half_rect := rl.Rectangle{10, 50, 20, 20}
whole_rect := rl.Rectangle{10, 80, 20, 20}
eighth_rect := rl.Rectangle{10, 110, 20, 20}


onQuarter :: proc() {
	quarter_rect.x += 5
}

onHalf :: proc() {
	half_rect.x += 5

}

onWhole :: proc() {
	whole_rect.x += 5
}

onEighth :: proc() {
	eighth_rect.x += 5
}

update :: proc(dt: f32) {
	if rl.IsKeyPressed(.ESCAPE) {
		g.run = false
	}

	switch g.state {
	case .Playing:
		rl.UpdateMusicStream(g.music)
		g.level.time += dt
		switch &t in g.level_segment {
		case Rhythm_Pattern:
			t.time += dt
			if t.time > pattern_duration(t, g.bpm) {
				segment, since_start := level_get_current_segment(g.level, g.bpm)
				if p_segment, ok := segment.(Rhythm_Pattern); ok {
					p_segment.time = since_start
					segment = p_segment
				}
				g.level_segment = segment
			}
		case Rest_Segment:
			t.time += dt
			if t.time > segment_duration(t, g.bpm) {
				segment, since_start := level_get_current_segment(g.level, g.bpm)
				if p_segment, ok := segment.(Rhythm_Pattern); ok {
					p_segment.time = since_start
					g.level_segment = p_segment
				}
			}
		}

		if pattern, ok := g.level_segment.(Rhythm_Pattern); ok {
			current_subdivision := pattern_get_current_subdivision(pattern, g.bpm)
			if rl.IsMouseButtonPressed(.LEFT) && on_beat(g.music, current_subdivision, g.bpm) {
				g.good_beats += 1
			}
		}
	case .Debug:
	// pass
	}
}

draw :: proc() {
	hash_string := rl.TextFormat("Built From: %s", commit_hash)
	good_beats_str := rl.TextFormat("Good Beats: %d", g.good_beats)

	rl.BeginDrawing()
	DrawRemainingTimeString()
	rl.ClearBackground(rl.BLACK)
	DrawAnchoredText(.TOP_LEFT, {10, 10}, hash_string, 20, rl.WHITE)

	DrawAnchoredText(.TOP_LEFT, {10, 30}, good_beats_str, 20, rl.WHITE)

	button_pos := GetAnchoredPosition(.CENTER, {75, 20}, {0, 75})
	button_rect := rl.Rectangle{f32(button_pos.x), f32(button_pos.y), 75, 20}
	if rl.GuiButton(button_rect, "Toggle Debug") {
		switch g.state {
		case .Playing:
			rl.StopMusicStream(g.music)
			g.state = .Debug
		case .Debug:
			rl.PlayMusicStream(g.music)
			g.state = .Playing
			g.level.time = 0
			segment, _ := level_get_current_segment(g.level, g.bpm)
			g.level_segment = segment
		}
	}

	segment_draw_test_bar(g.level_segment)

	rl.EndDrawing()
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
	level_destroy(&g.level)
	hm.delete(&g.entities)
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
		state = .Debug,
	}

	level_init()
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

level_init :: proc() {
	g.level = level_create()

	assert(len(g.level.segments) == 0, "level length should be zero!")

	level_append_rest(&g.level, 1)

	four_quarter_notes: Rhythm_Pattern
	four_quarter_notes.rhythm = {
		Rhythm_Beat{count = 1, subdivision = .QUARTER},
		Rhythm_Beat{count = 1, subdivision = .QUARTER},
		Rhythm_Beat{count = 1, subdivision = .QUARTER},
		Rhythm_Beat{count = 1, subdivision = .QUARTER},
	}

	song_duration := rl.GetMusicTimeLength(g.music)
	song_beats := int(math.round(song_duration / seconds_per_beat(g.bpm)))
	song_measures := (song_beats - 1) / 4

	for i in 0 ..< song_measures {
		if i % 2 == 0 {
			level_append_pattern(&g.level, four_quarter_notes)
		} else {
			level_append_rest(&g.level, 4)
		}
	}
}
