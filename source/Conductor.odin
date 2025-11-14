package game

import math "core:math"
import rl "vendor:raylib"

Conductor :: struct {
	music:              rl.Music,
	timeSincePlayed:    f32,
	bpm:                f32,
	wholeNoteDuration:  f32,
	halfNoteDuration:   f32,
	quaterNoteDuration: f32,
	eighthNoteDuration: f32,
	wholeNote:          int,
	prevWholeNote:      int,
	halfNote:           int,
	prevHalfNote:       int,
	quarterNote:        int,
	prevQuarterNote:    int,
	eighthNote:         int,
	prevEighthNote:     int,
}


SyncBeat :: proc(c: ^Conductor) {

	c.timeSincePlayed = rl.GetMusicTimePlayed(c.music)
	c.quaterNoteDuration = 60.0 / c.bpm
	c.eighthNoteDuration = c.quaterNoteDuration * 0.5
	c.halfNoteDuration = c.quaterNoteDuration * 2
	c.wholeNoteDuration = c.quaterNoteDuration * 4


	c.quarterNote = int(math.floor(c.timeSincePlayed / c.quaterNoteDuration))
	if c.quarterNote > c.prevQuarterNote {
		c.prevQuarterNote = c.quarterNote
	}


	c.halfNote = int(math.floor(c.timeSincePlayed / c.halfNoteDuration))
	if c.halfNote > c.prevHalfNote {
		c.prevHalfNote = c.halfNote
	}


	c.wholeNote = int(math.floor(c.timeSincePlayed / c.wholeNoteDuration))
	if c.wholeNote > c.prevWholeNote {
		c.prevWholeNote = c.wholeNote
	}

	c.eighthNote = int(math.floor(c.timeSincePlayed / c.eighthNoteDuration))
	if c.eighthNote > c.prevEighthNote {
		c.prevEighthNote = c.eighthNote
	}

}
