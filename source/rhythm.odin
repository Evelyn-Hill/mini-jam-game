package game

import "core:math"
import rl "vendor:raylib"

BEAT_BUFFER :: 0.0825

Rhythm_Beat :: struct {
	count:    int,
	subdivision: Rhythm_Subdivision,
}

Rhythm_Pattern :: struct {
	rhythm: []Rhythm_Beat,
	time:   f32,
}

Rhythm_Subdivision :: enum {
	EIGHTH,
	QUARTER,
	HALF,
	WHOLE,
}

pattern_draw_test_bar :: proc(p: Rhythm_Pattern) {
	screen_width := rl.GetScreenWidth()
	bar_size := [2]f32{0.8 * f32(screen_width), 50}
	bar_pos := GetAnchoredPosition(.CENTER, bar_size, {0, 0})
	bar := rl.Rectangle{bar_pos.x, bar_pos.y, bar_size.x, bar_size.y}

	duration := pattern_duration(p, g.bpm)
	time: f32
	for beat in p.rhythm {
		width := BEAT_BUFFER * bar.width / duration
		start_offset := (time * bar.width / duration)
		if start_offset == 0 {
			width /= 2
		} else {
			start_offset -= width / 2
		}
		box := rl.Rectangle{bar.x + start_offset, bar.y, width, bar.height}
		rl.DrawRectanglePro(box, {}, 0, rl.RED)
		time += beat_duration(beat, g.bpm)
	}

	rl.DrawRectangleLinesEx(bar, 2, rl.WHITE)

    time_line_x := bar.x + (p.time * bar.width) / duration
    time_line_top := [2]f32{ time_line_x, bar.y - 20, }
    time_line_bot := [2]f32{ time_line_x, bar.y + bar.height + 20 }
    rl.DrawLineEx(time_line_top, time_line_bot, 3, rl.BLUE)
}

get_beat :: proc(music: rl.Music, duration: Rhythm_Subdivision, bpm: f32) -> (int, f32) {
	time_playing := rl.GetMusicTimePlayed(music)
	spb := seconds_per_beat(bpm)
	beat_factor: f32
	switch duration {
	case .EIGHTH:
		beat_factor = 0.5
	case .QUARTER:
		beat_factor = 1
	case .HALF:
		beat_factor = 2
	case .WHOLE:
		beat_factor = 4
	}
	num_beats := spb * beat_factor / time_playing
	return int(math.floor(num_beats)), (num_beats - math.floor(num_beats)) / beat_factor
}

pattern_duration :: proc(p: Rhythm_Pattern, bpm: f32) -> f32 {
	sum: f32 = 0
	for beat in p.rhythm {
		sum += beat_duration(beat, bpm)
	}
	return sum
}

beat_duration :: proc(b: Rhythm_Beat, bpm: f32) -> f32 {
	return subdivision_duration(b.subdivision, bpm) * f32(b.count)
}

subdivision_duration :: proc(b: Rhythm_Subdivision, bpm: f32) -> f32 {
	return subdivision_quarters(b) * seconds_per_beat(bpm)
}

subdivision_quarters :: proc(b: Rhythm_Subdivision) -> f32 {
	switch b {
	case .WHOLE:
		return 4
	case .HALF:
		return 2
	case .QUARTER:
		return 1
	case .EIGHTH:
		return 0.5
	}
	panic("")
}

seconds_per_beat :: proc(bpm: f32) -> f32 {
	return 60 / bpm
}
