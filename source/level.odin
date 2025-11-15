package game

import "core:log"
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

// ok is true if the searched segment is inside the level, and false if the searched segment
// is after the level ends
level_get_segment :: proc {
	level_get_time_segment,
	level_get_beat_segment,
}

level_get_time_segment :: proc(l: Level, time, tempo: f32) -> (Level_Segment, int, bool) {
	curr_time: f32 = 0
	for segment, index in l.segments {
		if curr_time > time {
			return segment, index, true
		}
		switch s in segment {
		case Rhythm_Pattern:
			curr_time += pattern_duration(s, tempo)
		case Rest_Segment:
			curr_time += f32(s.beats) * seconds_per_beat(tempo)
		}
	}
	return l.segments[len(l.segments) - 1], len(l.segments) - 1, false
}

level_get_beat_segment :: proc(
	l: Level,
	beat: int,
	subdivision := Rhythm_Subdivision.QUARTER,
) -> (
	Level_Segment,
	int,
	bool,
) {
	target_beat := int(math.floor(subdivision_quarters(subdivision) * f32(beat)))
	curr_beat := 0
	for segment, index in l.segments {
		if curr_beat > target_beat {
			return segment, index, true
		}
		curr_beat += segment_quarters(segment)
	}
	return l.segments[len(l.segments) - 1], len(l.segments) - 1, false
}

level_get_beat :: proc {
	level_get_segment_beat,
}

level_get_segment_beat :: proc(l: Level, index: int) -> int {
	curr_beat := 0
	for i in 0 ..< index {
		curr_beat += segment_quarters(l.segments[i])
	}
	return curr_beat
}

level_create :: proc() -> Level {
	segments := make([dynamic]Level_Segment)
	return {segments = segments}
}

level_add_pattern :: proc(l: ^Level, start_beat: int, pattern: Rhythm_Pattern) {
	seg, seg_index, in_level := level_get_segment(l^, start_beat)
	_, is_rest := seg.(Rest_Segment)
	if in_level && !is_rest {
		log.errorf("failed to add pattern: beat %d is already inside of a pattern!", start_beat)
		return
	}

	segment_start := level_get_beat(l^, seg_index)
	segment_length := segment_quarters(seg)
	if is_rest {
		pattern_length := segment_quarters(pattern)
		mod_rest := &l.segments[seg_index].(Rest_Segment)
		mod_rest.beats = start_beat - segment_start
		inject_at(&l.segments, segment_start + 1, pattern)
		remain_beats := segment_length - (pattern_length + mod_rest.beats)
		if remain_beats > 0 {
			inject_at(&l.segments, segment_start + 2, Rest_Segment{remain_beats})
		}
	} else {
		segment_end := segment_start + segment_length
		append(&l.segments, Rest_Segment{start_beat + segment_end})
		append(&l.segments, pattern)
	}
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
