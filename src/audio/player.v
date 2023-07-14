module audio

import time
import sokol.audio

[noinit]
pub struct Player {
mut:
	sounds      map[string]Sound
	initialised bool
	pause       bool
	queue       []string
	pos         int
}

fn audio_player_callback(buffer &f32, num_frames int, num_channels int, mut p Player) {
	name := p.queue[0] or {
		if p.initialised {
			audio.shutdown()
			p.initialised = false
		}
		return
	}

	if !p.pause && name in p.sounds {
		ntotal := num_channels * num_frames
		nremaining := p.sounds[name].samples.len - p.pos
		nsamples := if nremaining < ntotal { nremaining } else { ntotal }
		if nsamples <= 0 {
			p.next()
			return
		}
		unsafe { vmemcpy(buffer, &p.sounds[name].samples[p.pos], nsamples * int(sizeof(f32))) }
		p.pos += nsamples
	}
}

pub fn (mut p Player) init() {
	if !p.pause && !p.initialised {
		audio.setup(
			num_channels: 2
			stream_userdata_cb: audio_player_callback
			user_data: p
		)
		p.initialised = true
	}
}

pub fn Player.new() Player {
	return Player{}
}

pub fn (mut p Player) next() {
	p.pause = true
	p.queue.delete(0)
	p.pos = 0
	p.pause = false
	p.init()
}

pub fn (mut p Player) clear() {
	p.pause = true
	p.queue.clear()
}

pub fn (mut p Player) stop() {
	p.pause = true
	p.queue.delete(0)
	p.pos = 0
}

pub fn (mut p Player) add(name string, path string) bool {
	sound := Sound.from_wav(name, path)
	if sound.is_valid() {
		p.sounds[name] = sound
		return true
	}
	eprintln('> Player - invalid wav sound path: ${path}')
	return false
}

pub fn (mut p Player) pause() {
	p.pause = true
}

pub fn (mut p Player) play(name ?string) bool {
	p.pause = false
	p.init()

	if name != none && name in p.sounds {
		p.queue << name
		return true
	} else if name != none {
		eprintln('> Player - cannot play ${name}')
	}
	return false
}

[params]
pub struct WaitOptions {
	timeout time.Duration = time.Duration(15 * time.second)
}

pub fn (mut p Player) wait(options WaitOptions) {
	sw := time.new_stopwatch(auto_start: true)
	for p.queue.len > 0 {
		time.sleep(16 * time.millisecond)
		if sw.elapsed().milliseconds() > options.timeout.milliseconds() {
			p.stop()
		}
	}
}

pub fn (mut p Player) free() {
	p.queue.clear()

	for mut s in p.sounds.values() {
		s.free()
	}

	if p.initialised {
		audio.shutdown()
	}
}
