-- Progress persistence: unlock chain, best percent and best rank per
-- stage, in the "wardance" datastore.

Save = {}

local STAGES = 8

Save.data = nil

function Save.load()
    local d = playdate.datastore.read("wardance") or {}
    d.unlocked = d.unlocked or 1
    d.diff = d.diff or 2          -- difficulty index into C.DIFFS (NORMAL)
    d.best = d.best or {}
    d.ranks = d.ranks or {}
    for i = 1, STAGES do
        d.best[i] = d.best[i] or 0
        d.ranks[i] = d.ranks[i] or "-"
    end
    Save.data = d
end

function Save.store()
    playdate.datastore.write(Save.data, "wardance")
end

function Save.reset()
    Save.data = nil
    playdate.datastore.delete("wardance")
    Save.load()
end

function Save.allClear()
    for i = 1, STAGES do
        if Save.data.best[i] < C.CLEAR_PCT then return false end
    end
    return true
end
