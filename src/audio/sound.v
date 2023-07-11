module audio

import os

struct Sound {
mut:
	samples []f32 [required]
	pos     int
}

pub fn Sound.from_wav(name string, fpath string) Sound {
	if !os.exists(fpath) || os.is_dir(fpath) {
		eprintln('skipping "${fpath}" (does not exist)')
		return Sound.empty()
	}
	fext := os.file_ext(fpath).to_lower()
	if fext != '.wav' {
		eprintln('skipping "${fpath}" (not a .wav file)')
		return Sound.empty()
	}
	samples := read_wav_file_samples(fpath) or { return Sound.empty() }
	return Sound{
		samples: samples
	}
}

fn Sound.empty() Sound {
	return Sound{
		samples: []
	}
}

pub fn (s Sound) is_valid() bool {
	return s.samples.len > 0
}

pub fn (mut s Sound) free() {
	s.samples = []f32{}
	s.pos = 0
}

// The read_wav_file_samples function below is based on the following sources:
// http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html
// http://www.lightlink.com/tjweber/StripWav/WAVE.html
// http://www.lightlink.com/tjweber/StripWav/Canon.html
// https://tools.ietf.org/html/draft-ema-vpim-wav-00
// Note: > The chunks MAY appear in any order except that the Format chunk
// > MUST be placed before the Sound data chunk (but not necessarily
// > contiguous to the Sound data chunk).
struct RIFFHeader {
	riff      [4]u8
	file_size u32
	form_type [4]u8
}

struct RIFFChunkHeader {
	chunk_type [4]u8
	chunk_size u32
	chunk_data voidptr
}

struct RIFFFormat {
	format_tag            u16    // PCM = 1; Values other than 1 indicate some form of compression.
	nchannels             u16    // Nc ; 1 = mono ; 2 = stereo
	sample_rate           u32    // F
	avg_bytes_per_second  u32    // F * M*Nc
	nblock_align          u16    // M*Nc
	bits_per_sample       u16    // 8 * M
	cbsize                u16    // Size of the extension: 22
	valid_bits_per_sample u16    // at most 8*M
	channel_mask          u32    // Speaker position mask
	sub_format            [16]u8 // GUID
}

fn read_wav_file_samples(fpath string) ![]f32 {
	mut res := []f32{}
	// eprintln('> read_wav_file_samples: $fpath -------------------------------------------------')
	mut bytes := os.read_bytes(fpath)!
	mut pbytes := &u8(bytes.data)
	mut offset := u32(0)
	rh := unsafe { &RIFFHeader(pbytes) }
	// eprintln('rh: $rh')
	if rh.riff != [u8(`R`), `I`, `F`, `F`]! {
		return error('WAV should start with `RIFF`')
	}
	if rh.form_type != [u8(`W`), `A`, `V`, `E`]! {
		return error('WAV should have `WAVE` form type')
	}
	if rh.file_size + 8 != bytes.len {
		return error('WAV should have valid length')
	}
	offset += sizeof(RIFFHeader)
	mut rf := &RIFFFormat(unsafe { nil })
	for {
		if offset >= bytes.len {
			break
		}
		//
		ch := unsafe { &RIFFChunkHeader(pbytes + offset) }
		offset += 8 + ch.chunk_size
		// eprintln('ch: $ch')
		// eprintln('p: $pbytes | offset: $offset | bytes.len: $bytes.len')
		// ////////
		if ch.chunk_type == [u8(`L`), `I`, `S`, `T`]! {
			continue
		}
		//
		if ch.chunk_type == [u8(`i`), `d`, `3`, ` `]! {
			continue
		}
		//
		if ch.chunk_type == [u8(`f`), `m`, `t`, ` `]! {
			// eprintln('`fmt ` chunk')
			rf = unsafe { &RIFFFormat(&ch.chunk_data) }
			// eprintln('fmt riff format: $rf')
			if rf.format_tag != 1 {
				return error('only PCM encoded WAVs are supported')
			}
			if rf.nchannels < 1 || rf.nchannels > 2 {
				return error('only mono or stereo WAVs are supported')
			}
			if rf.bits_per_sample !in [u16(8), 16] {
				return error('only 8 or 16 bits per sample WAVs are supported')
			}
			continue
		}
		//
		if ch.chunk_type == [u8(`d`), `a`, `t`, `a`]! {
			if unsafe { rf == 0 } {
				return error('`data` chunk should be after `fmt ` chunk')
			}
			// eprintln('`fmt ` chunk: $rf\n`data` chunk: $ch')
			mut doffset := 0
			mut dp := unsafe { &u8(&ch.chunk_data) }
			for doffset < ch.chunk_size {
				for c := 0; c < rf.nchannels; c++ {
					mut x := f32(0.0)
					mut step := 0
					ppos := unsafe { dp + doffset }
					if rf.bits_per_sample == 8 {
						d8 := unsafe { &u8(ppos) }
						x = (f32(*d8) - 128) / 128.0
						step = 1
						doffset++
					}
					if rf.bits_per_sample == 16 {
						d16 := unsafe { &i16(ppos) }
						x = f32(*d16) / 32768.0
						step = 2
					}
					doffset += step
					if doffset < ch.chunk_size {
						res << x
						if rf.nchannels == 1 {
							// Duplicating single channel mono sounds,
							// produces a stereo sound, simplifying further processing:
							res << x
						}
					}
				}
			}
		}
	}
	return res
}
