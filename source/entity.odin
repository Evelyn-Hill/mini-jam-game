package game
/*
MAX_ENTITIES :: 2048

Entity_Handle :: struct {
	idx: uint,
	gen: uint,
}

Entity :: struct {
	handle:   Entity_Handle,
	position: [2]f32,
}

Entity_Map :: struct {
	items:      [MAX_ENTITIES]Entity,
	free_list:  [MAX_ENTITIES]Entity_Handle,
	free_count: uint,
	count:      uint,
	top:        uint,
}

entity_get :: proc(h: Entity_Handle) -> (^Entity, bool) #optional_ok {
	e := &g.entities.items[h.idx]
	if h.gen == e.handle.gen {
		return e, true
	} else {
		return nil, false
	}
}

entity_add :: proc(v: Entity) -> Entity_Handle {
	v := v

	if g.entities.free_count > 0 {
		g.entities.free_count -= 1
		h := g.entities.free_list[g.entities.free_count]
		h.gen += 1
		v.handle = h
		g.entities.items[h.idx] = v
		g.entities.count += 1
		return h
	}

	assert(g.entities.top < MAX_ENTITIES - 1, "max entities reached")

	v.handle.idx = g.entities.top
	v.handle.gen = 0
	g.entities.items[v.handle.idx] = v
	g.entities.top += 1
	g.entities.count += 1
	return v.handle
}

entity_remove :: proc(h: Entity_Handle) {
	e := &g.entities.items[h.idx]
	if h.gen != e.handle.gen {
		return
	}
	e.handle.gen = 0
	g.entities.count -= 1
	g.entities.free_list[g.entities.free_count] = h
	g.entities.free_count += 1
}
*/
