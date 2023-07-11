module audio

import time
import sokol.audio

[noinit]
pub struct Player {
mut:
	sounds  map[string]Sound
	playing ?string
}

fn audio_player_callback(buffer &f32, num_frames int, num_channels int, mut p Player) {
	name := p.playing or { return }

	if name in p.sounds {
		mut s := p.sounds[name]
		ntotal := num_channels * num_frames
		nremaining := s.samples.len - s.pos
		nsamples := if nremaining < ntotal { nremaining } else { ntotal }
		if nsamples <= 0 {
			s.pos = 0
			p.playing = none
			p.sounds[name] = s
			return
		}
		unsafe { vmemcpy(buffer, &s.samples[s.pos], nsamples * int(sizeof(f32))) }
		s.pos += nsamples
		p.sounds[name] = s
	}
}

pub fn (mut p Player) init() {
	audio.setup(
		num_channels: 2
		stream_userdata_cb: audio_player_callback
		user_data: p
	)
}

pub fn Player.new() Player {
	return Player{}
}

pub fn (mut p Player) stop() {
	audio.shutdown()
	p.free()
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

pub fn (mut p Player) play(name string) bool {
	if name in p.sounds {
		p.playing = name
		for p.playing != none {
			time.sleep(16 * time.millisecond)
		}
		return true
	}
	eprintln('> Player - cannot play ${name}')
	return false
}

fn (mut p Player) free() {
	for mut s in p.sounds.values() {
		s.free()
	}
}
