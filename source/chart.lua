-- Chart expansion: the song's chart strings become a sorted list of
-- notes. L/R/U/D hops, A pounce, B dook; 'S' opens a crank spin whose
-- length is the run of '=' that follows.

Chart = {}

-- returns notes[], maxPoints
function Chart.build(song)
    local str = Conductor.expand(song, "chart")
    local sd = 60 / song.bpm / 4
    local diff = C.DIFFS[(Save.data and Save.data.diff) or 3] or C.DIFFS[3]
    local notes = {}
    local maxPts = 0
    local arrowN = 0
    local i = 1
    while i <= #str do
        local c = str:sub(i, i)
        if c:match("[LRUDAB]") then
            arrowN = arrowN + 1
            -- EASY: drop every 3rd arrow so charts breathe (spins are kept)
            if not (diff.thin and arrowN % 3 == 0) then
                notes[#notes + 1] = { t = (i - 1) * sd, type = c }
                maxPts = maxPts + C.PTS_PERFECT
            end
            i = i + 1
        elseif c == "S" then
            local j = i + 1
            while j <= #str and str:sub(j, j) == "=" do j = j + 1 end
            notes[#notes + 1] = { t = (i - 1) * sd, type = "S", dur = (j - i) * sd, rot = 0 }
            maxPts = maxPts + C.PTS_SPIN
            i = j
        else
            i = i + 1
        end
    end
    return notes, math.max(maxPts, 1)
end
