local composer = require("composer")
local scene = composer.newScene()

local physics = require("physics")

local muteBtn
local backBtn

-- make sure global exists
_G.isMuted = _G.isMuted or false

function scene:create(event)
    local sceneGroup = self.view

    -- Background image for settings screen
    local bg = display.newImageRect(sceneGroup, "images/bg.jpg", display.contentWidth, display.contentHeight)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    bg.alpha = 0.8

    -- Settings Panel (center content)
    local panel = display.newRoundedRect(
        sceneGroup,
        display.contentCenterX,
        display.contentCenterY,
        display.contentWidth - 80,
        display.contentHeight - 200,
        22
    )
    panel:setFillColor(0.1, 0.1, 0.2, 0.95)
    panel.strokeWidth = 3
    panel:setStrokeColor(0.7, 0.7, 1)

    local title = display.newText({
        parent = sceneGroup,
        text = "SETTINGS",
        x = display.contentCenterX,
        y = display.contentCenterY - 160,
        font = native.systemFontBold,
        fontSize = 36
    })
    title:setFillColor(0.4, 1, 0.7)

    local infoText = display.newText({
        parent = sceneGroup,
        text = "Choose Skin and Timer below",
        x = display.contentCenterX,
        y = display.contentCenterY - 120,
        font = native.systemFont,
        fontSize = 20
    })
    infoText:setFillColor(1, 1, 1)

    -- Skin dropdown style control
    local skinOptions = require("scene.skins").getOptions()
    local currentSkinIndex = 1
    local selectedKey = require("scene.skins").getSelectedKey()
    for i = 1, #skinOptions do
        if skinOptions[i].key == selectedKey then
            currentSkinIndex = i
            break
        end
    end

    local skinLabel = display.newText({
        parent = sceneGroup,
        text = "Skin: " .. skinOptions[currentSkinIndex].name,
        x = display.contentCenterX,
        y = display.contentCenterY - 40,
        font = native.systemFontBold,
        fontSize = 24
    })
    skinLabel:setFillColor(1, 1, 0)

    local function updateSkin(increment)
        currentSkinIndex = currentSkinIndex + increment
        if currentSkinIndex < 1 then currentSkinIndex = #skinOptions end
        if currentSkinIndex > #skinOptions then currentSkinIndex = 1 end
        local key = skinOptions[currentSkinIndex].key
        require("scene.skins").setSelected(key)
        skinLabel.text = "Skin: " .. skinOptions[currentSkinIndex].name
    end

    local leftSkin = display.newText({ parent = sceneGroup, text = "<<", x = display.contentCenterX - 100, y = display.contentCenterY - 40, font = native.systemFontBold, fontSize = 26 })
    local rightSkin = display.newText({ parent = sceneGroup, text = ">>", x = display.contentCenterX + 100, y = display.contentCenterY - 40, font = native.systemFontBold, fontSize = 26 })
    leftSkin:setFillColor(0.8, 0.8, 1); rightSkin:setFillColor(0.8, 0.8, 1)

    leftSkin:addEventListener("tap", function() updateSkin(-1); return true end)
    rightSkin:addEventListener("tap", function() updateSkin(1); return true end)

    -- Timer dropdown style control
    local timeOptions = {1,2,3,4,5,"none"}
    local currentTimeIndex = 1

    local timerLabel = display.newText({
        parent = sceneGroup,
        text = "Timer: " .. (timeOptions[currentTimeIndex] == "none" and "None" or timeOptions[currentTimeIndex] .. " min"),
        x = display.contentCenterX,
        y = display.contentCenterY + 10,
        font = native.systemFontBold,
        fontSize = 24
    })
    timerLabel:setFillColor(0.4, 1, 0.6)

    local function updateTimer(increment)
        currentTimeIndex = currentTimeIndex + increment
        if currentTimeIndex < 1 then currentTimeIndex = #timeOptions end
        if currentTimeIndex > #timeOptions then currentTimeIndex = 1 end
        timerLabel.text = "Timer: " .. (timeOptions[currentTimeIndex] == "none" and "None" or timeOptions[currentTimeIndex] .. " min")
    end

    local leftTime = display.newText({ parent = sceneGroup, text = "<<", x = display.contentCenterX - 100, y = display.contentCenterY + 10, font = native.systemFontBold, fontSize = 26 })
    local rightTime = display.newText({ parent = sceneGroup, text = ">>", x = display.contentCenterX + 100, y = display.contentCenterY + 10, font = native.systemFontBold, fontSize = 26 })
    leftTime:setFillColor(0.8, 0.8, 1); rightTime:setFillColor(0.8, 0.8, 1)

    leftTime:addEventListener("tap", function() updateTimer(-1); return true end)
    rightTime:addEventListener("tap", function() updateTimer(1); return true end)

    -- Save selection to composer params when leaving
    local function saveSettings()
        if timeOptions[currentTimeIndex] == "none" then
            composer.setVariable("selectedTime", nil)
        else
            composer.setVariable("selectedTime", timeOptions[currentTimeIndex] * 60)
        end
    end

    -- BACK BUTTON
    backBtn = display.newImageRect(sceneGroup, "images/backbtn.png", 120, 120)
    backBtn.x = display.contentCenterX - 80
    backBtn.y = display.contentCenterY + 120

    -- MUTE BUTTON
    muteBtn = display.newImageRect(sceneGroup, _G.isMuted and "images/unmute.png" or "images/mute.png", 120, 120)
    muteBtn.x = display.contentCenterX + 80
    muteBtn.y = display.contentCenterY + 120

    backBtn:addEventListener("tap", function()
        saveSettings()
        composer.hideOverlay("fade", 300)
        return true
    end)

    muteBtn:addEventListener("tap", function()
        _G.isMuted = not _G.isMuted

        if _G.isMuted then
            audio.setVolume(0.0)
            muteBtn.fill = { type = "image", filename = "images/unmute.png" }
        else
            audio.setVolume(1.0)
            muteBtn.fill = { type = "image", filename = "images/mute.png" }
        end

        return true
    end)
end

function scene:show(event)
    if event.phase == "did" then
        physics.pause()

        if _G.isMuted then
            audio.setVolume(0.0)
            muteBtn.fill = { type = "image", filename = "images/unmute.png" }
        else
            audio.setVolume(1.0)
            muteBtn.fill = { type = "image", filename = "images/mute.png" }
        end
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