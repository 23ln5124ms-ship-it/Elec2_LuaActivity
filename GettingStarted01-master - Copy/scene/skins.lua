local skins = {}

local skinOptions = {
    default = "tnt.png",
    yellow = "yellow_tnt.png",
    purple = "purple_tnt.png",
    pink = "pink_tnt.png",
    blue = "blue_tnt.png",
}

local selectedKey = "default"

function skins.getOptions()
    return {
        { key = "default", name = "Default", file = skinOptions.default },
        { key = "yellow", name = "Yellow", file = skinOptions.yellow },
        { key = "purple", name = "Purple", file = skinOptions.purple },
        { key = "pink", name = "Pink", file = skinOptions.pink },
        { key = "blue", name = "Blue", file = skinOptions.blue },
    }
end

function skins.getSelected()
    return skinOptions[selectedKey] or skinOptions.default
end

function skins.getSelectedKey()
    return selectedKey
end

function skins.setSelected(key)
    if skinOptions[key] then
        selectedKey = key
        return true
    end
    return false
end

-- Create a skin selection UI block.
-- sceneGroup: group to insert UI into.
-- onComplete: callback(skinKey) when skin is changed.
function skins.createSelection(sceneGroup, onComplete)
    local skinOptionsList = skins.getOptions()

    local panel = display.newRoundedRect(sceneGroup,
        display.contentCenterX,
        260,
        display.contentWidth - 40,
        180,
        18
    )
    panel:setFillColor(0, 0, 0, 0.65)
    panel.strokeWidth = 3
    panel:setStrokeColor(0.9,0.9,1)

    local title = display.newText({
        parent = sceneGroup,
        text = "SKIN SELECT",
        x = display.contentCenterX,
        y = 215,
        font = native.systemFontBold,
        fontSize = 30
    })

    local infoLabel = display.newText({
        parent = sceneGroup,
        text = "Current: " .. skins.getSelectedKey(),
        x = display.contentCenterX,
        y = 245,
        font = native.systemFont,
        fontSize = 20
    })

    local buttonY = 310
    local totalCount = #skinOptionsList
    local spacing = (display.contentWidth - 80) / totalCount
    local selectedFrame

    local function updateSelectionFrame(button)
        if selectedFrame then selectedFrame:removeSelf() end
        selectedFrame = display.newRoundedRect(sceneGroup, button.x, button.y, button.width + 14, button.height + 14, 18)
        selectedFrame:setFillColor(0,0,0,0)
        selectedFrame.strokeWidth = 3
        selectedFrame:setStrokeColor(1, 0.8, 0)
        selectedFrame:toBack()
        button:toFront()
    end

    for i = 1, totalCount do
        local skin = skinOptionsList[i]
        local button = display.newImageRect(sceneGroup, "images/" .. skin.file, 70, 70)
        button.x = 40 + (i - 1) * spacing + 35
        button.y = buttonY

        local label = display.newText({
            parent = sceneGroup,
            text = skin.name,
            x = button.x,
            y = buttonY + 50,
            font = native.systemFont,
            fontSize = 16
        })

        if skin.key == skins.getSelectedKey() then
            updateSelectionFrame(button)
        end

        button:addEventListener("tap", function()
            if skins.setSelected(skin.key) then
                infoLabel.text = "Current: " .. skins.getSelectedKey()
                updateSelectionFrame(button)
                if onComplete then
                    onComplete(skin.key)
                end
            end
            return true
        end)
    end

    return {
        panel = panel,
        title = title,
        infoLabel = infoLabel,
        selectedFrame = selectedFrame
    }
end

return skins
