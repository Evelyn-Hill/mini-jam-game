package game

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

MAX_PATH_LEN :: 16

Bezier :: struct {
	point_a: [2]f32,
	point_b: [2]f32,
	control: [2]f32,
}


Motion :: struct {
	duration: f32,
	timer:    f32,
	pos:      [2]f32,
	active:   bool,
}


bezier_lerp :: proc(b: Bezier, m: ^Motion) {
	if !m.active {
		return
	}

	if m.timer < m.duration {
		m.timer += rl.GetFrameTime()
		delta := math.clamp(m.timer / m.duration, 0.0, 1.0)
		m.pos = rl.GetSplinePointBezierQuad(b.point_a, b.control, b.point_b, delta)
	} else {
		m.active = false
	}
}

/*
entity_lerp_bezier :: proc(b: Bezier, e: ^Entity, t: f32) {
	e.position = bezier_lerp(b, t)
}
*/
