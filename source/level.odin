package game

import "core:math"

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
}

level_get_current_segment :: proc(l: Level, tempo: f32) -> (Level_Segment, f32) {
	time: f32 = 0
	for segment in l.segments {
		duration := segment_duration(segment, tempo)
		if time >= l.time {
			since_started := duration - (time - l.time)
			return segment, since_started
		}
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
	append(&l.segments, Rest_Segment{beats})
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
