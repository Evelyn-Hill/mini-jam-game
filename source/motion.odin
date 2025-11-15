package game

//import "core:fmt"
import "core:math"
import "core:math/linalg"

PATH_LEN :: 7

Bezier :: struct {
	point_a: [2]f32,
	point_b: [2]f32,
	control: [2]f32,
}

/*
bezier_lerp :: proc(b: Bezier, e: Entity_Handle) {
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
*/


mo_entity_lerp :: proc(point: [2]f32, eh: Entity_Handle, g: ^Game_Memory, dt: f32) {
	e := entity_get(eh)

	if e.current_point == PATH_LEN {
		return
	}

	if !e.anim_active {
		return
	}

	if e.anim_timer < e.duration {
		e.anim_timer += dt
		delta := math.clamp(e.anim_timer / e.duration, 0.0, 1.0)
		e.position = linalg.lerp(g.path[e.current_point - 1], g.path[e.current_point], delta)
	} else {
		e.anim_active = false
		e.anim_timer = 0
	}
}
