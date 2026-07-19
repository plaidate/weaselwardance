-- Screens and HUD: title, the size-ordered dancer select, stage intro
-- card, the scrolling note track, and results. Big text is the system
-- font drawn into a cached image and scaled up.

local gfx <const> = playdate.graphics

UI = {}

local cache = {}

function UI.text(str, x, y, align)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    local w = gfx.getTextSize(str)
    if align == "center" then
        x = x - w / 2
    elseif align == "right" then
        x = x - w
    end
    gfx.drawText(str, x, y)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

function UI.bigText(str, x, y, scale, center)
    local img = cache[str]
    if not img then
        local w, h = gfx.getTextSize(str)
        img = gfx.image.new(math.max(w, 1), math.max(h, 1))
        gfx.pushContext(img)
        gfx.drawText(str, 0, 0)
        gfx.popContext()
        cache[str] = img
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    local w = img.width * scale
    img:drawScaled(center and (x - w / 2) or x, y, scale)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

-- ---- note glyphs ------------------------------------------------------------

local function glyph(ty, x, y, r)
    if ty == "L" then
        gfx.fillTriangle(x - r, y, x + r * 0.8, y - r * 0.9, x + r * 0.8, y + r * 0.9)
    elseif ty == "R" then
        gfx.fillTriangle(x + r, y, x - r * 0.8, y - r * 0.9, x - r * 0.8, y + r * 0.9)
    elseif ty == "U" then
        gfx.fillTriangle(x, y - r, x - r * 0.9, y + r * 0.8, x + r * 0.9, y + r * 0.8)
    elseif ty == "D" then
        gfx.fillTriangle(x, y + r, x - r * 0.9, y - r * 0.8, x + r * 0.9, y - r * 0.8)
    elseif ty == "A" then
        -- a paw: pad plus toes
        gfx.fillCircleAtPoint(x, y + 1, r * 0.62)
        gfx.fillCircleAtPoint(x - r * 0.55, y - r * 0.45, r * 0.28)
        gfx.fillCircleAtPoint(x, y - r * 0.62, r * 0.28)
        gfx.fillCircleAtPoint(x + r * 0.55, y - r * 0.45, r * 0.28)
    elseif ty == "B" then
        -- a chirp: nested arcs
        gfx.setLineWidth(2)
        gfx.drawArc(x - 2, y, r * 0.4, 20, 160)
        gfx.drawArc(x - 2, y, r * 0.8, 20, 160)
        gfx.setLineWidth(1)
    end
end

function UI.track()
    local sT = Conductor.t
    gfx.drawCircleAtPoint(C.HITX, C.TRACKY, 13)
    gfx.drawCircleAtPoint(C.HITX, C.TRACKY, 10)

    for _, n in ipairs(G.notes) do
        local dtn = n.t - sT
        if dtn > C.LOOKAHEAD then break end
        if n.type == "S" then
            local active = (G.spinNote == n)
            if not n.hit or active then
                local x1 = C.HITX + dtn * C.SCROLL
                local x2 = C.HITX + (n.t + n.dur - sT) * C.SCROLL
                local a = math.max(x1, C.HITX)
                if x2 > 0 and a < 404 then
                    x2 = math.min(x2, 404)
                    gfx.setLineWidth(3)
                    gfx.drawLine(a, C.TRACKY, x2, C.TRACKY)
                    gfx.setLineWidth(1)
                    for cx = a, x2, 11 do
                        gfx.drawCircleAtPoint(cx, C.TRACKY, 6)
                    end
                    if active then
                        local ratio = math.min(n.rot / ((G.diff and G.diff.spin or C.SPIN_RATE) * n.dur), 1)
                        for cx = a, a + (x2 - a) * ratio, 11 do
                            gfx.fillCircleAtPoint(cx, C.TRACKY, 6)
                        end
                        UI.text("CRANK!", C.HITX, C.TRACKY - 34, "center")
                    end
                end
            end
        elseif not n.hit then
            local x = C.HITX + dtn * C.SCROLL
            if x > -12 and x < 412 then
                glyph(n.type, x, C.TRACKY, 9)
            end
        end
    end
end

function UI.playHud()
    local song = Songs.list[G.stageIdx]
    UI.text(song.name, 8, 4)
    UI.text(tostring(G.points), 8, 20)

    -- hypno meter
    UI.text("HYPNO", 296, 4, "right")
    gfx.drawRect(300, 6, 94, 10)
    gfx.fillRect(302, 8, math.floor(90 * G.meter / 100), 6)

    if G.combo >= 5 then
        UI.bigText(G.combo .. " COMBO", 200, 24, 1.5, true)
    end

    -- song progress
    local prog = Util.clamp(Conductor.t / Conductor.dur(), 0, 1)
    gfx.fillRect(0, 238, 400 * prog, 2)

    -- count-in
    if Conductor.t < 0 then
        local n = math.ceil(-Conductor.t / (Conductor.stepDur * 4))
        UI.bigText(tostring(n), 200, 56, 3, true)
    end
end

-- ---- screens ----------------------------------------------------------------

function UI.title()
    UI.bigText("WEASEL", 200, 14, 3, true)
    UI.bigText("WAR DANCE", 200, 46, 3, true)
    UI.text("A RHYTHM ROMP THROUGH THE MUSTELID FAMILY", 200, 88, "center")
    Dancer.draw(200, C.DANCER_Y, 2, 1)
    if math.floor(G.t * 2) % 2 == 0 then
        UI.text("PRESS A TO DANCE", 200, 208, "center")
    end
    UI.text("CRANK READY", 8, 220)
end

function UI.select()
    UI.bigText("CHOOSE YOUR DANCER", 200, 6, 1.5, true)
    local d = Save.data
    UI.text("DIFFICULTY: " .. C.DIFFS[d.diff].name .. "   (UP/DOWN)", 200, 40, "center")
    for i = 1, #SPECIES do
        local x = 34 + (i - 1) * 47
        if i > d.unlocked then
            gfx.drawCircleAtPoint(x, 150, 12)
            UI.text("?", x, 142, "center")
        else
            Dancer.draw(x, 172, i, 0.5)
            UI.text(d.ranks[i], x, 178, "center")
        end
        if i == G.selIx then
            gfx.drawRect(x - 23, 100, 46, 96)
        end
    end
    local sp = SPECIES[G.selIx]
    local song = Songs.list[G.selIx]
    if G.selIx <= d.unlocked then
        UI.text(sp.name .. " - " .. song.name, 200, 202, "center")
        UI.text(song.bpm .. " BPM   PREY: " .. sp.prey .. "   BEST " .. d.best[G.selIx], 200, 220, "center")
    else
        UI.text(sp.name, 200, 202, "center")
        UI.text("LOCKED - CATCH THE PREY BEFORE IT", 200, 220, "center")
    end
end

function UI.introCard()
    Prey.scenery(G.stageIdx, G.t)
    Prey.draw(G.stageIdx, 0, G.t)
    Dancer.draw(C.DANCER_X, C.DANCER_Y, G.stageIdx, 1)
    local sp = SPECIES[G.stageIdx]
    local song = Songs.list[G.stageIdx]
    UI.bigText(sp.name, 200, 20, 2, true)
    UI.text(song.name .. "   " .. song.bpm .. " BPM", 200, 56, "center")
    UI.text("MESMERIZE THE " .. sp.prey, 200, 76, "center")
end

function UI.results()
    local sp = SPECIES[G.stageIdx]
    if G.caught then
        UI.bigText("PREY CAUGHT", 200, 12, 2, true)
    else
        UI.bigText(sp.prey .. " ESCAPED", 200, 12, 2, true)
    end
    UI.bigText(G.lastRank, 200, 48, 5, true)
    UI.text(G.lastPct .. " PERCENT MESMERIZED", 200, 112, "center")
    UI.text("PERFECT " .. G.nPerfect .. "   GOOD " .. G.nGood .. "   MISS " .. G.nMiss .. "   FLUB " .. G.nFlub,
        200, 132, "center")
    UI.text("BEST COMBO " .. G.maxCombo, 200, 150, "center")
    if G.newBest then
        UI.text("NEW BEST!", 200, 168, "center")
    end
    if G.caught and G.stageIdx < #SPECIES and Save.data.unlocked == G.stageIdx + 1 then
        UI.text(SPECIES[G.stageIdx + 1].name .. " UNLOCKED", 200, 186, "center")
    end
    if math.floor(G.t * 2) % 2 == 0 then
        UI.text("A - CONTINUE", 200, 212, "center")
    end
end
