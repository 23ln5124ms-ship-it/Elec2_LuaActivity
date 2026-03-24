local composer = require("composer")
local skins = require("scene.skins")
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
        "CHOOSE SKIN",
        display.contentCenterX,
        60,
        native.systemFontBold,
        46)
    title:setFillColor(1,1,0.5)

    -- Skin dropdown UI for clean appearance and user-friendly control
    local dropdownGroup = display.newGroup()
    sceneGroup:insert(dropdownGroup)

    local dropdownBox = display.newRoundedRect(dropdownGroup,
        display.contentCenterX,
        115,
        display.contentWidth - 80,
        60,
        18
    )
    dropdownBox:setFillColor(0.1, 0.5, 0.9, 0.95)
    dropdownBox.strokeWidth = 2
    dropdownBox:setStrokeColor(1, 1, 1)

    local dropdownLabel = display.newText({
        parent = dropdownGroup,
        text = "Skin: " .. skins.getSelectedKey(),
        x = display.contentCenterX - 50,
        y = 150,
        font = native.systemFontBold,
        fontSize = 24
    })

    local dropdownArrow = display.newText({
        parent = dropdownGroup,
        text = "▼",
        x = display.contentCenterX + 170,
        y = 150,
        font = native.systemFontBold,
        fontSize = 22
    })

    -- Skin preview icon below dropdown
    local skinPreview = display.newImageRect(sceneGroup,
        "images/" .. skins.getSelected(),
        50,
        50
    )
    skinPreview.x = display.contentCenterX
    skinPreview.y = 200

    local optionsGroup = display.newGroup()
    sceneGroup:insert(optionsGroup)
    optionsGroup.isVisible = false

    -- Semi-transparent overlay for dropdown menu
    local dropdownOverlay = display.newRect(sceneGroup,
        display.contentCenterX,
        display.contentCenterY,
        display.contentWidth,
        display.contentHeight
    )
    dropdownOverlay:setFillColor(0, 0, 0, 0.3)
    dropdownOverlay.isVisible = false

    local function hideOptions()
        optionsGroup.isVisible = false
        dropdownOverlay.isVisible = false
        dropdownArrow.text = "▼"
    end

    dropdownOverlay:addEventListener("tap", hideOptions)

    local function showOptions()
        optionsGroup:removeSelf()
        optionsGroup = display.newGroup()
        sceneGroup:insert(optionsGroup)

        dropdownOverlay.isVisible = true
        dropdownArrow.text = "▲"

        local opts = skins.getOptions()
        local optionStartY = 250
        local optionHeight = 50
        local optionSpacing = 10

        for i = 1, #opts do
            local option = opts[i]
            local optionY = optionStartY + (i - 1) * (optionHeight + optionSpacing)
            local optionBG = display.newRoundedRect(optionsGroup,
                display.contentCenterX,
                optionY,
                display.contentWidth - 80,
                optionHeight,
                12
            )
            optionBG:setFillColor(0.08, 0.08, 0.12, 0.95)
            optionBG.strokeWidth = 2
            optionBG:setStrokeColor(0.7, 0.7, 1)

            local optionText = display.newText({
                parent = optionsGroup,
                text = option.name,
                x = display.contentCenterX - 60,
                y = optionY,
                font = native.systemFont,
                fontSize = 20
            })

            local optionIcon = display.newImageRect(optionsGroup,
                "images/" .. option.file,
                40,
                40
            )
            optionIcon.x = display.contentCenterX + 120
            optionIcon.y = optionY

            optionBG:addEventListener("tap", function()
                skins.setSelected(option.key)
                dropdownLabel.text = "Skin: " .. skins.getSelectedKey()
                skinPreview.fill = { type = "image", filename = "images/" .. skins.getSelected() }
                hideOptions()
            end)

            optionIcon:addEventListener("tap", function()
                skins.setSelected(option.key)
                dropdownLabel.text = "Skin: " .. skins.getSelectedKey()
                skinPreview.fill = { type = "image", filename = "images/" .. skins.getSelected() }
                hideOptions()
            end)

            optionText:addEventListener("tap", function()
                skins.setSelected(option.key)
                dropdownLabel.text = "Skin: " .. skins.getSelectedKey()
                skinPreview.fill = { type = "image", filename = "images/" .. skins.getSelected() }
                hideOptions()
            end)
        end

        optionsGroup.isVisible = true
    end

    dropdownBox:addEventListener("tap", function()
        if optionsGroup.isVisible then
            hideOptions()
        else
            showOptions()
        end
        return true
    end)

    -- Timer label, placed below skins area
    local skinCount = #skins.getOptions()
    local optionRowHeight = 50
    local optionRowSpacing = 10
    local timerY = 250 + skinCount * (optionRowHeight + optionRowSpacing) + 40

    local timerLabel = display.newText(sceneGroup,
        "SELECT TIMER",
        display.contentCenterX,
        timerY,
        native.systemFontBold,
        34)
    timerLabel:setFillColor(0.4, 1, 0.6)

    -- Back button to return to main menu
    local backBtn = display.newImageRect(sceneGroup, "images/backbtn.png", 120, 120)
    backBtn.x = 80
    backBtn.y = 80
    backBtn:addEventListener("tap", function()
        composer.gotoScene("scene.menu", {
            effect = "fade",
            time = 300
        })
        return true
    end)

    for i = 1, 5 do

        local btn = display.newRoundedRect(
            sceneGroup,
            display.contentCenterX,
            timerY + 50 + (i - 1) * 75,
            320,
            60,
            18
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