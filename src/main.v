module main

import audio as au
import frame
import render
import terminal
import events
import time
import player

fn main() {
	mut audio := au.Player.new()

	audio.add('explode', 'assets/explode.wav')
	audio.add('lose', 'assets/lose.wav')
	audio.add('move', 'assets/move.wav')
	audio.add('pew', 'assets/pew.wav')
	audio.add('startup', 'assets/startup.wav')
	audio.add('win', 'assets/win.wav')
	audio.play('startup')

	// Terminal
	stdout := terminal.stdout()
	terminal.enable_raw_mode()
	stdout.execute(terminal.enter_alternate_screen)
	stdout.execute(terminal.hide)

	// Render in a separate thread
	channel := chan frame.Frame{cap: 1}

	render_handle := spawn fn (channel chan frame.Frame) {
		mut last_frame := frame.new_frame()
		render.render(last_frame, last_frame, true)
		for {
			if select {
				curr_frame := <-channel {
					render.render(last_frame, curr_frame, false)
					last_frame = curr_frame
				}
			} {
				continue
			} else {
				break
			}
		}
	}(channel)

	// Game loop
	mut p := player.new()
	gameloop: for {
		// Per-frame init
		mut curr_frame := frame.new_frame()

		// Input
		for event in events.poll() {
			if event is events.KeyboardEvent {
				match event.code {
					.left {
						p.move_left()
					}
					.right {
						p.move_right()
					}
					.q, .escape {
						audio.play('lose')
						break gameloop
					}
					else {}
				}
			}
		}

		// Draw & render
		p.draw(mut &curr_frame)
		channel <- curr_frame
		time.sleep(1 * time.millisecond)
	}

	// Cleanup
	channel.close()
	render_handle.wait()
	audio.wait()
	stdout.execute(terminal.show)
	stdout.execute(terminal.leave_alternate_screen)
	terminal.disable_raw_mode()
}
