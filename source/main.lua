-- Weasel War Dance — a rhythm game for Playdate.
-- Stoats really do dance to mesmerize prey. Work up the family: hop with
-- the d-pad, pounce with A, dook with B, and crank the spins. Eight
-- mustelids from least weasel to giant otter, each with its own song.

import "CoreLibs/graphics"

import "config"
import "util"
import "harness"
import "save"
import "sfx"
import "songs"
import "conductor"
import "chart"
import "judge"
import "dancer"
import "prey"
import "fx"
import "input"
import "ui"

local gfx <const> = playdate.graphics

Save.load()
math.randomseed(playdate.getSecondsSinceEpoch())
playdate.display.setRefreshRate(SMOKE_BUILD and 0 or 30)

Harness.shotPath = "build/wardance-shot.png"

playdate.getSystemMenu():addMenuItem("reset save", function()
    Save.reset()
    G.state = "title"
    G.t = 0
end)

local titleMoveT = 0

local function enterTitle()
    G.state = "title"
    G.t = 0
    Dancer.reset()
end

local function enterSelect()
    G.state = "select"
    G.t = 0
    G.selIx = Util.clamp(G.selIx, 1, Save.data.unlocked)
end

local function enterIntro(i)
    G.stageIdx = i
    G.state = "intro"
    G.t = 0
    Dancer.reset()
    Sfx.blip(880)
end

local function startPlay()
    local song = Songs.list[G.stageIdx]
    Conductor.load(song)
    local notes, maxPts = Chart.build(song)
    Judge.start(notes, maxPts)
    Dancer.reset()
    Prey.reset()
    Fx.reset()
    G.state = "play"
    G.t = 0
    Harness.count("stagesPlayed")
end

local function finishSong()
    Conductor.stop()
    local pct = Judge.pct()
    G.lastPct = pct
    G.lastRank = Judge.rankFor(pct)
    G.caught = pct >= C.CLEAR_PCT
    local d = Save.data
    G.newBest = pct > d.best[G.stageIdx]
    if G.newBest then
        d.best[G.stageIdx] = pct
        d.ranks[G.stageIdx] = G.lastRank
    end
    if G.caught then
        if G.stageIdx == d.unlocked and d.unlocked < #Songs.list then
            d.unlocked = d.unlocked + 1
            Harness.count("unlocks")
        end
        Fx.confetti(30)
        Sfx.caught()
        Harness.count("cleared")
    else
        Sfx.escaped()
        Harness.count("escaped")
    end
    Save.store()
    Harness.count("rank" .. G.lastRank)
    if Save.allClear() and not G.allClearDone then
        G.allClearDone = true
        Harness.set("allClear", 1)
        if Harness.enabled then
            G.sloppy = true -- replays go sloppy: exercise the escape path
        end
    end
    G.state = "results"
    G.t = 0
end

-- idle dancing on the title and select screens
local function idleDance(dt)
    titleMoveT = titleMoveT - dt
    if titleMoveT <= 0 then
        titleMoveT = 0.55
        local moves = { "L", "R", "U", "D", "A", "B" }
        Dancer.setMove(moves[math.random(#moves)])
    end
end

local function updateTitle(dt)
    idleDance(dt)
    if Input.confirm() then
        Sfx.blip(990)
        enterSelect()
    end
end

local selCrank = 0
local function updateSelect(dt)
    idleDance(dt)
    if Harness.enabled then
        if G.t > 0.8 then
            local target
            for i = 1, Save.data.unlocked do
                if Save.data.best[i] < C.CLEAR_PCT then
                    target = i
                    break
                end
            end
            target = target or math.random(Save.data.unlocked)
            G.selIx = target
            enterIntro(target)
        end
        return
    end
    selCrank = selCrank + playdate.getCrankChange()
    local move = 0
    while selCrank >= 60 do selCrank = selCrank - 60; move = move + 1 end
    while selCrank <= -60 do selCrank = selCrank + 60; move = move - 1 end
    if playdate.buttonJustPressed(playdate.kButtonRight) then move = move + 1 end
    if playdate.buttonJustPressed(playdate.kButtonLeft) then move = move - 1 end
    local dd = 0
    if playdate.buttonJustPressed(playdate.kButtonUp) then dd = 1 end
    if playdate.buttonJustPressed(playdate.kButtonDown) then dd = -1 end
    if dd ~= 0 then
        Save.data.diff = Util.clamp(Save.data.diff + dd, 1, #C.DIFFS)
        Save.store()
        Sfx.blip(600 + Save.data.diff * 120)
    end
    if move ~= 0 then
        G.selIx = Util.clamp(G.selIx + move, 1, #SPECIES)
        Sfx.blip(440 + G.selIx * 60)
    end
    if playdate.buttonJustPressed(playdate.kButtonA) then
        if G.selIx <= Save.data.unlocked then
            enterIntro(G.selIx)
        else
            Sfx.flub()
        end
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        enterTitle()
    end
end

local function updatePlay(dt)
    Conductor.update(dt)
    local inp = Input.gather()
    if Conductor.t >= 0 then
        Judge.update(dt, inp)
    end
    Prey.update(dt)
    if Conductor.done() then
        finishSong()
    end
end

local function drawPlay()
    Prey.scenery(G.stageIdx, G.t)
    Prey.draw(G.stageIdx, G.meter, G.t)
    Dancer.draw(C.DANCER_X, C.DANCER_Y, G.stageIdx, 1)
    UI.track()
    UI.playHud()
    Fx.draw()
end

local function tick()
    local dt = C.DT
    G.t = G.t + dt
    Util.runPending(dt)
    Fx.update(dt)
    Dancer.update(dt)

    gfx.clear(gfx.kColorBlack)
    gfx.setColor(gfx.kColorWhite)

    if G.state == "title" then
        updateTitle(dt)
        Prey.scenery(1, G.t)
        UI.title()
    elseif G.state == "select" then
        updateSelect(dt)
        UI.select()
    elseif G.state == "intro" then
        UI.introCard()
        if G.t > 1.8 then startPlay() end
    elseif G.state == "play" then
        updatePlay(dt)
        if G.state == "play" then drawPlay() end
    elseif G.state == "results" then
        UI.results()
        Fx.draw()
        if G.t > 1 and Input.confirm() then
            Sfx.blip(990)
            enterSelect()
        end
    end
end

Harness.extra = function(t)
    t.state = G.state
    t.stage = G.stageIdx
    t.unlocked = Save.data.unlocked
    t.pct = G.lastPct or 0
    t.meter = math.floor(G.meter or 0)
    t.combo = G.combo or 0
    t.sloppy = G.sloppy and 1 or 0
end

local frame = 0
function playdate.update()
    frame = frame + 1
    Harness.frame(frame, tick)
end
