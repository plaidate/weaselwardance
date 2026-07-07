-- Flair: spark particles, floating judgment popups, combo confetti and a
-- screen-shake timer. Everything is white-on-black beam-and-dot work.

local gfx <const> = playdate.graphics

Fx = {}

local parts = {}
local pops = {}
local confs = {}
local shakeT = 0

function Fx.reset()
    parts, pops, confs = {}, {}, {}
    shakeT = 0
end

function Fx.burst(x, y, n)
    for _ = 1, (n or 8) do
        local a = math.random() * math.pi * 2
        local s = 40 + math.random(70)
        parts[#parts + 1] = {
            x = x, y = y,
            vx = math.cos(a) * s, vy = math.sin(a) * s - 30,
            life = 0.3 + math.random() * 0.3,
        }
    end
end

function Fx.popup(text, x, y)
    pops[#pops + 1] = { text = text, x = x, y = y, life = 0.7 }
end

function Fx.confetti(n)
    for _ = 1, (n or 15) do
        confs[#confs + 1] = {
            x = math.random(40, 360), y = -6 - math.random(30),
            vy = 50 + math.random(50), ph = math.random() * 6,
            life = 2.2,
        }
    end
end

function Fx.shake(secs)
    shakeT = math.max(shakeT, secs or 0.2)
end

function Fx.offset()
    if shakeT > 0 then
        return math.random(-2, 2), math.random(-2, 2)
    end
    return 0, 0
end

function Fx.update(dt)
    if shakeT > 0 then shakeT = shakeT - dt end
    for i = #parts, 1, -1 do
        local p = parts[i]
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(parts, i)
        else
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.vy = p.vy + 160 * dt
        end
    end
    for i = #pops, 1, -1 do
        local p = pops[i]
        p.life = p.life - dt
        p.y = p.y - 26 * dt
        if p.life <= 0 then table.remove(pops, i) end
    end
    for i = #confs, 1, -1 do
        local c = confs[i]
        c.life = c.life - dt
        c.y = c.y + c.vy * dt
        c.x = c.x + math.sin(c.ph + c.y * 0.06) * 0.8
        if c.life <= 0 or c.y > 240 then table.remove(confs, i) end
    end
end

function Fx.draw()
    for _, p in ipairs(parts) do
        gfx.drawPixel(p.x, p.y)
    end
    for _, c in ipairs(confs) do
        gfx.fillRect(c.x, c.y, 3, 2)
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    for _, p in ipairs(pops) do
        local w = gfx.getTextSize(p.text)
        gfx.drawText(p.text, p.x - w / 2, p.y)
    end
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end
