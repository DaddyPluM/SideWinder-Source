local data = require "data"
local button = require "button"

local gameState = {
    menu = true,
    game = false,
    pause = false,
    over = false,
}

local buttons = {
    pauseState = {},
    menuState = {},
    overState = {}
}

local function startGame()
    if gameState["over"] then
        reset()
    end
    gameState["menu"] = false
    gameState["game"] = true
    gameState["pause"] = false
    gameState["over"] = false
end

local function startMenu()
    gameState["menu"] = true
    gameState["game"] = false
    gameState["pause"] = false
    gameState["over"] = false
end

local function pauseGame()
    gameState["menu"] = false
    gameState["game"] = false
    gameState["pause"] = true
    gameState["over"] = false
end


local function endGame()
    gameState["menu"] = false
    gameState["game"] = false
    gameState["pause"] = false
    gameState["over"] = true
end

function love.mousepressed(x, y, button, isTouch, presses)
    if button == 1 then
        if gameState["menu"] then 
            for buttonIndex in pairs(buttons.menuState) do
                buttons.menuState[buttonIndex]:checkPressed(x, y)
            end
        elseif gameState["pause"] then
            for buttonIndex in pairs(buttons.pauseState) do
                buttons.pauseState[buttonIndex]:checkPressed(x, y)
            end
        elseif gameState["over"] then
            for buttonIndex in pairs(buttons.overState) do
                buttons.overState[buttonIndex]:checkPressed(x, y)
            end
        end
    end
end

function love.load()
    buttons.menuState.playGame = button("Play", startGame, nil, 100, 20)
    buttons.menuState.exitGame = button("Exit", love.event.quit, nil, 100, 20)
    buttons.pauseState.mainMenu = button("Main Menu", startMenu, nil, 100, 20)
    buttons.overState.mainMenu = button("Main Menu", startMenu, nil, 120, 20)
    buttons.overState.restart = button("Restart", startGame , nil, 120, 20)
    pause = false
    score = 0
    highScore = 0
    if highScore ~= 0 then
        load("HIGH")
    end
    timer=0
    alpha = 1
    snakeAlive = true
    img = love.graphics.newImage("ball.png")
    ps = love.graphics.newParticleSystem(img,32)
    ps:setParticleLifetime(.5)
    ps:setSpeed(150)
    ps:setSizes(1,.5)
    ps:setSpread(6)
    --Window Dimensions
    winHeight = love.graphics.getHeight()
    winWidth= love.graphics.getWidth()
    gridXCount = winWidth/15
    gridYCount = winHeight/15
    local fHeight = math.floor(gridYCount)
    local fWidth = math.floor(gridXCount)
    local cHeight = math.ceil(gridYCount)
    local cWidth = math.ceil(gridXCount)
    if fWidth == cWidth then
        gridXCount = fWidth
    end
    if fHeight == cHeight then
        gridYCount = fHeight
    end
    if fWidth <= cWidth then
        gridXCount = fWidth
    end
    if fHeight <= cHeight then
        gridYCount = fHeight
    end
    foodPosition= {
        x = love.math.random(1, gridXCount),
        y = love.math.random(1, gridYCount)
    }
    directionQueue = {"right"}
    snakeSegments = {
        {x = 3, y = 1},
        {x = 2, y = 1},
        {x= 1, y = 1}
    }
    
    function moveFood()
        local possibleFoodPositions = {}

        for foodX = 1, gridXCount do
            for foodY = 1, gridYCount do
                local possible = true

                for segmentIndex, segment in ipairs(snakeSegments) do
                    if foodX == segment.x and foodY == segment.y then
                        possible = false
                    end
                end

                if possible then
                    table.insert(possibleFoodPositions, {x = foodX, y = foodY})
                end
            end
        end

        foodPosition = possibleFoodPositions[
            love.math.random(#possibleFoodPositions)
        ]
    end
    moveFood()

    function reset()
        snakeSegments = {
            {x = 3, y = 1},
            {x = 2, y = 1},
            {x= 1, y = 1}
        }
        directionQueue = {"right"}
        snakeAlive = true
        timer, score = 0, 0 
        moveFood()
    end
    reset()

    function resume()
        timer = 0
    end
end

function love.update(dt)
    ps:update(dt)
    timer = timer+dt
    full=ps:getCount()
    if snakeAlive then
        if timer >= .1  then 
            timer = 0 
            if full == 10 then
                alpha = alpha-.25
            else
                alpha = 1
            end
        local nextXPosition = snakeSegments[1].x
        local nextYPosition = snakeSegments[1].y
        local canMove = true

        if #directionQueue > 1 then
            table.remove(directionQueue,1)
        end

        if directionQueue[1] == "right" then nextXPosition = nextXPosition+1
            if nextXPosition > gridXCount then
                --[[ps:setPosition(nextXPosition*15,nextXPosition*15)
                ps:emit(5)]]
                nextXPosition = 1
                --[[ps:setPosition(nextXPosition*15,nextXPosition*15)
                ps:emit(5)]]
            end
        elseif directionQueue[1] == "left" then nextXPosition = nextXPosition-1
            if nextXPosition < 1 then
                nextXPosition = gridXCount
            end
        elseif directionQueue[1] == "up" then nextYPosition = nextYPosition-1
            if nextYPosition < 1 then
                nextYPosition = gridYCount
            end
        elseif directionQueue[1] == "down" then nextYPosition = nextYPosition+1
            if nextYPosition > gridYCount then
                nextYPosition = 1
            end
        end

        for segmentIndex, segment in ipairs(snakeSegments) do
            if segmentIndex ~= #snakeSegments
            and
            nextXPosition == segment.x
            and
            nextYPosition == segment.y then
                canMove = false
            end
        end

        if canMove then
            table.insert(snakeSegments, 1, {x = nextXPosition, y = nextYPosition}) 
            if snakeSegments[1].x == foodPosition.x and snakeSegments[1].y == foodPosition.y then
                ps:emit(10)
                moveFood()
                score = score + 1
            else
                table.remove(snakeSegments)
            end
            else
                snakeAlive = false

            end
        end
    elseif  timer >= 2 then
        endGame()
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0, .2, 0)
    if gameState["game"] then
        local cellSize = 15
        love.graphics.setColor(0,1,.5)
        love.graphics.print("score: "..score,winWidth/2-#"score")
        love.graphics.setColor(1, .3, 0)
        ps:setPosition((foodPosition.x-.5)*cellSize,(foodPosition.y-.5)*cellSize)
        ps:setColors(1,1,1,alpha)
        love.graphics.draw(ps)
        local function drawCell(x,y)
            love.graphics.rectangle(
                "fill",
                (x - 1) * cellSize,
                (y - 1) * cellSize,
                cellSize ,
                cellSize 
            )
        end
        local function drawCircle(x,y)
            love.graphics.circle(
                "fill",
                (x - 1) * cellSize + cellSize/2,
                (y - 1) * cellSize + cellSize/2,
                cellSize/1.5
            )
        end
        

        love.graphics.setColor(.28, .28, .28)
        --love.graphics.rectangle("fill", 0, 0, gridCountX*cellSize, gridCountY*cellSize)

        --Text

        for directionIndex, direction in ipairs(directionQueue) do
            love.graphics.setColor(1,1,1)
            love.graphics.print(
            "directionQueue[" .. directionIndex .. "]: "  .. direction, 15, 15 * directionIndex
            )
        end
        
        for segmentIndex, segment in ipairs(snakeSegments) do
            if snakeAlive then
            love.graphics.setColor(0, 1-(0+segmentIndex/40), 1)
            else
            love.graphics.setColor(timer,1+timer,32+timer)
            end
            if segmentIndex == 1 then
                drawCircle(segment.x , segment.y)
            else
                drawCell(segment.x, segment.y)
            end

        love.graphics.setColor(1, 0, 0)
        drawCell(foodPosition.x, foodPosition.y)
        end
        

function love.keypressed(key)
    if key == "escape" and timer >= 0 and gameState["game"] then
        pauseGame()
    elseif key == "escape" and timer ~= 0 then
        startGame()
        resume()
    elseif key == "escape" and gameState["menu"] then
        love.event.quit()
    end
    if key == "right" and directionQueue[#directionQueue] ~= "left" 
    or
    key == "left" and directionQueue[#directionQueue] ~= "right" 
    or
    key == "up" and directionQueue[#directionQueue] ~= "down"
    or
    key == "down" and directionQueue[#directionQueue] ~= "up" then
        table.insert(directionQueue, key)
end
        end
    elseif  gameState["menu"] then
        buttons.menuState.playGame:draw((winWidth/2)-50, (winHeight/2)-20,40,5)
        buttons.menuState.exitGame:draw((winWidth/2)-50, (winHeight/2)+10,40,5)
        reset()
    elseif gameState["pause"] then
        love.graphics.setColor(0,0,1)
        timer = math.sqrt(-4)
        love.graphics.print("PAUSE", winWidth/2-#"PAUSxE"*20, winHeight/2-200, 0, 5,5)
        buttons.pauseState.mainMenu:draw((winWidth/2)-50, (winHeight/2)-20,(50/2) - (#"Main Menu"/2),3)
    elseif gameState["over"] then
        love.graphics.setColor(0,0,1)
        if score > highScore then
            highScore = score
            save("HIGH", highScore)
        end
        timer = math.sqrt(-4)
        love.graphics.print("GAMEOVER", winWidth/2-#"GAMEOVER"*15, winHeight/2-250, 0, 4,4)
        love.graphics.setColor(0,1,0)
        love.graphics.print("HighScore: " .. highScore, 330, winHeight/2-150, 0, 2,2)
        buttons.overState.mainMenu:draw((winWidth/2)-50, (winHeight/2)-20,(60/2) - (#"Main Menu"/2),3)
        buttons.overState.restart:draw((winWidth/2)-50, (winHeight/2)+10,(60/2) - (#"Restart"/2),3)
    end
end
love.window.setTitle("SideWinder")