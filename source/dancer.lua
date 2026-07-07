-- The dancer: one parametric mustelid renderer. A quadratic-spline spine
-- hung between hips and head, circles along it, tail, legs, ears, snout,
-- and per-species markings (stoat tail tip, ferret mask, badger crown
-- stripe, wolverine flank band...). Poses come from the last judged hit;
-- everything bounces on the conductor's beat.

local gfx <const> = playdate.graphics

SPECIES = {
    { name = "LEAST WEASEL", prey = "VOLE",     len = 34, girth = 7,  tail = 14, tailG = 2.4, ear = 3,   leg = 7,  style = "white",     scenery = "meadow" },
    { name = "STOAT",        prey = "RABBIT",   len = 42, girth = 8,  tail = 18, tailG = 3,   ear = 3.5, leg = 8,  style = "tailtip",   scenery = "snow" },
    { name = "MINK",         prey = "FISH",     len = 48, girth = 9,  tail = 22, tailG = 4,   ear = 3,   leg = 8,  style = "dark",      scenery = "river" },
    { name = "FERRET",       prey = "SOCK",     len = 52, girth = 10, tail = 20, tailG = 4,   ear = 4,   leg = 9,  style = "mask",      scenery = "den" },
    { name = "PINE MARTEN",  prey = "SQUIRREL", len = 56, girth = 11, tail = 26, tailG = 6,   ear = 5,   leg = 10, style = "throat",    scenery = "forest" },
    { name = "HONEY BADGER", prey = "COBRA",    len = 66, girth = 16, tail = 12, tailG = 5,   ear = 2,   leg = 10, style = "badger",    scenery = "savanna" },
    { name = "WOLVERINE",    prey = "WOLF",     len = 78, girth = 19, tail = 24, tailG = 8,   ear = 3.5, leg = 12, style = "wolverine", scenery = "blizzard" },
    { name = "GIANT OTTER",  prey = "CAIMAN",   len = 96, girth = 15, tail = 34, tailG = 8,   ear = 2.5, leg = 11, style = "otter",     scenery = "rivernight" },
}

Dancer = { time = 0, stumbleT = 0, spinning = false, spinA = 0 }

local GRAY = { 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55 }    -- 50%
local DIM = { 0x88, 0x22, 0x88, 0x22, 0x88, 0x22, 0x88, 0x22 }     -- 25%

function Dancer.reset()
    Dancer.move = nil
    Dancer.stumbleT = 0
    Dancer.spinning = false
    Dancer.spinA = 0
end

function Dancer.setMove(ty, q)
    Dancer.move = { type = ty, age = 0, q = q }
end

function Dancer.stumble()
    Dancer.stumbleT = 0.5
end

function Dancer.startSpin()
    Dancer.spinning = true
end

function Dancer.spin(deltaDeg)
    Dancer.spinA = (Dancer.spinA + deltaDeg * 2.2) % 360
end

function Dancer.endSpin()
    Dancer.spinning = false
end

function Dancer.update(dt)
    Dancer.time = Dancer.time + dt
    if Dancer.move then
        Dancer.move.age = Dancer.move.age + dt
        if Dancer.move.age > 0.35 then Dancer.move = nil end
    end
    if Dancer.stumbleT > 0 then Dancer.stumbleT = Dancer.stumbleT - dt end
end

local function bodyFill(style)
    if style == "badger" or style == "wolverine" then
        gfx.setPattern(DIM)
    elseif style == "dark" or style == "throat" or style == "otter" then
        gfx.setPattern(GRAY)
    else
        gfx.setColor(gfx.kColorWhite)
    end
end

function Dancer.draw(x, y, idx, scale)
    local sp = SPECIES[idx]
    local s = scale or 1
    local beat = Conductor.beatPulse()
    local tm = Dancer.time

    -- pose from the last judged move
    local dx, dy, lean, crouch, pounce = 0, 0, 0, 0, 0
    local m = Dancer.move
    if m then
        local ph = math.min(m.age / 0.3, 1)
        local arc = math.sin(math.pi * ph)
        if m.type == "L" then
            dx, dy, lean = -12 * arc, -14 * arc, -20 * arc
        elseif m.type == "R" then
            dx, dy, lean = 12 * arc, -14 * arc, 20 * arc
        elseif m.type == "U" then
            dy = -24 * arc
        elseif m.type == "D" then
            crouch = arc
        elseif m.type == "A" then
            pounce = arc
            dx, dy = 26 * arc, -8 * arc
        elseif m.type == "B" then
            lean = -8 * arc
        end
    end
    if Dancer.stumbleT > 0 then
        lean = lean + 28 * math.sin(Dancer.stumbleT * 20) * Dancer.stumbleT * 2
    end
    dx, dy = dx * s, dy * s

    local len = sp.len * s
    local g = sp.girth * s
    local legL = sp.leg * s
    local hgt = len * 0.64 * (1 - 0.10 * beat) * (1 - 0.35 * crouch)
    local gg = g * (1 + 0.25 * crouch + 0.10 * beat)
    local fx, fy = x + dx, y + dy
    local airborne = dy < -3 * s

    -- spine: quadratic from hips to head
    local hipY = -legL
    -- lean the head toward the prey so the body reads as a hunched S
    local headX = len * 0.30 + lean / 90 * len * 0.45 + pounce * len * 0.5
    local headY = hipY - hgt + pounce * hgt * 0.45
    local ctlX = -len * 0.16 + pounce * len * 0.3 + lean / 90 * len * 0.2
    local ctlY = hipY - hgt * 0.45
    if Dancer.spinning then
        local a = math.rad(Dancer.spinA)
        headX = math.cos(a) * len * 0.42
        headY = hipY - hgt * 0.5 + math.sin(a) * hgt * 0.42
        ctlX, ctlY = 0, hipY - hgt * 0.9
    end
    local function bez(t)
        local u = 1 - t
        return fx + 2 * u * t * ctlX + t * t * headX,
            fy + u * u * hipY + 2 * u * t * ctlY + t * t * headY
    end

    -- tail (behind everything), wagging on its own beat
    local wag = math.sin(tm * 6 + idx) * 4 * s + beat * 5 * s
    local tipX, tipY = fx - sp.tail * s - math.abs(wag) * 0.3, fy + hipY - sp.tail * s * 0.35 - wag
    local tcx, tcy = fx - sp.tail * s * 0.5, fy + hipY + 3 * s
    local nT = 5
    for i = 0, nT do
        local t = i / nT
        local u = 1 - t
        local px = u * u * fx + 2 * u * t * tcx + t * t * tipX
        local py = u * u * (fy + hipY) + 2 * u * t * tcy + t * t * tipY
        local r = sp.tailG * s * (1 - 0.7 * t) + 1
        if sp.style == "tailtip" and i >= nT - 1 then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillCircleAtPoint(px, py, r + 1)
            gfx.setColor(gfx.kColorWhite)
            gfx.drawCircleAtPoint(px, py, r + 1)
        else
            bodyFill(sp.style)
            gfx.fillCircleAtPoint(px, py, r)
            gfx.setColor(gfx.kColorWhite)
        end
    end

    -- hind legs
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(2)
    if airborne then
        gfx.drawLine(fx - gg * 0.4, fy + hipY + gg * 0.5, fx - gg * 0.9, fy + hipY + gg * 0.9 + legL * 0.4)
        gfx.drawLine(fx + gg * 0.4, fy + hipY + gg * 0.5, fx + gg * 0.1, fy + hipY + gg * 0.9 + legL * 0.4)
    else
        gfx.drawLine(fx - gg * 0.45, fy + hipY + gg * 0.4, fx - gg * 0.7, fy)
        gfx.drawLine(fx + gg * 0.45, fy + hipY + gg * 0.4, fx + gg * 0.7, fy)
    end
    gfx.setLineWidth(1)

    -- body circles along the spine
    local nB = 8
    for i = 0, nB do
        local t = i / nB
        local px, py = bez(t)
        local r = gg * (1.05 - 0.30 * t)
        bodyFill(sp.style)
        gfx.fillCircleAtPoint(px, py, r)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawCircleAtPoint(px, py, r)
    end

    -- markings along the body
    if sp.style == "badger" then
        for i = 3, nB do
            local px, py = bez(i / nB)
            gfx.fillCircleAtPoint(px, py - gg * 0.55, gg * 0.3)
        end
    elseif sp.style == "wolverine" then
        gfx.setLineWidth(2)
        local lx, ly
        for i = 1, nB - 1 do
            local px, py = bez(i / nB)
            py = py + gg * 0.6
            if lx then gfx.drawLine(lx, ly, px, py) end
            lx, ly = px, py
        end
        gfx.setLineWidth(1)
    end

    -- forelegs dangle from the chest
    local cx2, cy2 = bez(0.72)
    gfx.setLineWidth(2)
    local sway = math.sin(tm * 7) * 3 * s
    if pounce > 0.2 then
        gfx.drawLine(cx2, cy2, cx2 + legL * 0.9, cy2 - legL * 0.2)
        gfx.drawLine(cx2, cy2 + 2, cx2 + legL * 0.8, cy2 + legL * 0.25)
    else
        gfx.drawLine(cx2, cy2, cx2 + sway, cy2 + legL * 0.55)
        gfx.drawLine(cx2 + 3 * s, cy2, cx2 + 3 * s - sway, cy2 + legL * 0.55)
    end
    gfx.setLineWidth(1)

    -- head
    local hx, hy = bez(1)
    local hr = gg * 0.95
    -- ears first (behind the head circle's top edge)
    local er = sp.ear * s
    for _, exo in ipairs({ -0.35, 0.55 }) do
        bodyFill(sp.style)
        gfx.fillCircleAtPoint(hx + hr * exo, hy - hr * 0.9, er)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawCircleAtPoint(hx + hr * exo, hy - hr * 0.9, er)
    end
    bodyFill(sp.style)
    gfx.fillCircleAtPoint(hx, hy, hr)
    gfx.setColor(gfx.kColorWhite)
    gfx.drawCircleAtPoint(hx, hy, hr)

    if sp.style == "badger" then
        gfx.fillEllipseInRect(hx - hr * 0.25, hy - hr, hr * 0.5, hr * 1.4)
    elseif sp.style == "mask" then
        gfx.setColor(gfx.kColorBlack)
        gfx.fillEllipseInRect(hx - hr * 0.85, hy - hr * 0.45, hr * 1.7, hr * 0.6)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawEllipseInRect(hx - hr * 0.85, hy - hr * 0.45, hr * 1.7, hr * 0.6)
    elseif sp.style == "throat" or sp.style == "otter" or sp.style == "dark" then
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(hx + hr * 0.15, hy + hr * 0.75, hr * 0.38)
    end

    -- snout, nose, whiskers
    bodyFill(sp.style)
    gfx.fillCircleAtPoint(hx + hr * 0.8, hy + hr * 0.18, hr * 0.45)
    gfx.setColor(gfx.kColorWhite)
    gfx.drawCircleAtPoint(hx + hr * 0.8, hy + hr * 0.18, hr * 0.45)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(hx + hr * 1.18, hy + hr * 0.12, math.max(1.5, hr * 0.14))
    gfx.setColor(gfx.kColorWhite)
    gfx.drawLine(hx + hr * 0.9, hy + hr * 0.3, hx + hr * 1.5, hy + hr * 0.45)
    gfx.drawLine(hx + hr * 0.9, hy + hr * 0.15, hx + hr * 1.55, hy + hr * 0.1)

    -- eye: X-eyed while stumbling, beady otherwise
    local ex, ey = hx + hr * 0.25, hy - hr * 0.22
    if Dancer.stumbleT > 0.1 then
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(2)
        gfx.drawLine(ex - 3, ey - 3, ex + 3, ey + 3)
        gfx.drawLine(ex + 3, ey - 3, ex - 3, ey + 3)
        gfx.setLineWidth(1)
    else
        if sp.style == "mask" or sp.style == "dark" then
            gfx.setColor(gfx.kColorWhite)
            gfx.fillCircleAtPoint(ex, ey, 3)
        end
        gfx.setColor(gfx.kColorBlack)
        gfx.fillCircleAtPoint(ex, ey, math.max(1.5, hr * 0.16))
    end

    -- dook: open mouth
    if m and m.type == "B" and m.age < 0.25 then
        gfx.setColor(gfx.kColorBlack)
        gfx.fillTriangle(hx + hr * 0.7, hy + hr * 0.45, hx + hr * 1.2, hy + hr * 0.5,
            hx + hr * 0.85, hy + hr * 0.85)
    end

    gfx.setColor(gfx.kColorWhite)
end
