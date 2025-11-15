package handle_map

import "base:runtime"
import "base:intrinsics"

Handle :: struct {
	idx: uint,
	gen: uint,
}

Handle_Map :: struct($T: typeid, $HT: typeid, $N: uint) {
	items:      [N]T,
	free_list:  [dynamic]HT,
	count:      uint,
	top:        uint,
}

clear :: proc(hm: ^Handle_Map($T, $HT, $N), loc := #caller_location) {
	intrinsics.mem_zero(hm.items, size_of(hm.items))
	runtime.clear(hm.free_list, loc)
	hm.count = 0
	hm.items = 0
}

delete :: proc(hm: ^Handle_Map($T, $HT, $N), loc := #caller_location) {
	runtime.delete(hm.free_list, loc)
}

get :: proc(hm: ^Handle_Map($T, $HT, $N), h: HT) -> (^T, bool) #optional_ok {
	if hm.count == 0 || h.idx >= hm.top {
		return nil, false
	}

	e := &hm.items[h.idx]
	if h.gen == e.handle.gen {
		return e, true
	} else {
		return nil, false
	}
}

add :: proc(hm: ^Handle_Map($T, $HT, $N), v: T) -> HT {
	v := v

	if len(hm.free_list) > 0 {
		h := pop(&hm.free_list)
		h.gen += 1
		v.handle = h
		hm.items[h.idx] = v
		hm.count += 1
		return h
	}

	v.handle.idx = hm.top
	v.handle.gen = 1
	hm.items[v.handle.idx] = v
	hm.count += 1
	hm.top += 1
	return v.handle
}

remove :: proc(hm: ^Handle_Map($T, $HT, $N), h: HT) {
	e := &hm.items[h.idx]
	if h.gen != e.handle.gen {
		return
	}
	e.handle.gen = 0
	hm.count -= 1
	append(&hm.free_list, h)
}
