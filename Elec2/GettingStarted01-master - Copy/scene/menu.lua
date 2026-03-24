local composer = require("composer")
local scene = composer.newScene()

local bgMusic
local musicChannel
local welcomeimg
local quitbtn
local muteBtn
local set2btn

-- Make sure global mute exists
_G.isMuted = _G.isMuted or false

function scene:create(event)
    local sceneGroup = self.view

    -- Background
    local background = display.newImageRect(sceneGroup, "images/bg.jpg", 480, 800)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Welcome Image
    welcomeimg = display.newImageRect(sceneGroup, "images/welcomeimg.png", 500, 500)
    welcomeimg.x = display.contentCenterX
    welcomeimg.y = display.contentCenterY - 200

    -- Play Button
    local playbtn = display.newImageRect(sceneGroup, "images/playbtn.png", 300, 190)
    playbtn.x = display.contentCenterX
    playbtn.y = 650

    -- Quit Button
    quitbtn = display.newImageRect(sceneGroup, "images/quit.png", 300, 190)
    quitbtn.x = display.contentCenterX
    quitbtn.y = 550

    -- Quit Button
    set2btn = display.newImageRect(sceneGroup, "images/settings.png", 300, 190)
    set2btn.x = display.contentCenterX
    set2btn.y = 450


     -------------------------------------------------
    -- MUTE BUTTON
    -------------------------------------------------
    local muteImage = _G.isMuted and "images/unmute.png" or "images/mute.png"

    muteBtn = display.newImageRect(sceneGroup, muteImage, 150, 150)
    muteBtn.x = display.contentWidth - 90
    muteBtn.y = 750

    -------------------------------------------------
    -- LOAD AUDIO
    -------------------------------------------------
    bgMusic = audio.loadStream("audio/wilted.mp3")
    local clickSound = audio.loadSound("audio/stone.mp3")

    set2btn:addEventListener("tap", function()

    composer.gotoScene("scene.set2", {
        effect = "fade",
        time = 300
    })
    return true
end)

    -------------------------------------------------
    -- PLAY BUTTON
    -------------------------------------------------
    local function onPlayTap()

        audio.play(clickSound)

        transition.to(welcomeimg, {
            time = 400,
            alpha = 0
        })

        timer.performWithDelay(400, function()
            composer.gotoScene("scene.game", { effect="fade", time=500 })
        end)

        return true
    end

    playbtn:addEventListener("tap", onPlayTap)

    -------------------------------------------------
    -- QUIT BUTTON (keep inside game flow, avoid simulator dashboard)
    -------------------------------------------------
    local function onQuitTouch(event)
        if event.phase == "ended" then
            -- Commented out exit behavior to prevent returning to Solar2D dashboard / project picker.
            -- native.requestExit()
            -- Return to main menu when user wants quit-in-game.
            composer.gotoScene("scene.menu", { effect="fade", time=300 })
        end
        return true
    end

    quitbtn:addEventListener("touch", onQuitTouch)

    local function toggleMute()

    _G.isMuted = not _G.isMuted

    if _G.isMuted then
        audio.setVolume(0)
        muteBtn.fill = { type="image", filename="images/unmute.png" }
    else
        audio.setVolume(1)
        muteBtn.fill = { type="image", filename="images/mute.png" }
    end

    return true
    end

    muteBtn:addEventListener("tap", toggleMute)

end
    ----------------------------------------------

    -------------------------------------------------   
    -- SCENE SHOW
    -------------------------------------------------
    function scene:show(event)
    if event.phase == "did" then
        musicChannel = audio.play(bgMusic, { loops = -1 })

        -- Apply mute state when music starts
        if _G.isMuted then
            audio.setVolume(0)
        else
            audio.setVolume(1)
        end
    end
    end

    -------------------------------------------------
    -- SCENE HIDE
    -------------------------------------------------
    function scene:hide(event)
    if event.phase == "will" then
        audio.stop()
    end
    end

    scene:addEventListener("create", scene)
    scene:addEventListener("show", scene)
    scene:addEventListener("hide", scene)

    return scene    
