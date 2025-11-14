package game

import math "core:math"
import rl "vendor:raylib"

Conductor :: struct {
	music:                rl.Music,
	timeSincePlayed:      f32,
	bpm:                  f32,

	// ---
	wholeNoteDuration:    f32,
	wholeNote:            int,
	prevWholeNote:        int,
	timeSinceLastWhole:   f32,
	onWhole:              proc(),

	// ---
	halfNoteDuration:     f32,
	halfNote:             int,
	prevHalfNote:         int,
	timeSinceLastHalf:    f32,
	onHalf:               proc(),

	// ---
	quaterNoteDuration:   f32,
	quarterNote:          int,
	prevQuarterNote:      int,
	timeSinceLastQuarter: f32,
	onQuarter:            proc(),

	// ---
	eighthNoteDuration:   f32,
	eighthNote:           int,
	prevEighthNote:       int,
	timeSinceLastEighth:  f32,
	onEighth:             proc(),
}

NoteDurations :: enum {
	EIGHTH,
	QUARTER,
	HALF,
	WHOLE,
}

SyncBeat :: proc(c: ^Conductor) {
	c.timeSincePlayed = rl.GetMusicTimePlayed(c.music)
	c.quaterNoteDuration = 60.0 / c.bpm
	c.eighthNoteDuration = c.quaterNoteDuration * 0.5
	c.halfNoteDuration = c.quaterNoteDuration * 2
	c.wholeNoteDuration = c.quaterNoteDuration * 4


	c.quarterNote = int(math.floor(c.timeSincePlayed / c.quaterNoteDuration))
	c.timeSinceLastQuarter += rl.GetFrameTime()
	if c.quarterNote > c.prevQuarterNote {
		c.prevQuarterNote = c.quarterNote
		c.timeSinceLastQuarter = 0
		c.onQuarter()
	}


	c.halfNote = int(math.floor(c.timeSincePlayed / c.halfNoteDuration))
	c.timeSinceLastHalf += rl.GetFrameTime()
	if c.halfNote > c.prevHalfNote {
		c.prevHalfNote = c.halfNote
		c.timeSinceLastHalf = 0
		c.onHalf()
	}


	c.wholeNote = int(math.floor(c.timeSincePlayed / c.wholeNoteDuration))
	c.timeSinceLastWhole += rl.GetFrameTime()
	if c.wholeNote > c.prevWholeNote {
		c.prevWholeNote = c.wholeNote
		c.timeSinceLastWhole = 0
		c.onWhole()
	}

	c.eighthNote = int(math.floor(c.timeSincePlayed / c.eighthNoteDuration))
	c.timeSinceLastEighth += rl.GetFrameTime()
	if c.eighthNote > c.prevEighthNote {
		c.prevEighthNote = c.eighthNote
		c.timeSinceLastEighth = 0
		c.onEighth()
	}
}

GetNote :: proc(c: ^Conductor, duration: NoteDurations) -> (count: int, timeSince: f32) {
	switch duration {
	case .EIGHTH:
		return c.eighthNote, c.timeSinceLastEighth
	case .QUARTER:
		return c.quarterNote, c.timeSinceLastQuarter
	case .HALF:
		return c.halfNote, c.timeSinceLastHalf
	case .WHOLE:
		return c.wholeNote, c.timeSinceLastWhole
	}

	return -1, -1
}
