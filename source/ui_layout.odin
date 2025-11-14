package game

import rl "vendor:raylib"

Anchor :: enum {
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	CENTER,
}

ScreenSize :: distinct [2]i32
UIPosition :: distinct [2]i32

DrawAnchoredText :: proc(
	anchor: Anchor,
	offset: UIPosition,
	text: cstring,
	fontSize: i32,
	color: rl.Color,
) {

	textSize := rl.MeasureTextEx(rl.GetFontDefault(), text, f32(fontSize), 2)
	textSizeI: UIPosition = {i32(textSize.x), i32(textSize.y)}

	switch anchor {
	case .TOP_LEFT:
		rl.DrawText(text, offset.x, offset.y, fontSize, color)
	case .TOP_RIGHT:
		x_pos := (GetScreenSize().x - textSizeI.x) - offset.x
		y_pos := offset.y
		rl.DrawText(text, x_pos, y_pos, fontSize, color)
	case .BOTTOM_LEFT:
		x_pos := offset.x
		y_pos := (GetScreenSize().y - textSizeI.y) - offset.y
		rl.DrawText(text, x_pos, y_pos, fontSize, color)
	case .BOTTOM_RIGHT:
		x_pos := (GetScreenSize().x - textSizeI.x) - offset.x
		y_pos := (GetScreenSize().y - textSizeI.y) - offset.y
		rl.DrawText(text, x_pos, y_pos, fontSize, color)
	case .CENTER:
		x_pos := (GetScreenSize().x / 2) - (textSizeI.x / 2) - offset.x
		y_pos := (GetScreenSize().y / 2) - (textSizeI.y / 2) - offset.y
		rl.DrawText(text, x_pos, y_pos, fontSize, color)
	}

}

// Use this to get the position for an object *before* your draw call.
// eg.
// pos := GetAnchoredPosition(xxxxx)
// DrawRectangle(pos.x, pos.y, size, size, color)
GetAnchoredPosition :: proc(
	anchor: Anchor,
	itemSize: rl.Vector2,
	offset: UIPosition,
) -> UIPosition {

	switch anchor {
	case .TOP_LEFT:
		return offset
	case .TOP_RIGHT:
		return {(GetScreenSize().x - i32(itemSize.x)) - offset.x, offset.y}
	case .BOTTOM_LEFT:
		return {offset.x, (GetScreenSize().y - i32(itemSize.y)) - offset.y}
	case .BOTTOM_RIGHT:
		return {
			(GetScreenSize().x - i32(itemSize.x)) - offset.x,
			(GetScreenSize().y - i32(itemSize.y)) - offset.y,
		}
	case .CENTER:
		return {
			(GetScreenSize().x / 2) - i32(itemSize.x / 2) - offset.x,
			(GetScreenSize().y / 2) - i32(itemSize.y / 2) - offset.y,
		}
	}

	return {0, 0}
}

GetScreenSize :: proc() -> ScreenSize {
	return {rl.GetScreenWidth(), rl.GetScreenHeight()}
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
