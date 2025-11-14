package game

import rl "vendor:raylib"

Rhythm_Unit :: struct {
	count:    int,
	duration: NoteDurations,
}

Rhythm_Pattern :: struct {
	rhythm: []Rhythm_Unit,
	time:   f32,
}

seconds_per_beat :: proc(bpm: int) -> f32 {
	return 60 / f32(bpm)
}

draw_test_bar :: proc(p: Rhythm_Pattern) {
	screen_width := rl.GetScreenWidth()
    bar_size := [2]f32{0.8 * f32(screen_width), 50}
	bar_pos := GetAnchoredPosition(.CENTER, bar_size, {0, 0})
    bar := rl.Rectangle{bar_pos.x, bar_pos.y, bar_size.x, bar_size.y}
    rl.DrawRectangleLinesEx(bar, 2, rl.WHITE)
}
