local composer = require("composer")
local scene = composer.newScene()
local physics = require("physics")
local skins = require("scene.skins")

-- VARIABLES
local balloon
local platform
local tapText
local gameOverimg
local resetBtn
local settingsbtn
local gameOverSound

local tapCount = 0
local gameOver = false
local gameStarted = false
local explosionSound
local finalScoreText
local finalHighScoreText
local highScore = 0
local scoreBg
local scoreGroup
local highScoreText
local backBtn

local selectedTime = 60
local timeLeft = 60
local gameTimer
local timerText
local timerStarted = false
local gameSceneGroup
local useTimer = false
local currentSkinKey = nil

local function createTimerDisplay(sceneGroup)

    if not useTimer then return end

    if timerText then
        timerText:removeSelf()
        timerText = nil
    end

    timeLeft = selectedTime
    timerStarted = false

    timerText = display.newText({
        parent = scoreGroup,
        text = string.format("%d:00", selectedTime / 60),
        x = display.contentCenterX,
        y = 90,
        font = native.systemFontBold,
        fontSize = 32
    })
    timerText:setFillColor(0.2, 1, 0.8)
end

local function createBalloon()
    if balloon then
        balloon:removeSelf()
        balloon = nil
    end

    balloon = display.newImageRect(gameSceneGroup, "images/" .. skins.getSelected(), 150, 150)
    balloon.x = display.contentCenterX
    balloon.y = display.contentCenterY
    physics.addBody(balloon, "kinematic", { radius = 70, bounce = 0 })
    balloon:addEventListener("tap", function()
        if pushBalloon then
            pushBalloon()
        end
        return true
    end)

    currentSkinKey = skins.getSelectedKey()
end

local function startGameTimer(sceneGroup)

    if not useTimer then return end

    if gameTimer then
        timer.cancel(gameTimer)
    end

    timeLeft = selectedTime
    timerStarted = true

    if timerText then
        timerText.text = string.format("%d:%02d", timeLeft / 60, timeLeft % 60)
    end

    gameTimer = timer.performWithDelay(1000, function()
        timeLeft = timeLeft - 1

        local minutes = math.floor(timeLeft / 60)
        local seconds = timeLeft % 60

        if timerText then
            timerText.text = string.format("%d:%02d", minutes, seconds)
        end

        if timeLeft <= 0 then
            timer.cancel(gameTimer)
            gameOver = true
        end
    end, 0)
end


-------------------------------------------------
-- PUSH BALLOON
-------------------------------------------------
local function pushBalloon()
    if gameOver or not balloon then return end

    if not gameStarted then
        gameStarted = true
        startGameTimer(gameSceneGroup)
        if balloon then
            physics.removeBody(balloon)
            physics.addBody(balloon, "dynamic", { radius=70, bounce=1 })
        end
    end

    if balloon then
        balloon:applyLinearImpulse(0, -0.75, balloon.x, balloon.y)
    end
    
    tapCount = tapCount + 1
    tapText.text = tapCount

    -- UPDATE HIGH SCORE LIVE
    if tapCount > highScore then
        highScore = tapCount
        highScoreText.text = "High: " .. highScore
    end

end

-------------------------------------------------
-- RESET GAME
-------------------------------------------------
local function resetGame()
    if gameTimer then
        timer.cancel(gameTimer)
        gameTimer = nil
    end
    
    tapCount = 0
    tapText.text = tapCount
    gameOver = false
    gameStarted = false
    timerStarted = false

    gameOverimg.isVisible = false
    resetBtn.isVisible = false

    -- Re-create balloon with selected skin and reset physics
    createBalloon()

    finalScoreText.isVisible = false
    finalHighScoreText.isVisible = false
    
    -- Reset timer display if timer is being used
    if useTimer then
        timeLeft = selectedTime
        if timerText then
            timerText.text = string.format("%d:00", selectedTime / 60)
        end
    end
    
    transition.to(scoreGroup, {time=300, alpha=1})
end




local function showExplosion(x, y)

    -- 🔊 Play sound FIRST (instant)
    audio.play(explosionSound)

    local boom = display.newImageRect("images/boom.png", 300, 300)
    boom.x = x
    boom.y = y

    boom.xScale = 0.2
    boom.yScale = 0.2
    boom.alpha = 1

    boom:toFront()

    transition.to(boom, {
        time = 250,   -- short and punchy
        xScale = 1.8,
        yScale = 1.8,
        alpha = 0,
        transition = easing.outQuad,
        onComplete = function()
            display.remove(boom)

            
        end
    })
end
-------------------------------------------------
-- CHECK POSITION
-------------------------------------------------
local function checkBalloonPosition()

    if gameOver then return end

    local balloonBottom = balloon.y + (balloon.height/2)
    local balloonTop    = balloon.y - (balloon.height/2)
    local balloonLeft   = balloon.x - (balloon.width/2)
    local balloonRight  = balloon.x + (balloon.width/2)

    local platformTop   = platform.y - (platform.height/2)
    local platformLeft  = platform.x - (platform.width/2)
    local platformRight = platform.x + (platform.width/2)

    

    if balloonTop <= 0 then
        gameOver = true
    end

    if balloonBottom >= platformTop and
       balloonRight > platformLeft and
       balloonLeft < platformRight then
        gameOver = true
    end

    -- Out-of-bounds checks (immediately detect when completely off-screen)
    if balloonBottom > display.contentHeight or
       balloonTop < 0 or
       balloonRight < 0 or
       balloonLeft > display.contentWidth then
        gameOver = true
    end

    if gameOver then

        -- Update high score
if tapCount > highScore then
    highScore = tapCount
end

        -- Update text values
finalScoreText.text = "Score: " .. tapCount
finalHighScoreText.text = "High Score: " .. highScore

-- Show them
finalScoreText.isVisible = true
finalHighScoreText.isVisible = true

-- Bring to front
finalScoreText:toFront()
finalHighScoreText:toFront()
gameOverimg:toFront()
resetBtn:toFront()
        
        gameOverimg.isVisible = true
        gameOverimg:toFront()

        showExplosion(balloon.x, balloon.y)

        timer.performWithDelay(200, function()

        gameOverimg.isVisible = true
        gameOverimg:toFront()

        balloon.isVisible = false

        audio.play(gameOverSound)  

        resetBtn.isVisible = true

        transition.to(scoreGroup, {time=300, alpha=0})

end)

        balloon:setLinearVelocity(0, 0)
        balloon.angularVelocity = 0

        physics.removeBody(balloon)
        physics.addBody(balloon, "static")
    end
end


-------------------------------------------------
-- SCENE CREATE
-------------------------------------------------
function scene:create(event)
    local sceneGroup = self.view
    gameSceneGroup = sceneGroup


    explosionSound = audio.loadSound("audio/explode.mp3")

    physics.start()
    physics.setGravity(0, 9.8)

    gameOverSound = audio.loadSound("audio/gameover.mp3")

    -- Background
    local background = display.newImageRect(sceneGroup, "images/bg.jpg", 480, 800)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Platform
    platform = display.newImageRect(sceneGroup, "images/platform.jpg", 500, 90)
    platform.x = display.contentCenterX
    platform.y = display.contentHeight - 25
    physics.addBody(platform, "static")

    -- Balloon
    createBalloon()

    -------------------------------------------------
-- SCORE UI GROUP
-------------------------------------------------
scoreGroup = display.newGroup()
sceneGroup:insert(scoreGroup)
self.view.scoreGroup = scoreGroup
    -------------------------------------------------
-- SCORE BACKGROUND
-------------------------------------------------
scoreBg = display.newRoundedRect(scoreGroup,
    display.contentCenterX,
    60,
    420,
    90,
    20
)
scoreBg:setFillColor(0, 0, 0, 0.6) -- semi transparent black

-------------------------------------------------
-- HIGH SCORE (LEFT)
-------------------------------------------------
highScoreText = display.newText({
    parent = scoreGroup,
    text = "High: 0",
    x = display.contentCenterX - 120,
    y = 60,
    font = native.systemFontBold,
    fontSize = 36
})
highScoreText:setFillColor(1, 0.8, 0) -- gold

-------------------------------------------------
-- CURRENT SCORE (RIGHT)
-------------------------------------------------
tapText = display.newText({
    parent = scoreGroup,
    text = "0",
    x = display.contentCenterX + 120,
    y = 60,
    font = native.systemFontBold,
    fontSize = 50
})
tapText:setFillColor(1, 1, 1)

    -- Game Over Image
    gameOverimg = display.newImageRect(sceneGroup, "images/gameover.png", 500, 200)
    gameOverimg.x = display.contentCenterX
    gameOverimg.y = display.contentCenterY
    gameOverimg.isVisible = false

    -- Final Score Text (hidden at start)
finalScoreText = display.newText(sceneGroup,
    "",
    display.contentCenterX,
    gameOverimg.y - 160,
    native.systemFontBold,
    40
)
finalScoreText.isVisible = false

-- Final High Score Text (hidden at start)
finalHighScoreText = display.newText(sceneGroup,
    "",
    display.contentCenterX,
    gameOverimg.y - 110,
    native.systemFontBold,
    35
)
finalHighScoreText.isVisible = false


    -- Reset Button
    resetBtn = display.newImageRect(sceneGroup, "images/rstbtn.png", 200, 120)
    resetBtn.x = display.contentCenterX
    resetBtn.y = 600
    resetBtn.isVisible = false


    -- Settings Button (Overlay)
    settingsbtn = display.newImageRect(sceneGroup, "images/settings.png", 120, 120)
    settingsbtn.x = display.contentWidth - 70
    settingsbtn.y = 140

     -- BACK BUTTON
    backBtn = display.newImageRect(sceneGroup, "images/backbtn.png", 120, 120)
    backBtn.x = 80
    backBtn.y = 140

    backBtn:addEventListener("tap", function()

        physics.stop()   -- pause physics while leaving game
        -- Avoid removing scenes and causing reload via dashboard.
        composer.gotoScene("scene.menu", {
            effect = "fade",
            time = 300
        })
        return true
    end)


    -------------------------------------------------
    -- LISTENERS
    -------------------------------------------------
    balloon:addEventListener("tap", pushBalloon)
    resetBtn:addEventListener("tap", resetGame)
    Runtime:addEventListener("enterFrame", checkBalloonPosition)

    settingsbtn:addEventListener("tap", function()
        composer.showOverlay("scene.settings", {
            isModal = true,
            effect = "fade",
            time = 300
        })
    end)
end

-------------------------------------------------
-- SCENE SHOW
-------------------------------------------------
function scene:show(event)
    if event.phase == "did" then
        -- Handle selected time from set2 scene
        if event.params and event.params.selectedTime then
            useTimer = true
            selectedTime = event.params.selectedTime
            timeLeft = selectedTime
        else
            useTimer = false
        end
        
        -- Ensure timer display is created (only if useTimer is true)
        if not timerText and useTimer and scoreGroup then
            createTimerDisplay(gameSceneGroup)
        end

        -- Update balloon skin in case it was changed in settings/set2
        if skins.getSelectedKey() ~= currentSkinKey then
            createBalloon()
        end
    end
end

-------------------------------------------------
-- PAUSE WHEN OVERLAY OPENS
-------------------------------------------------
function scene:pause(event)
    physics.pause()
end

-------------------------------------------------
-- RESUME WHEN OVERLAY CLOSES
-------------------------------------------------
function scene:resume(event)
    physics.start()
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("pause", scene)
scene:addEventListener("resume", scene)
return scene

