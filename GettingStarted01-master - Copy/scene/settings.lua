local composer = require("composer")
local scene = composer.newScene()

local physics = require("physics")

local muteBtn
local backBtn

-- make sure global exists
_G.isMuted = _G.isMuted or false

function scene:create(event)
    local sceneGroup = self.view

    -- Dark overlay
    local overlay = display.newRect(
        sceneGroup,
        display.contentCenterX,
        display.contentCenterY,
        display.contentWidth,
        display.contentHeight
    )
    overlay:setFillColor(0,0,0,0.6)

    -- BACK BUTTON
    backBtn = display.newImageRect(sceneGroup, "images/backbtn.png", 200, 200)
    backBtn.x = display.contentCenterX
    backBtn.y = display.contentCenterY - 60

    -- MUTE BUTTON
    muteBtn = display.newImageRect(sceneGroup, "images/mute.png", 200, 200)
    muteBtn.x = display.contentCenterX
    muteBtn.y = display.contentCenterY + 60
end

function scene:show(event)
    if event.phase == "did" then

        physics.pause()

        --  APPLY CURRENT MUTE STATE WHEN OPENING SETTINGS
        if _G.isMuted then
            audio.setVolume(0.0)
            muteBtn.fill = { type="image", filename="images/unmute.png" }
        else
            audio.setVolume(1.0)
            muteBtn.fill = { type="image", filename="images/mute.png" }
        end

       backBtn:addEventListener("tap", function()

    physics.start()   -- resume physics if needed

    composer.gotoScene("scene.game", {
        effect = "fade",
        time = 300
    })
    return true
end)




        muteBtn:addEventListener("tap", function()

            _G.isMuted = not _G.isMuted

            if _G.isMuted then
                audio.setVolume(0.0)
                muteBtn.fill = { type="image", filename="images/unmute.png" }
                
            else
                audio.setVolume(1.0)
                muteBtn.fill = { type="image", filename="images/mute.png" }
            end

            return true
        end)
    end
end

function scene:hide(event)
    if event.phase == "will" then
        physics.start()
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene