package game

import "core:reflect"
import "core:log"
import "core:math"
import rl "vendor:raylib"

Level :: struct {
	segments: [dynamic]Level_Segment,
	time:     f32,
}

Level_Segment :: union #no_nil {
	Rhythm_Pattern,
	Rest_Segment,
}

Rest_Segment :: struct {
	beats: int,
	time:  f32,
}

level_get_current_segment :: proc(l: Level, tempo: f32) -> (Level_Segment, f32) {
	time: f32 = 0
	for _, index in l.segments {
		if time > l.time {
			segment := l.segments[index - 1]
			duration := segment_duration(segment, tempo)
			since_started := duration - (time - l.time)
			log.debugf("current segment at index %d: %v", index, reflect.union_variant_typeid(segment))
			return segment, since_started
		}
		segment := l.segments[index]
		duration := segment_duration(segment, tempo)
		time += duration
	}
	// at this point time is equal to the duration of the entire level
	return l.segments[len(l.segments) - 1], l.time - time
}

level_create :: proc() -> Level {
	segments := make([dynamic]Level_Segment)
	return {segments = segments}
}

level_append_pattern :: proc(l: ^Level, pattern: Rhythm_Pattern) {
	append(&l.segments, pattern)
}

level_append_rest :: proc(l: ^Level, beats: int) {
	append(&l.segments, Rest_Segment{beats = beats})
}

segment_duration :: proc(segment: Level_Segment, tempo: f32) -> f32 {
	result: f32
	switch s in segment {
	case Rhythm_Pattern:
		result = pattern_duration(s, tempo)
	case Rest_Segment:
		result = beat_duration({count = s.beats, subdivision = .QUARTER}, tempo)
	}
	return result
}

segment_quarters :: proc(segment: Level_Segment) -> int {
	switch s in segment {
	case Rhythm_Pattern:
		return int(math.ceil(pattern_quarters(s)))
	case Rest_Segment:
		return s.beats
	}
	panic("invalid segment")
}

level_destroy :: proc(l: ^Level) {
	if len(l.segments) > 0 {
		delete(l.segments)
	}
}

segment_draw_test_bar :: proc(segment: Level_Segment) {
	switch s in segment {
	case Rhythm_Pattern:
		pattern_draw_test_bar(s)
	case Rest_Segment:
		rest_draw_test_bar(s)
	}
}

rest_draw_test_bar :: proc(s: Rest_Segment) {
	screen_width := rl.GetScreenWidth()
	bar_size := [2]f32{0.8 * f32(screen_width), 50}
	bar_pos := GetAnchoredPosition(.CENTER, bar_size, {0, 0})
	bar := rl.Rectangle{bar_pos.x, bar_pos.y, bar_size.x, bar_size.y}

	duration := segment_duration(s, g.bpm)

	DrawAnchoredText(.CENTER, {0, 0}, "WAIT!!!", 20, rl.RED)

	rl.DrawRectangleLinesEx(bar, 2, rl.WHITE)

	time_line_x := bar.x + (s.time * bar.width) / duration
	time_line_top := [2]f32{time_line_x, bar.y - 20}
	time_line_bot := [2]f32{time_line_x, bar.y + bar.height + 20}
	rl.DrawLineEx(time_line_top, time_line_bot, 3, rl.BLUE)
}
