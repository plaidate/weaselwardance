-- Judgment and UI sound effects — separate synth voices from the song
-- instruments so a fanfare never steals the bass.

local snd <const> = playdate.sound

Sfx = {}

local tri = snd.synth.new(snd.kWaveTriangle)
local tri2 = snd.synth.new(snd.kWaveTriangle)
local sq = snd.synth.new(snd.kWaveSquare)
local saw = snd.synth.new(snd.kWaveSawtooth)
local noise = snd.synth.new(snd.kWaveNoise)

function Sfx.perfect()
    tri:playNote(1319, 0.28, 0.05)
end

function Sfx.good()
    tri:playNote(880, 0.22, 0.05)
end

function Sfx.miss()
    noise:playNote(110, 0.4, 0.12)
end

function Sfx.flub()
    saw:playNote(160, 0.3, 0.08)
end

function Sfx.dook()
    sq:playNote(1150, 0.22, 0.04)
    Util.after(0.06, function() sq:playNote(1450, 0.2, 0.04) end)
end

function Sfx.blip(f)
    tri2:playNote(f or 660, 0.25, 0.04)
end

function Sfx.spinStart()
    for i = 0, 3 do
        Util.after(i * 0.05, function() tri2:playNote(500 + i * 180, 0.2, 0.04) end)
    end
end

function Sfx.spinWin()
    for i = 0, 4 do
        Util.after(i * 0.04, function() tri2:playNote(900 + i * 160, 0.25, 0.04) end)
    end
end

function Sfx.jingle(notes, step, vol)
    for i, n in ipairs(notes) do
        Util.after((i - 1) * (step or 0.1), function() tri:playNote(n, vol or 0.3, (step or 0.1) * 1.4) end)
    end
end

function Sfx.caught()
    Sfx.jingle({ 523, 659, 784, 1047, 1319 }, 0.09)
end

function Sfx.escaped()
    Sfx.jingle({ 494, 415, 349, 262 }, 0.14)
end

function Sfx.comboJingle()
    Sfx.jingle({ 784, 1047 }, 0.06, 0.25)
end
