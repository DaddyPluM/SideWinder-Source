local data = require "data"
local button = require "button"
require "particles"
local profile = require "profile"


local winWidth, winHeight = love.window.getMode()
local pause = false
local score = 0
local highScore = 0
local timer = 0
local snakeSegments = {}
local cellSize = 15
local snakeAlive = true
local alpha = 1
local gridXCount = 0
local gridYCount = 0
local directionQueue = {}
local img = love.graphics.newImage("ball.png")
local particles = {}
local foodPosition= {--Picking a random position in the game
    x = love.math.random(1, gridXCount),
    y = love.math.random(1, gridYCount)
}


local gameState = { -- The different states of the game
    menu = true,    --When the player opens the game, it will show the menu by default
    game = false,
    pause = false,
    over = false,
}

local buttons = {   -- A table containing tables which contain buttons for a specific game state
    pauseState = {},
    menuState = {},
    overState = {}
}

local function startGame()  --Begins the game
    if gameState["over"] then
        reset()
    end
    gameState["menu"] = false
    gameState["game"] = true
    gameState["pause"] = false
    gameState["over"] = false
end

local function startMenu()  --Opens the main menu
    reset()
    if gameState["over"] then
        reset()
    end
    gameState["menu"] = true
    gameState["game"] = false
    gameState["pause"] = false
    gameState["over"] = false
end

local function pauseGame()  --Pauses the game
    gameState["menu"] = false
    gameState["game"] = false
    gameState["pause"] = true
    gameState["over"] = false
end

local function endGame()    -- Ends the game (Game Over)
    gameState["menu"] = false
    gameState["game"] = false
    gameState["pause"] = false
    gameState["over"] = true
end

function love.mousepressed(x, y, button, isTouch, presses)  -- Checks which button was pressed and what state the game was in when the button was pressed
    if button == 1 then     --If the left mouse button is pressed
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

function love.keypressed(key)   --This function is called automatically whenever a key is pressed. It checks which key was pressed and performs a specific action
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
    if key == "space" then
      --moveFood()
    end
end

function love.load()
    -- Loading all the buttons that are going to be used in-game
    buttons.menuState.playGame = button("Play", startGame, nil, 100, 20)
    buttons.menuState.exitGame = button("Exit", love.event.quit, nil, 100, 20)
    buttons.pauseState.mainMenu = button("Main Menu", startMenu, nil, 120, 20)
    buttons.pauseState.resume = button("Resume", startGame, nil, 120, 20)
    buttons.overState.mainMenu = button("Main Menu", startGame, nil, 120, 20)
    buttons.overState.restart = button("Restart", startGame, nil, 120, 20)
    highScore = tonumber(data.load("HIGH"))       -- This loads the file that contains the players HighScore if they has played the game before
    snakeAlive = true

    --[[The window dimensions are divided by 15 because most of the objects in the game are 15 by 15 squares.
    Dividing it makes implementing some features easier]]
    gridXCount = winWidth/15
    gridYCount = winHeight/15
    --Calculations are done to round the divided numbers to their nearest whole number if they are not whole numbers
    gridXCount = math.floor(gridXCount + 0.5)
    gridYCount = math.floor(gridYCount + 0.5)

    --This makes the snakes move right when the game starts
    directionQueue = {"right"}

    --[[The table containing the positions of the snake's segments.
     The snake is made up of square and this tells the computer where to spawn them]]
    snakeSegments = {
        {x = 3, y = 1},
        {x = 2, y = 1},
        {x= 1, y = 1}
    }
    possibleFoodPositions = {}
    pfp = {}    --This table is used to cache the position of every cell in the game
    for foodX = 1, gridXCount do
        for foodY = 1, gridYCount do
            table.insert(pfp, {x = foodX, y = foodY})   --Store every possible space(cell) an object can occupy in a table
        end
    end
    
    function moveFood()     -- This spawns the food on a square that isn't already occupied
        table.move(pfp, 1, #pfp, 1, possibleFoodPositions)  --Reset the possibleFoodPositions table by copying the values from the pfp table into it
        for segmentIndex, segment in pairs(snakeSegments) do
            for i, v in pairs(possibleFoodPositions) do
                if v.x == segment.x or v.y == segment.y then
                    table.remove(possibleFoodPositions, i)
                end                
            end
        end
        foodPosition = possibleFoodPositions[
            love.math.random(#possibleFoodPositions)
        ]
        --print(table.maxn(possibleFoodPositions))
    end

    function reset()    -- Reset the value of some variables
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

    function resume()   -- Resumes the game after it has been paused
        timer = 0
    end
end

function love.update(dt)    -- Called every frame
    if #particles > 0 then      --If there are particles present in-game
        for i, v in pairs(particles) do
            if v.finished == true then      --If particle emiters have exceeded their lifetime
              table.remove(particles, i)    --Remove particle emitters that have exceeded their lifetime
            end
            v:update(dt)    --Update particles
        end
    end
    timer = timer + dt
    if gameState["game"] then
        if snakeAlive then  --This happens if the snake is still alive
            if timer >= .1  then --This allows us to control the game's update rate 
                timer = 0   --The timer will reset after some time has passed and when it does, the parts of the game that are in this if statement will update
                --These variables are used to move the snake
                local nextXPosition = snakeSegments[1].x
                local nextYPosition = snakeSegments[1].y
                local canMove = true

                if #directionQueue > 1 then
                    table.remove(directionQueue,1)
                end
                --This makes the snake wrap around the screen when it goes past an edge
                if directionQueue[1] == "right" then nextXPosition = nextXPosition+1
                    if nextXPosition > gridXCount then
                        nextXPosition = 1
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

                for segmentIndex, segment in ipairs(snakeSegments) do   --This checks if the head of the snake is going to collide with a part of it (segment) that is not the tail
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
                    if snakeSegments[1].x == foodPosition.x and snakeSegments[1].y == foodPosition.y then   --When the snake eats and apple
                        table.insert(particles, createParticle((foodPosition.x - .5) * cellSize, (foodPosition.y - .5) * cellSize, 150, 360, 10, 1, 2, .3, 1, true, img))
                        moveFood()
                        score = score + 1
                    else
                        table.remove(snakeSegments)  --When the snake doesn't eat an apple, it removes the last segment of the snake so it looks like the snake is moving and doesn't infinetly grow
                    end
                else
                    snakeAlive = false      --When the snake is no longer able to move
                 end
            end
            
        elseif  timer >= 2 then     --When the snake dies, the timer will no longer reset
            endGame()
        end
    end
end

function love.draw()    --This renders objects to the screen
    love.graphics.setBackgroundColor(0, .2, 0)
	local gameOverFont = love.graphics.newFont(36)
	local highScoreFont = love.graphics.newFont(23)
	local pauseFont = love.graphics.newFont(35)
    if gameState["game"] then   --This occurs when the game's state is "game", when the player can move the snake
        love.graphics.setColor(1, .3, 0)
        if #particles > 0 then  --If there are particles present in-game
            for i, v in pairs(particles) do
                v:draw()    --Draw particles
            end
        end
        local function drawCell(x, y)    --Calling this fuction will draw a square onto the screen
            love.graphics.rectangle(
                "fill",
                (x - 1) * cellSize,
                (y - 1) * cellSize,
                cellSize ,
                cellSize 
            )
        end
        local function drawCircle(x,y, radius)    --Calling this function will draw a circle onto the screen
            love.graphics.circle(
                "fill",
                (x - 1) * cellSize + cellSize/2,
                (y - 1) * cellSize + cellSize/2,
                radius
            )
        end
        


        --[[I used this for debugging, you can delete it if you want
        love.graphics.setColor(.28, .28, .28)
        for directionIndex, direction in ipairs(directionQueue) do
            love.graphics.setColor(1,1,1)
            love.graphics.print(
            "directionQueue[" .. directionIndex .. "]: "  .. direction, 15, 15 * directionIndex
        )
        end]]
        
        for segmentIndex, segment in pairs(snakeSegments) do   
            if snakeAlive then
                love.graphics.setColor(0, 1 - (0 + segmentIndex/40), 1)     --This gives the snake's body a gradient effect
            else
                love.graphics.setColor(timer, 1 + timer, 32 + timer)  --This changes the snakes's color to whit when it dies
            end
            if segmentIndex == 1 then
                drawCircle(segment.x , segment.y, cellSize/1.5)   --This draws the head of the snake
            else
                drawCell(segment.x, segment.y)   --This draws the rest of the snake
            end
        end
        love.graphics.setColor(1, 0, 0)     --This draws the food onto the screen
        drawCircle(foodPosition.x, foodPosition.y, cellSize/2.5)
        love.graphics.setColor(0,1,.5)
        love.graphics.printf("score: "..score, 0, 0, winWidth, "center")    --This displays the score at the top of the screen
        love.graphics.setColor(1, .3, 0)
    elseif  gameState["menu"] then  
        --This creates the buttons for the main menu
        buttons.menuState.playGame:draw((winWidth/2) - 50, (winHeight/2) - 20)
        buttons.menuState.exitGame:draw((winWidth/2) - 50, (winHeight/2) + 10)
    elseif gameState["pause"] then 
        love.graphics.setColor(0,0,1)
		love.graphics.printf("PAUSE", pauseFont, 0, (winHeight/2) - 200, winWidth, "center")
        buttons.pauseState.mainMenu:draw((winWidth/2) - 60, (winHeight/2) - 20)
        buttons.pauseState.resume:draw((winWidth/2) - 60, (winHeight/2) + 10)
    elseif gameState["over"] then
        love.graphics.setColor(0,0,1)
        if score > highScore then   --Saving the score if it is higher than the HighScore
            highScore = score
            data.save("HIGH", highScore)
        end
		love.graphics.printf("GAMEOVER", gameOverFont,0, winHeight/2 - 250, winWidth, "center")
        love.graphics.setColor(0,1,0)
		love.graphics.printf("HighScore: " .. highScore, highScoreFont,0, winHeight/2 - 150, winWidth, "center")
        buttons.overState.mainMenu:draw((winWidth/2) - 60, (winHeight/2) - 20)
        buttons.overState.restart:draw((winWidth/2) - 60, (winHeight/2) + 10)
    end
end
