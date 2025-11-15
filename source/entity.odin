package game

import hm "handle_map"

MAX_ENTITIES :: 1024

Entity_Handle :: distinct hm.Handle

Entity :: struct {
	handle:   Entity_Handle,
	position: [2]f32,
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
