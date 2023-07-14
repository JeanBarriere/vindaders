module events

pub enum Direction {
	up
	down
	left
	right
}

pub enum MouseButton {
	unknown = -1
	left
	middle
	right
}

fn MouseButton.from_int(nb int) MouseButton {
	match nb {
		0 {
			return MouseButton.left
		}
		1 {
			return MouseButton.middle
		}
		2 {
			return MouseButton.right
		}
		else {
			return MouseButton.unknown
		}
	}
}

[noinit]
struct MouseMoveEvent {
pub:
	x         int
	y         int
	modifiers Modifiers
}

[noinit]
pub struct MouseDragEvent {
	MouseMoveEvent
	button MouseButton
}

[noinit]
pub struct MouseDownEvent {
	MouseMoveEvent
	button MouseButton
}

[noinit]
pub struct MouseUpEvent {
	MouseMoveEvent
	button MouseButton
}

[noinit]
pub struct MouseWheelEvent {
	MouseMoveEvent
	direction Direction
}

pub type MouseEvent = MouseDownEvent
	| MouseDragEvent
	| MouseMoveEvent
	| MouseUpEvent
	| MouseWheelEvent

fn mouse_event(buf string) ?MouseEvent {
	split := buf[3..].split(';')
	if split.len >= 3 {
		typ, x, y := split[0].int(), split[1].int(), split[2].int()
		lo := typ & 0b00011
		hi := typ & 0b11100

		mut modifiers := Modifiers.@none
		if hi & 4 != 0 {
			modifiers.set(.shift)
		}
		if hi & 8 != 0 {
			modifiers.set(.alt)
		}
		if hi & 16 != 0 {
			modifiers.set(.ctrl)
		}

		match typ {
			0...31 {
				last := buf[buf.len - 1]
				if last == `m` {
					return MouseEvent(MouseUpEvent{
						x: x
						y: y
						modifiers: modifiers
						button: MouseButton.from_int(lo)
					})
				} else {
					return MouseEvent(MouseDownEvent{
						x: x
						y: y
						modifiers: modifiers
						button: MouseButton.from_int(lo)
					})
				}
			}
			32...63 {
				if lo < 3 {
					return MouseEvent(MouseDragEvent{
						x: x
						y: y
						modifiers: modifiers
						button: MouseButton.from_int(lo)
					})
				}
				return MouseEvent(MouseMoveEvent{
					x: x
					y: y
					modifiers: modifiers
				})
			}
			64...95 {
				direction := if typ & 1 == 0 { Direction.down } else { Direction.up }
				return MouseEvent(MouseWheelEvent{
					x: x
					y: y
					direction: direction
					modifiers: modifiers
				})
			}
			else {}
		}
	}

	return none
}
