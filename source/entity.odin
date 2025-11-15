package game

import hm "handle_map"

MAX_ENTITIES :: 1024

Entity_Handle :: distinct hm.Handle

Entity :: struct {
	handle:        Entity_Handle,
	position:      [2]f32,

	// -- ANIM
	duration:      f32,
	anim_timer:    f32,
	anim_active:   bool,
	start_pos:     [2]f32,
	current_point: int,
	done:          bool,
}

Entity_Map :: hm.Handle_Map(Entity, Entity_Handle, MAX_ENTITIES)

entity_get :: proc(h: Entity_Handle) -> (^Entity, bool) #optional_ok {
	return hm.get(&g.entities, h)
}

entity_add :: proc(v: Entity) -> Entity_Handle {
	return hm.add(&g.entities, v)
}

entity_remove :: proc(h: Entity_Handle) {
	hm.remove(&g.entities, h)
}

entity_create_anim :: proc(
	pos: [2]f32,
	duration: f32,
	wait_duration: f32,
	animate_on_create: bool = false,
) -> Entity_Handle {

	e := Entity {
		position      = pos,
		duration      = duration,
		anim_timer    = 0,
		anim_active   = animate_on_create,
		current_point = 1,
	}

	return entity_add(e)
}
