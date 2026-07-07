-- Controls: d-pad hops, A pounce, B dook, crank for spin sections. The
-- smoke autopilot reads the chart and plays it back with human-ish
-- imperfection; after every stage is cleared it turns sloppy so the
-- prey-escaped path gets exercised too.

Input = {}

-- returns { L,R,U,D,A,B = justPressed booleans, crank = degrees }
function Input.gather()
    if Harness.enabled and Harness.autopilot then
        return Harness.autopilot()
    end
    local jp = playdate.buttonJustPressed
    return {
        L = jp(playdate.kButtonLeft),
        R = jp(playdate.kButtonRight),
        U = jp(playdate.kButtonUp),
        D = jp(playdate.kButtonDown),
        A = jp(playdate.kButtonA),
        B = jp(playdate.kButtonB),
        crank = playdate.getCrankChange(),
    }
end

-- menu confirm, autopilot-aware
function Input.confirm()
    if Harness.enabled then
        return G.t > 0.6
    end
    return playdate.buttonJustPressed(playdate.kButtonA)
end

Harness.autopilot = function()
    local inp = { crank = 0 }
    if G.state ~= "play" then return inp end
    local sT = Conductor.t
    local accuracy = G.sloppy and 0.45 or 0.95
    for _, n in ipairs(G.notes) do
        if n.t > sT + 0.1 then break end
        if not n.hit and not n.apDone and n.type ~= "S" then
            if sT >= n.t - C.DT / 2 then
                if math.random() < 0.2 then
                    -- hesitate a frame: lands as a late perfect or a good
                else
                    n.apDone = true
                    if math.random() < accuracy then
                        inp[n.type] = true
                    end
                end
            end
        end
    end
    if G.spinNote then
        local rate = G.sloppy and 120 or 360
        inp.crank = rate * C.DT
    end
    return inp
end
