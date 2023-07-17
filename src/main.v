module main

import audio as au
import frame
import render
import terminal
import events
import time
import player
import invaders

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
	mut instant := time.new_stopwatch()
	mut i := invaders.new()
	mut drawables := []frame.Drawable{}
	drawables << p
	drawables << i
	gameloop: for {
		// Per-frame init
		mut curr_frame := frame.new_frame()
		delta := instant.elapsed()
		instant.restart()

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
					.space {
						if p.shoot() {
							audio.play('pew')
						}
					}
					.q, .escape {
						audio.play('lose')
						break gameloop
					}
					else {}
				}
			}
		}

		// Updates
		p.update(delta)
		if i.update(delta) {
			audio.play('move')
		}
		if p.detect_hits(mut i) {
			audio.play('explode')
		}

		// Draw & render
		for drawable in drawables {
			drawable.draw(mut curr_frame)
		}
		channel <- curr_frame
		time.sleep(1 * time.millisecond)

		// Win or lose?
		if i.all_killed() {
			audio.play('win')
			break gameloop
		}
		if i.reached_bottom() {
			audio.play('lose')
			break gameloop
		}
	}

	// Cleanup
	channel.close()
	render_handle.wait()
	audio.wait()
	stdout.execute(terminal.show)
	stdout.execute(terminal.leave_alternate_screen)
	terminal.disable_raw_mode()
}
