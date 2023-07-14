module events

[noinit]
pub struct WindowResizeEvent {
	width  int
	height int
}

pub type WindowEvent = WindowResizeEvent
