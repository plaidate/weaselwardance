-- The conductor: a 16th-note step sequencer driven by the game clock.
-- Songs are pattern strings (16 steps per bar); the clock starts one bar
-- early for the count-in clicks. Because judgment reads the same clock,
-- audio and gameplay stay locked by construction.

local snd <const> = playdate.sound

Conductor = { t = 0, playing = false, stepDur = 0.125, total = 0 }

local kick = snd.synth.new(snd.kWaveSine)
local snare = snd.synth.new(snd.kWaveNoise)
local hat = snd.synth.new(snd.kWaveNoise)
local bass = snd.synth.new(snd.kWaveSquare)
local lead = snd.synth.new(snd.kWaveTriangle)
local click = snd.synth.new(snd.kWaveSquare)

-- expand a song's sections into one long per-step string for `key`;
-- section patterns repeat cyclically to fill their bar count
function Conductor.expand(song, key)
    local out = {}
    for _, sec in ipairs(song.sections) do
        local pat = sec[key]
        if not pat or #pat == 0 then pat = "................" end
        local steps = sec.bars * 16
        for i = 0, steps - 1 do
            local j = (i % #pat) + 1
            out[#out + 1] = pat:sub(j, j)
        end
    end
    return table.concat(out)
end

function Conductor.load(song)
    Conductor.song = song
    Conductor.stepDur = 60 / song.bpm / 4
    Conductor.drum = Conductor.expand(song, "drum")
    Conductor.bass = Conductor.expand(song, "bass")
    Conductor.lead = Conductor.expand(song, "lead")
    Conductor.total = #Conductor.drum
    Conductor.t = -Conductor.stepDur * 16 -- one count-in bar
    Conductor.lastStep = -17
    Conductor.playing = true
end

local function degFreq(root, scale, ch)
    local d = ch:byte() - 48 -- '0'.. index into the scale, octaves stacked
    local n = #scale
    local semis = scale[(d % n) + 1] + 12 * (d // n)
    return root * 2 ^ (semis / 12)
end

local function trigger(s)
    local song = Conductor.song
    if s < 0 then
        if s % 4 == 0 then
            click:playNote(s % 16 == 0 and 1760 or 1175, 0.28, 0.05)
        end
        return
    end
    if s >= Conductor.total then return end
    local i = s + 1
    local d = Conductor.drum:sub(i, i)
    if d == "K" then
        kick:playNote(52, 0.55, 0.09)
    elseif d == "S" then
        snare:playNote(400, 0.4, 0.07)
    elseif d == "B" then
        kick:playNote(52, 0.55, 0.09)
        snare:playNote(400, 0.4, 0.07)
    elseif d == "h" then
        hat:playNote(3000, 0.12, 0.025)
    elseif d == "H" then
        hat:playNote(2300, 0.22, 0.12)
    end
    local b = Conductor.bass:sub(i, i)
    if b:match("%d") then
        bass:playNote(degFreq(song.root, song.scale, b), 0.22, Conductor.stepDur * 1.8)
    end
    local l = Conductor.lead:sub(i, i)
    if l:match("%d") then
        lead:playNote(degFreq(song.root * 2, song.scale, l), 0.18, Conductor.stepDur * 1.6)
    end
end

function Conductor.update(dt)
    if not Conductor.playing then return end
    Conductor.t = Conductor.t + dt
    local step = math.floor(Conductor.t / Conductor.stepDur)
    while Conductor.lastStep < step do
        Conductor.lastStep = Conductor.lastStep + 1
        trigger(Conductor.lastStep)
    end
end

-- 1 on the beat decaying to 0, for squash-and-stretch
function Conductor.beatPulse()
    if not Conductor.playing then return 0 end
    local beatDur = Conductor.stepDur * 4
    local ph = (Conductor.t % beatDur) / beatDur
    return math.max(0, 1 - ph * 3)
end

function Conductor.dur()
    return Conductor.total * Conductor.stepDur
end

function Conductor.done()
    return Conductor.playing and Conductor.t > Conductor.dur() + 1.6
end

function Conductor.stop()
    Conductor.playing = false
end
