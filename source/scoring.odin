package game

Accuracy :: enum {
    None,
    Miss,
    Good,
    Perfect,
}

GOOD_THRESHOLD :: 0.04125
PERF_THRESHOLD :: 0.0825

on_beat_accuracy :: proc(s: Rhythm_Subdivision) -> Accuracy {
    _, since_beat := get_beat(g.music, s, g.bpm)
    beat_duration := subdivision_duration(s, g.bpm)

    beat_distance: f32
    if since_beat > beat_duration / 2 {
        beat_distance = beat_duration - since_beat
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
