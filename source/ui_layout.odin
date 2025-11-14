package game

import rl "vendor:raylib"

Anchor :: enum {
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	CENTER,
}

DrawAnchoredText :: proc(
	anchor: Anchor,
	offset: [2]f32,
	text: cstring,
	fontSize: f32,
	color: rl.Color,
) {
	textSize := rl.MeasureTextEx(rl.GetFontDefault(), text, f32(fontSize), 2)

    default_font := rl.GetFontDefault()

    position := offset
	switch anchor {
	case .TOP_LEFT:
        // pass, position is the same as offset
	case .TOP_RIGHT:
		position.x = (get_f32_screen_size().x - textSize.x) - offset.x
	case .BOTTOM_LEFT:
		position.y = (get_f32_screen_size().y - textSize.y) - offset.y
	case .BOTTOM_RIGHT:
		position.x = (get_f32_screen_size().x - textSize.x) - offset.x
		position.y = (get_f32_screen_size().y - textSize.y) - offset.y
	case .CENTER:
		position.x = (get_f32_screen_size().x / 2) - (textSize.x / 2) - offset.x
		position.y = (get_f32_screen_size().y / 2) - (textSize.y / 2) - offset.y
	}
    rl.DrawTextEx(default_font, text, offset, fontSize, 0, color)
}

// Use this to get the position for an object *before* your draw call.
// eg.
// pos := GetAnchoredPosition(xxxxx)
// DrawRectangle(pos.x, pos.y, size, size, color)
GetAnchoredPosition :: proc(
	anchor: Anchor,
	itemSize: [2]f32,
	offset: [2]f32,
) -> [2]f32 {

	switch anchor {
	case .TOP_LEFT:
		return offset
	case .TOP_RIGHT:
		return {(get_f32_screen_size().x - itemSize.x) - offset.x, offset.y}
	case .BOTTOM_LEFT:
		return {offset.x, (get_f32_screen_size().y - itemSize.y) - offset.y}
	case .BOTTOM_RIGHT:
		return {
			(get_f32_screen_size().x - itemSize.x) - offset.x,
			(get_f32_screen_size().y - itemSize.y) - offset.y,
		}
	case .CENTER:
		return {
			(get_f32_screen_size().x / 2 - itemSize.x / 2 - offset.x),
			(get_f32_screen_size().y / 2 - itemSize.y / 2 - offset.y),
		}
	}

	return {0, 0}
}

GetScreenSize :: proc() -> [2]i32 {
    return {
        rl.GetScreenWidth(),
        rl.GetScreenHeight(),
    }
}

get_i32_screen_size :: GetScreenSize

get_f32_screen_size :: proc() -> [2]f32 {
    return {
        f32(rl.GetScreenWidth()),
        f32(rl.GetScreenHeight()),
    }
}

/* I'll do these if I gotta. -P
HorizontalList :: proc(size: $N, spacing: int, origin: rl.Vector2) -> [N]rl.Vector2 {
	list := [size]rl.Vector2
	for i := 0; i < size; i += 1 {
		list[i] = {0, 0}
	}
	return list
}

VerticalList :: proc(size: $N, spacing: int, origin: rl.Vector2) -> [N]rl.Vector2 {
	list := [size]rl.Vector2
	for i := 0; i < size; i += 1 {
		list[i] = {0, 0}
	}
	return list
}
*/
