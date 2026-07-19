-- Judgment: match presses to the nearest unhit note of that type, grade
-- by offset, run the crank spins, and keep score, combo and the hypno
-- meter. Off-beat mashing is a "flub" and costs meter and combo.

Judge = {}

local clamp = Util.clamp

function Judge.rankFor(pct)
    for _, r in ipairs(C.RANKS) do
        if pct >= r[1] then return r[2] end
    end
    return "D"
end

function Judge.start(notes, maxPts)
    G.diff = C.DIFFS[(Save.data and Save.data.diff) or 3] or C.DIFFS[3]
    G.notes = notes
    G.maxPts = maxPts
    G.points = 0
    G.combo = 0
    G.maxCombo = 0
    G.meter = C.METER_START
    G.nPerfect, G.nGood, G.nMiss, G.nFlub = 0, 0, 0, 0
    G.spinNote = nil
    G.missIx = 1
end

local function addCombo()
    G.combo = G.combo + 1
    if G.combo > G.maxCombo then G.maxCombo = G.combo end
    if G.combo % 25 == 0 then
        Fx.confetti(20)
        Sfx.comboJingle()
        Harness.count("comboMilestones")
    end
end

local function land(note, q)
    note.hit = true
    if q == "P" then
        G.points = G.points + C.PTS_PERFECT
        G.nPerfect = G.nPerfect + 1
        G.meter = clamp(G.meter + C.MET_PERFECT, 0, 100)
        Fx.popup("PERFECT", C.DANCER_X, 96)
        Fx.burst(C.HITX, C.TRACKY, 8)
        Sfx.perfect()
        Harness.count("perfects")
    else
        G.points = G.points + C.PTS_GOOD
        G.nGood = G.nGood + 1
        G.meter = clamp(G.meter + C.MET_GOOD, 0, 100)
        Fx.popup("GOOD", C.DANCER_X, 96)
        Sfx.good()
        Harness.count("goods")
    end
    if note.type == "B" then Sfx.dook() end
    addCombo()
    Dancer.setMove(note.type, q)
end

local function missNote(note)
    note.hit = true
    G.nMiss = G.nMiss + 1
    G.combo = 0
    G.meter = clamp(G.meter + C.MET_MISS * (G.diff and G.diff.meter or 1), 0, 100)
    Fx.popup("MISS", C.DANCER_X, 96)
    Dancer.stumble()
    Prey.startle()
    Sfx.miss()
    Harness.count("misses")
end

local function flub()
    G.nFlub = G.nFlub + 1
    G.combo = 0
    G.meter = clamp(G.meter + C.MET_FLUB * (G.diff and G.diff.meter or 1), 0, 100)
    Dancer.stumble()
    Sfx.flub()
    Harness.count("flubs")
end

function Judge.press(ty)
    local sT = Conductor.t
    local win = G.diff and G.diff.win or 1
    local wGood, wPerfect = C.GOOD * win, C.PERFECT * win
    local best, bdt = nil, wGood + 0.001
    for _, n in ipairs(G.notes) do
        if n.t - sT > wGood then break end
        if not n.hit and n.type == ty then
            local d = math.abs(n.t - sT)
            if d <= wGood and d < bdt then
                best, bdt = n, d
            end
        end
    end
    if best then
        land(best, bdt <= wPerfect and "P" or "G")
    else
        flub()
    end
end

local function judgeSpinEnd(n)
    n.hit = true
    local ratio = n.rot / ((G.diff and G.diff.spin or C.SPIN_RATE) * n.dur)
    if ratio >= 1 then
        G.points = G.points + C.PTS_SPIN
        G.meter = clamp(G.meter + C.MET_SPIN, 0, 100)
        Fx.popup("DIZZYING", C.DANCER_X, 96)
        Fx.confetti(10)
        Sfx.spinWin()
        addCombo()
        Harness.count("spinPerfect")
    elseif ratio >= 0.55 then
        G.points = G.points + C.PTS_SPIN_GOOD
        G.meter = clamp(G.meter + C.MET_GOOD, 0, 100)
        Fx.popup("WOBBLY", C.DANCER_X, 96)
        Sfx.good()
        addCombo()
        Harness.count("spinGood")
    else
        G.nMiss = G.nMiss + 1
        G.combo = 0
        G.meter = clamp(G.meter + C.MET_MISS, 0, 100)
        Fx.popup("TOO SLOW", C.DANCER_X, 96)
        Prey.startle()
        Sfx.miss()
        Harness.count("spinMiss")
    end
    G.spinNote = nil
    Dancer.endSpin()
end

function Judge.update(dt, inp)
    local sT = Conductor.t

    for _, ty in ipairs({ "L", "R", "U", "D", "A", "B" }) do
        if inp[ty] then Judge.press(ty) end
    end

    -- crank spins
    local spin = G.spinNote
    if spin then
        spin.rot = spin.rot + math.abs(inp.crank or 0)
        Dancer.spin(inp.crank or 0)
        if sT > spin.t + spin.dur then judgeSpinEnd(spin) end
    else
        for _, n in ipairs(G.notes) do
            if n.t > sT then break end
            if n.type == "S" and not n.hit then
                G.spinNote = n
                Dancer.startSpin()
                Sfx.spinStart()
                Harness.count("spins")
                break
            end
        end
    end

    -- notes that sailed past unanswered
    while G.missIx <= #G.notes do
        local n = G.notes[G.missIx]
        if n.hit then
            G.missIx = G.missIx + 1
        elseif n.type ~= "S" and sT - n.t > C.GOOD * (G.diff and G.diff.win or 1) then
            missNote(n)
            G.missIx = G.missIx + 1
        elseif n.type == "S" and sT > n.t + (n.dur or 0) + 0.3 then
            G.missIx = G.missIx + 1 -- safety: spin logic owns these
        else
            break
        end
    end
end

function Judge.pct()
    return math.floor(G.points / G.maxPts * 100 + 0.5)
end
