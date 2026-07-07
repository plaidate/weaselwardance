-- The audience: each stage's prey sits stage right getting steadily more
-- hypnotized (spiral eyes, swaying) as the meter climbs, and flinches
-- when the dance stumbles. Also draws each stage's scenery.

local gfx <const> = playdate.graphics

Prey = { startleT = 0 }

function Prey.reset()
    Prey.startleT = 0
end

function Prey.startle()
    Prey.startleT = 0.4
end

function Prey.update(dt)
    if Prey.startleT > 0 then Prey.startleT = Prey.startleT - dt end
end

-- a spiral eye: rotation speed scales with hypnosis
local function eye(x, y, hyp, t)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(x, y, 5)
    gfx.setColor(gfx.kColorBlack)
    if hyp < 15 then
        gfx.fillCircleAtPoint(x, y, 1.5)
    else
        local a0 = t * (30 + hyp * 4)
        for r = 1, 4 do
            gfx.drawArc(x, y, r, a0 + r * 90, a0 + r * 90 + 250)
        end
    end
    gfx.setColor(gfx.kColorWhite)
end

local function heart(x, y)
    gfx.fillCircleAtPoint(x - 2, y, 2.5)
    gfx.fillCircleAtPoint(x + 2, y, 2.5)
    gfx.fillTriangle(x - 4, y + 1, x + 4, y + 1, x, y + 6)
end

function Prey.draw(idx, hyp, t)
    local sp = SPECIES[idx]
    local x, y = C.PREY_X, C.PREY_Y
    local sway = math.sin(t * 2.2) * hyp * 0.045
    x = x + sway * 6
    if Prey.startleT > 0 then
        y = y - math.abs(math.sin(Prey.startleT * 25)) * 8
    end
    local p = sp.prey

    if p == "VOLE" then
        gfx.fillEllipseInRect(x - 8, y - 12, 16, 12)
        gfx.drawLine(x + 8, y - 4, x + 14, y - 2)
        gfx.fillCircleAtPoint(x - 5, y - 12, 2)
        gfx.fillCircleAtPoint(x + 1, y - 12, 2)
        eye(x - 2, y - 7, hyp, t)
    elseif p == "RABBIT" then
        gfx.fillEllipseInRect(x - 10, y - 18, 20, 18)
        gfx.fillEllipseInRect(x - 8, y - 30, 5, 14)
        gfx.fillEllipseInRect(x + 2, y - 31, 5, 15)
        eye(x - 2, y - 11, hyp, t)
    elseif p == "FISH" then
        local bob = math.sin(t * 3) * 2
        gfx.fillEllipseInRect(x - 12, y - 12 + bob, 24, 10)
        gfx.fillTriangle(x + 11, y - 7 + bob, x + 18, y - 12 + bob, x + 18, y - 2 + bob)
        eye(x - 5, y - 7 + bob, hyp, t)
    elseif p == "SOCK" then
        -- a sock can be mesmerized; ferrets know this
        gfx.fillRect(x - 5, y - 22, 10, 14)
        gfx.fillEllipseInRect(x - 5, y - 10, 16, 10)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawLine(x - 4, y - 19, x + 4, y - 19)
        gfx.setColor(gfx.kColorWhite)
        eye(x, y - 14, hyp, t)
    elseif p == "SQUIRREL" then
        gfx.fillEllipseInRect(x - 8, y - 16, 16, 16)
        gfx.setLineWidth(3)
        gfx.drawArc(x + 11, y - 14, 8, 0, 200)
        gfx.setLineWidth(1)
        gfx.fillCircleAtPoint(x - 5, y - 16, 2.5)
        gfx.fillCircleAtPoint(x + 2, y - 16, 2.5)
        eye(x - 2, y - 10, hyp, t)
    elseif p == "COBRA" then
        local swy = math.sin(t * 3 + hyp * 0.02) * (2 + hyp * 0.06)
        gfx.setLineWidth(4)
        gfx.drawLine(x + 6, y, x, y - 10)
        gfx.drawLine(x, y - 10, x + swy, y - 22)
        gfx.setLineWidth(1)
        gfx.fillEllipseInRect(x + swy - 8, y - 34, 16, 14)
        eye(x + swy, y - 28, hyp, t)
        gfx.drawLine(x + swy, y - 20, x + swy + 3, y - 17)
    elseif p == "WOLF" then
        gfx.fillEllipseInRect(x - 14, y - 24, 28, 24)
        gfx.fillTriangle(x - 10, y - 22, x - 4, y - 32, x - 1, y - 22)
        gfx.fillTriangle(x + 2, y - 22, x + 6, y - 32, x + 10, y - 22)
        gfx.fillEllipseInRect(x - 22, y - 14, 12, 7)
        eye(x - 4, y - 15, hyp, t)
    elseif p == "CAIMAN" then
        gfx.fillEllipseInRect(x - 26, y - 10, 52, 10)
        gfx.fillEllipseInRect(x - 34, y - 8, 16, 7)
        gfx.setColor(gfx.kColorBlack)
        for i = 0, 3 do
            gfx.fillTriangle(x - 32 + i * 4, y - 2, x - 30 + i * 4, y - 5, x - 28 + i * 4, y - 2)
        end
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(x - 14, y - 11, 4)
        eye(x - 14, y - 12, hyp, t)
    end

    if hyp > 85 and math.floor(t * 2) % 2 == 0 then
        heart(x, y - 42)
    end
end

-- per-stage backdrop, drawn before everyone else
function Prey.scenery(idx, t)
    local sc = SPECIES[idx].scenery
    gfx.setColor(gfx.kColorWhite)
    gfx.drawLine(0, C.GROUND_Y, 400, C.GROUND_Y)

    if sc ~= "savanna" then
        gfx.drawCircleAtPoint(352, 38, 14) -- moon
        gfx.drawArc(352, 38, 14, 300, 80)
    else
        gfx.fillCircleAtPoint(352, 38, 12) -- sun
    end

    if sc == "meadow" then
        for i = 0, 9 do
            local gx = 20 + i * 41
            gfx.drawLine(gx, 190, gx - 3, 182)
            gfx.drawLine(gx, 190, gx + 3, 181)
        end
    elseif sc == "snow" or sc == "blizzard" then
        local n = sc == "snow" and 14 or 30
        local speed = sc == "snow" and 18 or 55
        for i = 1, n do
            local sx = (i * 97 + t * speed * (1 + i % 3)) % 400
            local sy = (i * 53 + t * speed) % 185
            gfx.drawPixel(400 - sx, sy)
        end
    elseif sc == "river" or sc == "rivernight" then
        for k = 0, 1 do
            local yy = 205 + k * 12
            for xx = 0, 384, 16 do
                gfx.drawArc(xx + 8, yy, 8, 90, 180)
            end
        end
        if sc == "rivernight" then
            for i = 1, 12 do
                gfx.drawPixel((i * 137) % 400, (i * 61) % 90)
            end
        end
    elseif sc == "den" then
        gfx.drawRect(20, 140, 46, 50) -- a crate to hide socks behind
        gfx.drawLine(20, 156, 66, 156)
    elseif sc == "forest" then
        for _, tx in ipairs({ 40, 372 }) do
            gfx.fillRect(tx - 3, 120, 6, 70)
            gfx.fillTriangle(tx - 16, 130, tx + 16, 130, tx, 84)
        end
    elseif sc == "savanna" then
        gfx.fillRect(46, 158, 4, 32)
        gfx.fillEllipseInRect(24, 146, 48, 14)
    end
end
