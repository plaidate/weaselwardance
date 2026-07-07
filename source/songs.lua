-- The eight songs, one per mustelid, small to large. Pattern strings are
-- 16 steps (16ths) per bar; 32-char lines are built by concatenation so
-- the counts cannot drift. Chart glyphs: L R U D hops, A pounce, B dook,
-- S opens a crank spin lasting the run of '='.
--
-- Musical arc: 100 BPM tutorial quarters -> spins -> blues syncopation ->
-- major-key disco dooks -> up/down ladders -> heavy halftime pounces ->
-- dense 150 BPM storm -> 158 BPM everything-finale.

local MP = { 0, 3, 5, 7, 10 }    -- minor pentatonic
local MJ = { 0, 2, 4, 7, 9 }     -- major pentatonic
local BL = { 0, 3, 5, 6, 7, 10 } -- blues

Songs = {}

Songs.list = {
    { -- 1 LEAST WEASEL
        name = "TWITCHY FEET", bpm = 100, root = 110, scale = MP,
        sections = {
            { bars = 2, drum = "K...h...S...h...", bass = "0.......0......." },
            { bars = 4, drum = "K...h...S...h...", bass = "0...0...3...3...",
              lead = "....5.......3...", chart = "L.......R......." },
            { bars = 4, drum = "K...h...S..Kh...", bass = "0...0...5...4...",
              lead = "5...3...5...7...", chart = "L...R...L...R..." },
            { bars = 4, drum = "K.h.h.h.S.h.h.h.", bass = "0.0.....3.3.....",
              lead = "..7...5...3...2.",
              chart = "U.......D......." .. "L...R...U...D..." },
            { bars = 4, drum = "K...h.K.S...h...", bass = "0...3...5...7...",
              lead = "7...5...3...0...", chart = "L...U...R...D..." },
            { bars = 2, drum = "K.......S......." .. "K...K...H.......",
              bass = "0.......0......." .. "3...4...5.......",
              lead = "0...3...5...7..." .. "9...............",
              chart = "L...R...L...R..." .. "A..............." },
        },
    },
    { -- 2 STOAT
        name = "THE WAR DANCE", bpm = 112, root = 98, scale = MP,
        sections = {
            { bars = 2, drum = "K...h...S...h...", bass = "0.......5......." },
            { bars = 4, drum = "K...h...S...h...", bass = "0...0...3...5...",
              lead = "5.......7.......", chart = "L...R...S===...." },
            { bars = 4, drum = "K..h..h.S..h..h.", bass = "0.0.....5.5.....",
              lead = "..5..7..5..3....", chart = "L.R.L...R.L.R..." },
            { bars = 4, drum = "K...h...S...h.h.", bass = "0...3...5...3...",
              lead = "7...9...7...5...", chart = "U...D...S=======" },
            { bars = 4, drum = "K.h.h.h.S.h.h.h.", bass = "0.0.3.3.5.5.3.3.",
              lead = "5.3.5.7.9.7.5.3.", chart = "L.R.U.D.L.R.U.D." },
            { bars = 4, drum = "K.......S.......", bass = "0.......7.......",
              lead = "9...7...5...3...", chart = "S===....S===...." },
            { bars = 2, drum = "K...h...S...h..." .. "K.K.K.K.H.......",
              bass = "0...3...5...7..." .. "0.0.0.0.0.......",
              lead = "5...7...9...7..." .. "9.9.9.9.9.......",
              chart = "L...R...U...D..." .. "S======.A......." },
        },
    },
    { -- 3 MINK
        name = "RIVERBANK SLINK", bpm = 118, root = 104, scale = BL,
        sections = {
            { bars = 2, drum = "K..h..h.S..h..h.", bass = "0..0..3.5..3...." },
            { bars = 4, drum = "K..h..h.S..h..h.", bass = "0..0..3.5..3....",
              lead = "....3..2....0...", chart = "..L.....R......." },
            { bars = 4, drum = "K..h..h.S..h..h.", bass = "0..0..3.5..3....",
              lead = "3..2.0..3..5....", chart = "..L...R...U....." },
            { bars = 4, drum = "K..K..h.S..h..K.", bass = "0.0...5.3...2...",
              lead = "5..3..2..0......", chart = "L..L....R..R...." },
            { bars = 4, drum = "K..h..h.S..hS.h.", bass = "0..0..3.5..3.2..",
              lead = "..5..6..5..3....", chart = "..U...D...L...R." },
            { bars = 4, drum = "K..h..h.S..h..h.", bass = "0..0..5.6..5....",
              lead = "6..5..3..2..0...", chart = "L..R..U..D..S===" },
            { bars = 2, drum = "K.......S......." .. "K..K..K.H.......",
              bass = "0.......5......." .. "0..3..5.6.......",
              lead = "3..5..6.5......." .. "6...............",
              chart = "..L...R........." .. "A..............." },
        },
    },
    { -- 4 FERRET
        name = "DOOK DOOK DISCO", bpm = 126, root = 110, scale = MJ,
        sections = {
            { bars = 2, drum = "K.h.B.h.K.h.B.h.", bass = "0.4.2.4.0.4.2.4." },
            { bars = 4, drum = "K.h.B.h.K.h.B.h.", bass = "0.4.2.4.3.4.2.4.",
              lead = "7...4...7...9...", chart = "B.......B......." },
            { bars = 4, drum = "K.h.B.h.K.h.B.h.", bass = "0.4.2.4.5.4.2.4.",
              lead = "9...7...4...2...", chart = "B.B.....B.B....." },
            { bars = 4, drum = "K.h.B.h.K.h.B.h.", bass = "0.4.0.4.3.4.3.4.",
              lead = "..7..9..7..4....", chart = "L...B...R...B..." },
            { bars = 4, drum = "K.h.B.h.K.h.B.hh", bass = "0.4.2.4.5.5.4.4.",
              lead = "7.9.7.4.2.4.7.9.", chart = "B.B.L...B.B.R..." },
            { bars = 4, drum = "K.h.B.h.K.h.B.h.", bass = "0.4.2.4.3.4.2.4.",
              lead = "4...2...4...7...", chart = "S===B...S===B..." },
            { bars = 2, drum = "K.h.B.h.K.h.B.h." .. "K.K.K.K.H.......",
              bass = "0.4.2.4.3.4.2.4." .. "0.0.0.0.0.......",
              lead = "7...9...7...9..." .. "9.9.9.9.9.......",
              chart = "B.B.B...L...R..." .. "U...D...A......." },
        },
    },
    { -- 5 PINE MARTEN
        name = "CANOPY HOP", bpm = 134, root = 124, scale = MP,
        sections = {
            { bars = 2, drum = "K...h.h.S...h.h.", bass = "0...0...3...3..." },
            { bars = 4, drum = "K...h.h.S...h.h.", bass = "0...0...3...5...",
              lead = "5...7...9...7...", chart = "U.......D......." },
            { bars = 4, drum = "K..h..h.S...h.h.", bass = "0.0...3.5...3...",
              lead = "5.7.9...7.5.3...", chart = "U...U...D...D..." },
            { bars = 4, drum = "K.h.h.h.S.h.h.h.", bass = "0.0.3.3.5.5.7.7.",
              lead = "5.7.9.7.5.3.2.0.", chart = "U.U.D.D.L...R..." },
            { bars = 4, drum = "K.h.h.h.S.h.h.h.", bass = "0.0.5.5.3.3.2.2.",
              lead = "9.7.5.7.9.7.5.3.", chart = "U.D.U.D.R...L..." },
            { bars = 4, drum = "K...h...S...h...", bass = "0...5...3...2...",
              lead = "7...5...7...9...", chart = "S===....U.D.U.D." },
            { bars = 2, drum = "K.h.h.h.S.h.h.h." .. "K.K.K...H.......",
              bass = "0.0.3.3.5.5.7.7." .. "0...0...0.......",
              lead = "5.7.9.7.5.7.9..." .. "9.9.9...9.......",
              chart = "U.D.U.D.L.R.L.R." .. "S====...A......." },
        },
    },
    { -- 6 HONEY BADGER
        name = "DOES NOT CARE", bpm = 140, root = 82, scale = BL,
        sections = {
            { bars = 2, drum = "K.......S.......", bass = "0.......5......." },
            { bars = 4, drum = "K..K....S.......", bass = "0..0....5.......",
              lead = "....3.......2...", chart = "A.......A......." },
            { bars = 4, drum = "K..K....S....K..", bass = "0..0....5....3..",
              lead = "3...2...0.......", chart = "A...L...A...R..." },
            { bars = 4, drum = "K.K.....S.......", bass = "0.0.....6.5.....",
              lead = "..3..3..2..0....", chart = "A.A.....A.A....." },
            { bars = 4, drum = "K..K..K.S.......", bass = "0..0..0.6.......",
              lead = "6...5...3...2...", chart = "A..A....U...D..." },
            { bars = 4, drum = "K.......S......K", bass = "0.......5......3",
              lead = "0...2...3...5...", chart = "S=======........" },
            { bars = 2, drum = "K.K.K.K.S......." .. "K.K.K.K.H.......",
              bass = "0.0.0.0.5......." .. "0.0.0.0.0.......",
              lead = "3.3.3.3.2......." .. "3.3.3.3.6.......",
              chart = "A.A.....L...R..." .. "A.A.....A......." },
        },
    },
    { -- 7 WOLVERINE
        name = "WINTER STORM", bpm = 150, root = 92, scale = MP,
        sections = {
            { bars = 2, drum = "K...h...S...h...", bass = "0...0...0...0..." },
            { bars = 4, drum = "K.h.h.h.S.h.h.h.", bass = "0.0.....3.3.....",
              lead = "5...7...9...7...", chart = "L.R.L.R.U...D..." },
            { bars = 4, drum = "K.h.h.h.S.h.h.h.", bass = "0.0.3.3.5.5.3.3.",
              lead = "9.7.5.3.5.7.9.7.", chart = "U.D.U.D.L...R..." },
            { bars = 4, drum = "K.h.h.h.S.h.K.h.", bass = "0.0.5.5.3.3.2.2.",
              lead = "5.7.9.9.7.5.3.3.", chart = "A...S===A...S===" },
            { bars = 4, drum = "K.h.h.h.S.h.h.h.", bass = "0.0.3.3.5.5.7.7.",
              lead = "9.9.7.7.5.5.3.3.", chart = "L.R.U.D.A...B..." },
            { bars = 4, drum = "K.K.h.h.S.h.h.h.", bass = "0.0.0.0.5.5.5.5.",
              lead = "5.3.5.7.9.7.5.3.", chart = "L.R.L.R.U.D.U.D." },
            { bars = 4, drum = "K.h.h.h.S.h.h.h." .. "K.K.K.K.H.......",
              bass = "0.0.3.3.5.5.7.7." .. "0.0.0.0.0.......",
              lead = "9.7.9.7.9.7.9.7." .. "9.9.9.9.9.......",
              chart = "L.R.U.D.L.R.U.D." .. "S======.A......." },
        },
    },
    { -- 8 GIANT OTTER
        name = "RIVER RAVE", bpm = 158, root = 110, scale = MJ,
        sections = {
            { bars = 2, drum = "K.h.B.h.K.h.B.h.", bass = "0.2.4.2.0.2.4.2." },
            { bars = 4, drum = "K.h.B.h.K.h.B.h.", bass = "0.2.4.2.3.2.4.2.",
              lead = "7...9...7...4...", chart = "L.R.....U.D....." },
            { bars = 4, drum = "K.h.B.h.K.h.B.h.", bass = "0.2.4.2.5.2.4.2.",
              lead = "9.7.4.7.9.7.4.2.", chart = "L.R.U.D.B...B..." },
            { bars = 4, drum = "K.h.B.h.K.h.B.hh", bass = "0.0.4.4.3.3.4.4.",
              lead = "..9..7..9..4....", chart = "S===L.R.S===U.D." },
            { bars = 4, drum = "K.h.B.h.K.h.B.h.", bass = "0.2.4.2.5.5.3.3.",
              lead = "4.7.9.7.4.7.9.7.", chart = "A...L.R.A...U.D." },
            { bars = 4, drum = "K.K.B.h.K.K.B.h.", bass = "0.0.4.4.5.5.4.4.",
              lead = "9.9.7.7.9.9.7.7.", chart = "L.R.L.R.B.B.B.B." },
            { bars = 2, drum = "K.......S.......", bass = "0.......5.......",
              lead = "4...7...9.......", chart = "S==========....." },
            { bars = 4, drum = "K.h.B.h.K.h.B.h." .. "K.K.K.K.H.......",
              bass = "0.2.4.2.3.2.4.2." .. "0.0.0.0.0.......",
              lead = "9...7...9...7..." .. "9.9.9.9.9.......",
              chart = "L.R.U.D.L.R.U.D." .. "B.B.....A......." },
        },
    },
}

-- boot-time sanity: every pattern must be whole bars of 16 steps
for _, song in ipairs(Songs.list) do
    for si, sec in ipairs(song.sections) do
        for _, k in ipairs({ "drum", "bass", "lead", "chart" }) do
            local p = sec[k]
            if p and #p % 16 ~= 0 then
                error(song.name .. " section " .. si .. " " .. k .. " length " .. #p)
            end
        end
    end
end
