package game

Accuracy :: enum {
	None,
	Miss,
	Good,
	Perfect,
}

GOOD_THRESHOLD :: 0.0825
PERF_THRESHOLD :: 0.04125

on_beat_accuracy :: proc() -> Accuracy {
    since_beat, duration: f32
	switch segment in g.level_segment {
	case Rhythm_Pattern:
        current_beat := pattern_get_current_beat(segment, g.bpm)
        _, since_beat = get_beat(g.music, current_beat, g.bpm)
        duration = beat_duration(current_beat, g.bpm)
	case Rest_Segment:
        // TODO: you should be allowed to be a little bit early on the transition from a rest segment
        // to a pattern segment and still get some points
        return .Miss
	}

	beat_distance: f32
	if since_beat > duration / 2 {
		beat_distance = duration - since_beat
	} else {
		beat_distance = since_beat
	}

	assert(beat_distance >= 0, "beat distance should be positive!")

	if beat_distance < PERF_THRESHOLD {
		return .Perfect
	} else if beat_distance < GOOD_THRESHOLD {
		return .Good
	} else {
		return .Miss
	}
}
