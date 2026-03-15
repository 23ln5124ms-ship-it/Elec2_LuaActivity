local composer = require("composer")
local scene = composer.newScene()

-------------------------------------------------
-- SELECT TIME FUNCTION
-------------------------------------------------
local function selectTime(event)

    local minutes = event.target.minutes
    local selectedSeconds = minutes * 60

    composer.gotoScene("scene.game", {
        effect = "fade",
        time = 300,
        params = {
            selectedTime = selectedSeconds
        }
    })

    return true
end

-------------------------------------------------
-- CREATE
-------------------------------------------------
function scene:create(event)

    local sceneGroup = self.view

    local bg = display.newRect(sceneGroup,
        display.contentCenterX,
        display.contentCenterY,
        display.contentWidth,
        display.contentHeight)
    bg:setFillColor(0)

    local title = display.newText(sceneGroup,
        "SELECT TIMER",
        display.contentCenterX,
        200,
        native.systemFontBold,
        40)

    for i = 1, 5 do

        local btn = display.newRoundedRect(
            sceneGroup,
            display.contentCenterX,
            250 + (i * 80),
            300,
            60,
            15
        )

        btn:setFillColor(0.4, 0.7, 1)
        btn.minutes = i
        btn.interactive = true

        -- ✅ CORRECT (DO NOT ADD ())
        btn:addEventListener("tap", selectTime)

        local label = display.newText({
            parent = sceneGroup,
            text = i .. " min",
            x = btn.x,
            y = btn.y,
            font = native.systemFontBold,
            fontSize = 26
        })
    end
end

scene:addEventListener("create", scene)

return scene