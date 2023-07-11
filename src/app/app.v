module app

import term.ui
import audio

const (
	frame_rate = 30 // fps
	num_rows   = 20
	num_cols   = 40
	bg_color   = ui.Color{0, 0, 0}
	ui_color   = ui.Color{255, 255, 255}
)

struct App {
mut:
	ui            &ui.Context = unsafe { nil }
	frame         [][]string
	audio         &audio.Player = unsafe { nil }
	should_redraw bool = true
}

pub fn create(app_name string, audio_player audio.Player) &App {
	mut self := &App{}

	self.audio = &audio_player
	for _ in 0 .. app.num_cols {
		mut col := []string{}
		for _ in 0 .. app.num_rows {
			col << ' '
		}
		self.frame << col
	}

	self.ui = ui.init(
		user_data: self
		frame_fn: frame
		event_fn: event
		cleanup_fn: cleanup
		frame_rate: 30
		hide_cursor: true
		window_title: app_name
	)

	return self
}

fn cleanup(mut app App) {
	app.audio.play('lose')
	app.audio.free()
}

fn event(event &ui.Event, mut app App) {
	match event.typ {
		.key_down {
			match event.code {
				.q, .escape {
					app.ui.stop()
				}
				else {}
			}
		}
		else {}
	}
}

fn frame(mut app App) {
	app.render()
}

fn (mut app App) render() {
	if app.should_redraw {
		app.ui.clear()
		for col_idx, col in app.frame {
			for row_idx, text in col {
				app.ui.draw_text(col_idx, row_idx, text)
			}
		}
		app.ui.draw_text(0, 0, 'hello')
		app.should_redraw = false
		app.ui.flush()
	}
}

pub fn (mut app App) start() ! {
	app.ui.clear()
	return app.ui.run()
}
