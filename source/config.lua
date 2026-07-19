-- Tunables (C) and live game state (G). Times are seconds, the game runs
-- a fixed 30fps step, and the music is generated off the same clock the
-- judgment uses, so they can never drift apart.

C = {
    DT = 1 / 30,
    W = 400,
    H = 240,

    -- the note track
    SCROLL = 150,    -- px per second of chart time
    HITX = 64,       -- x of the hit ring
    TRACKY = 218,    -- y of the note track
    LOOKAHEAD = 2.4, -- seconds of notes visible

    -- judgment windows (seconds either side of the note)
    PERFECT = 0.06,
    GOOD = 0.13,

    -- crank spins: required rotation rate while a spin note runs
    SPIN_RATE = 180, -- deg/sec

    -- hypno meter
    METER_START = 55,
    MET_PERFECT = 3,
    MET_GOOD = 1.5,
    MET_MISS = -9,
    MET_FLUB = -4,
    MET_SPIN = 6,

    -- scoring
    PTS_PERFECT = 100,
    PTS_GOOD = 50,
    PTS_SPIN = 150,
    PTS_SPIN_GOOD = 75,
    CLEAR_PCT = 60, -- percent needed to catch the prey / unlock the next
    RANKS = { { 95, "S" }, { 85, "A" }, { 72, "B" }, { 60, "C" }, { 0, "D" } },

    -- layout. The dancer stands directly ABOVE the hit ring (same x) so the
    -- eye reads dancer + judgment as one column instead of two focal points.
    DANCER_X = 64,
    DANCER_Y = 186, -- feet on the ground line
    PREY_X = 330,
    PREY_Y = 186,
    GROUND_Y = 190,

    -- difficulty settings (select screen, up/down). win scales the judgment
    -- windows, meter scales the miss/flub penalties, spin is the required
    -- crank rate, thin drops every 3rd arrow from the chart.
    DIFFS = {
        { name = "EASY",   win = 1.7,  meter = 0.5,  spin = 120, thin = true },
        { name = "NORMAL", win = 1.25, meter = 0.75, spin = 150, thin = false },
        { name = "HARD",   win = 1.0,  meter = 1.0,  spin = 180, thin = false },
    },
}

G = {
    state = "title", -- "title" | "select" | "intro" | "play" | "results"
    t = 0,
    selIx = 1,
    stageIdx = 1,
    meter = C.METER_START,
    combo = 0,
    notes = {},
}
