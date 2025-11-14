package game

import rl "vendor:raylib"

BEAT_BUFFER :: 0.125

Rhythm_Unit :: struct {
	count:    int,
	duration: NoteDurations,
}

Rhythm_Pattern :: struct {
	rhythm: []Rhythm_Unit,
	time:   f32,
}

draw_test_bar :: proc(p: Rhythm_Pattern) {
	screen_width := rl.GetScreenWidth()
	bar_size := [2]f32{0.8 * f32(screen_width), 50}
	bar_pos := GetAnchoredPosition(.CENTER, bar_size, {0, 0})
	bar := rl.Rectangle{bar_pos.x, bar_pos.y, bar_size.x, bar_size.y}

	duration := pattern_duration(p, g.conductor.bpm)
	time: f32
	for beat in p.rhythm {
		start_offset := time * bar.width / duration
		width := BEAT_BUFFER * bar.width / duration
		box := rl.Rectangle{bar.x + start_offset, bar.y, width, bar.height}
		rl.DrawRectanglePro(box, {}, 0, rl.RED)
		time += beat_duration(beat, g.conductor.bpm)
	}

	rl.DrawRectangleLinesEx(bar, 2, rl.WHITE)
}

pattern_duration :: proc(p: Rhythm_Pattern, bpm: f32) -> f32 {
	sum: f32 = 0
	for beat in p.rhythm {
		sum += beat_duration(beat, bpm)
	}
	return sum
}

beat_duration :: proc(b: Rhythm_Unit, bpm: f32) -> f32 {
	count := f32(b.count)
	quarters: f32
	switch b.duration {
	case .WHOLE:
		quarters = count * 4
	case .HALF:
		quarters = count * 2
	case .QUARTER:
		quarters = count
	case .EIGHTH:
		quarters = count / 2.0
	}

	return quarters * seconds_per_beat(bpm)
}

seconds_per_beat :: proc(bpm: f32) -> f32 {
	return 60 / bpm
}
