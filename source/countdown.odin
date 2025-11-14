package game

// This just counts down until the jam ends. I want to make it fun for the
// playtesters. So they can see how much longer we have

import fmt "core:fmt"
//import "core:strings"
import "core:math"
import "core:time"

DrawRemainingTimeString :: proc() {
	now := time.now()
	end_time, ok := time.components_to_time(2025, 11, 16, 22, 30, 00)
	_ = ok

	diff := time.diff(now, end_time)

	str := fmt.aprintf(
		"%v:%v",
		int(time.duration_hours(diff)),
		int(
			60 *
			(f32(time.duration_minutes(diff) / 60) -
					math.round(f32(time.duration_minutes(diff) / 60))),
		),
	)
	delete(str)
}
