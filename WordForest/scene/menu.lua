-- scene/menu.lua
-- Main menu: category selection, daily challenge, stats

local composer  = require("composer")
local scene     = composer.newScene()
local wordbank  = require("modules.wordbank")
local savedata  = require("modules.savedata")
local P         = require("modules.palette")

local W = display.contentWidth
local H = display.contentHeight

-- ─── Category card ───────────────────────────────────────
local function makeCard(parent, cat, x, y, cw, ch, isLocked)
    local g = display.newGroup()
    parent:insert(g)
    g.x = x; g.y = y

    -- Background
    local fillCol = isLocked
        and P.parchment
        or  { cat.color[1]*0.22 + P.cream[1]*0.78,
              cat.color[2]*0.22 + P.cream[2]*0.78,
              cat.color[3]*0.22 + P.cream[3]*0.78 }
    local strokeCol = isLocked
        and { P.warmTan[1], P.warmTan[2], P.warmTan[3], 0.6 }
        or  { cat.color[1], cat.color[2], cat.color[3], 0.65 }

    local bg = display.newRoundedRect(g, 0, 0, cw, ch, 14)
    bg:setFillColor(unpack(fillCol))
    bg.strokeWidth = isLocked and 1 or 2
    bg:setStrokeColor(unpack(strokeCol))

    -- Icon
    P.text(g, isLocked and "🔒" or cat.icon, 0, -ch*0.22, 28)

    -- Name
    local nameCol = isLocked and P.bark or cat.accentColor
    local nameT = P.text(g, isLocked and "LOCKED" or cat.name,
                         0, ch*0.08, 12, native.systemFontBold, nameCol)

    -- Unlock hint
    if isLocked then
        P.text(g, "play more to unlock", 0, ch*0.3, 9, native.systemFont, P.bark)
    end

    if not isLocked then
        P.tapRect(g, 0, 0, cw, ch, function()
            P.flashTap(bg, function()
                composer.gotoScene("scene.difficulty", {
                    effect = "slideLeft", time = 340,
                    params = { categoryId = cat.id }
                })
            end)
        end)
    end

    return g
end

-- ─── Scene ───────────────────────────────────────────────
function scene:create(event)
    local sg = self.view
    savedata.load()

    -- Warm cream background
    local bg = display.newRect(sg, W/2, H/2, W, H)
    bg:setFillColor(unpack(P.cream))

    -- Decorative scattered dots
    for r = 0, 10 do
        for c = 0, 6 do
            local dot = display.newCircle(sg, c*(W/6), r*(H/10), 1.2)
            dot:setFillColor(P.bark[1], P.bark[2], P.bark[3], 0.12)
        end
    end

    -- Logo
    local logo = P.text(sg, "🌿", W/2, 44, 38)
    local title = P.text(sg, "WORD FOREST", W/2, 82, 20,
                          native.systemFontBold, P.moss)
    local sub   = P.text(sg, "find · discover · grow", W/2, 105, 10,
                          native.systemFont, P.bark)

    -- ─── Daily Challenge ─────────────────────────────────
    local streak, doneToday = savedata.checkDailyStreak()

    local dailyBg = display.newRoundedRect(sg, W/2, 155, W-36, 54, 13)
    if doneToday then
        dailyBg:setFillColor(P.parchment[1], P.parchment[2], P.parchment[3])
        dailyBg.strokeWidth = 1
        dailyBg:setStrokeColor(P.warmTan[1], P.warmTan[2], P.warmTan[3], 0.8)
    else
        dailyBg:setFillColor(0.996, 0.965, 0.910)
        dailyBg.strokeWidth = 2
        dailyBg:setStrokeColor(P.amber[1], P.amber[2], P.amber[3], 0.75)
    end

    P.text(sg, "📅", 36, 152, 22)

    local dailyTitle = P.text(sg,
        doneToday and "DAILY CHALLENGE  ✓" or "DAILY CHALLENGE",
        W/2 + 12, 143, 13, native.systemFontBold,
        doneToday and P.bark or P.rust)

    P.text(sg, "🔥 " .. streak .. " day streak  ·  new puzzle every day",
           W/2 + 12, 163, 10, native.systemFont, P.amber)

    if not doneToday then
        P.tapRect(sg, W/2, 155, W-36, 54, function()
            P.flashTap(dailyBg, function()
                composer.gotoScene("scene.game", {
                    effect = "slideLeft", time = 350,
                    params = { mode = "daily" }
                })
            end)
        end)
    end

    -- ─── Category grid ───────────────────────────────────
    P.text(sg, "CHOOSE A WORLD", W/2, 208, 10,
           native.systemFont, P.bark)

    local unlocked = savedata.get("unlockedCategories") or { nature = true }
    local cats     = wordbank.categories
    local cols     = 2
    local cw       = (W - 46) / cols
    local ch       = 102
    local startY   = 238
    local gapX, gapY = 10, 10

    for i, cat in ipairs(cats) do
        local col = (i-1) % cols
        local row = math.floor((i-1) / cols)
        local cx  = 20 + cw/2 + col*(cw + gapX)
        local cy  = startY + ch/2 + row*(ch + gapY)
        makeCard(sg, cat, cx, cy, cw, ch, not unlocked[cat.id])
    end

    -- ─── Stats bar ───────────────────────────────────────
    local statsBg = display.newRect(sg, W/2, H - 38, W, 76)
    statsBg:setFillColor(P.parchment[1], P.parchment[2], P.parchment[3])
    -- top border
    local border = display.newRect(sg, W/2, H - 76, W, 1)
    border:setFillColor(P.warmTan[1], P.warmTan[2], P.warmTan[3])

    local totalWords = savedata.get("totalWordsFound") or 0
    local hints      = savedata.getHintsAvailable()
    local games      = savedata.get("gamesCompleted") or 0

    local statItems = {
        { val = totalWords, lbl = "words" },
        { val = games,      lbl = "games" },
        { val = hints,      lbl = "hints" },
    }
    local sw = W / #statItems
    for i, s in ipairs(statItems) do
        local sx = (i-1)*sw + sw/2
        P.text(sg, tostring(s.val), sx, H - 48, 20, native.systemFontBold, P.moss)
        P.text(sg, s.lbl, sx, H - 28, 9, native.systemFont, P.bark)
    end
end

function scene:show(event) end
function scene:hide(event) end
function scene:destroy(event) end

scene:addEventListener("create",  scene)
scene:addEventListener("show",    scene)
scene:addEventListener("hide",    scene)
scene:addEventListener("destroy", scene)
return scene
