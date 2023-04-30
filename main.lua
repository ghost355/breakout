-- Breakout (classic 1986) Pavel Pavlov 2023

push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'
require 'Block'
require 'Wall'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
PADDLE_WIDTH = 12
PADDLE_HEIGHT = 5
BALL_SIZE = 4
WALL_WIDTH = 10

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 48)
    scoreFont = love.graphics.newFont('font.ttf', 16)
    love.graphics.setFont(smallFont)

    sounds = {
        paddle_hit = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        score = love.audio.newSource('sounds/score.wav', 'static'),
        wall_hit = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizeble = true,
        vsync = true,
        canvas = false
    })
    -- Paddle is placed in the middle of the bottom
    paddle = Paddle(VIRTUAL_WIDTH / 2 - PADDLE_WIDTH / 2, VIRTUAL_HEIGHT - PADDLE_HEIGHT - 5, PADDLE_WIDTH, PADDLE_HEIGHT)
    paddleLeft = Paddle(VIRTUAL_WIDTH / 2 - PADDLE_WIDTH, VIRTUAL_HEIGHT - PADDLE_HEIGHT - 5, PADDLE_WIDTH, PADDLE_HEIGHT)
    paddleRight = Paddle(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT - PADDLE_HEIGHT - 5, PADDLE_WIDTH,
        PADDLE_HEIGHT)

    -- Ball is placed in the middle of the Paddle on it
    ball = Ball(VIRTUAL_WIDTH / 2 - BALL_SIZE / 2, VIRTUAL_HEIGHT - PADDLE_HEIGHT - BALL_SIZE - 6, BALL_SIZE, BALL_SIZE)

    leftWall = Wall(0, 0, WALL_WIDTH, VIRTUAL_HEIGHT)
    rightWall = Wall(VIRTUAL_WIDTH - WALL_WIDTH, 0, WALL_WIDTH, VIRTUAL_HEIGHT)
    topWall = Wall(0, 0, VIRTUAL_WIDTH, 3)


    -- -- block wall
    -- blockWall = {}
    -- for i,v in pairs(blocks) do
    --     table.insert(Block(x,y,width,height,color))
    -- end
    life = 3
    score = 1000
    -- 'start' - on the start of the game; 'play' - when player play;
    -- 'serve' - after ball is lost, 'gameover' - when life < 0
    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'start' then
        ball.x = paddleLeft.x + paddleLeft.width - ball.width / 2
    elseif gameState == 'serve' then
        ball:reset()
        ball.x = paddleLeft.x + paddleLeft.width - ball.width / 2
    elseif gameState == 'play' then
        -- paddle collision
        if ball:collides(paddleLeft) then
            ball.y = VIRTUAL_HEIGHT - PADDLE_HEIGHT - BALL_SIZE - 5
            ball.dy = -ball.dy
            if ball.dx > 0 then
                ball.dx = -ball.dx + math.random(50)
            else
                ball.dx = ball.dx + math.random(50)
            end
        elseif ball:collides(paddleRight) then
            ball.y = VIRTUAL_HEIGHT - PADDLE_HEIGHT - BALL_SIZE - 5
            ball.dy = -ball.dy
            if ball.dx > 0 then
                ball.dx = ball.dx + math.random(50)
            else
                ball.dx = -ball.dx + math.random(50)
            end
        end

        -- top wall collision
        if ball:collides(topWall) then
            ball.y = WALL_WIDTH
            ball.dy = -ball.dy
            score = score + 1
            sounds.wall_hit:play()
        end
        -- left wall
        if ball:collides(leftWall) then
            ball.x = WALL_WIDTH
            ball.dx = -ball.dx
            sounds.wall_hit:play()
        end
        -- right wall
        if ball:collides(rightWall) then
            ball.x = VIRTUAL_WIDTH - WALL_WIDTH - BALL_SIZE
            ball.dx = -ball.dx
            sounds.wall_hit:play()
        end

        -- bottom
        if ball.y >= VIRTUAL_HEIGHT - BALL_SIZE then
            ball.y = VIRTUAL_HEIGHT
            sounds.score:play()
            life = life - 1
            if life == 0 then
                gameState = 'gameover'
            else
                gameState = 'serve'
            end
        end
    end

    -- KEYBOARD ACTIONS
    if gameState ~= 'pause' then
        if love.keyboard.isDown('left') then
            paddleLeft.dx = -PADDLE_SPEED
            paddleRight.dx = -PADDLE_SPEED
        elseif love.keyboard.isDown('right') then
            paddleLeft.dx = PADDLE_SPEED
            paddleRight.dx = PADDLE_SPEED
        else
            paddleLeft.dx, paddleRight.dx = 0, 0
        end
    elseif gameState == 'serve' then

    end
    -- UPDATE objs
    updatetObjects = { ball, paddleLeft, paddleRight }
    for _, obj in pairs(updatetObjects) do
        obj:update(dt)
    end
end

function gameInitial()
    ball:reset()
    life = 3
    score = 0
end

function love.keypressed(key)
    -- exit from game
    if key == 'escape' then
        love.event.quit()
        -- change game states with Enter key
        -- ..start -> serve -> play -0=> pause , -1-> serve , -2-> gameover -> start-..
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
            gameInitial()
        elseif gameState == 'pause' then
            gameState = 'play'
        elseif gameState == 'serve' or gameState == 'play' then
            gameState = 'pause'
        elseif gameState == 'gameover' then
            gameState = 'start'
        end
    elseif key == 'space' and gameState == 'serve' then
        ball.dy = -100
        ball.dx = math.random(-1, 1) == 1 and math.random(5, 40) or math.random(-40, -5)
        gameState = 'play'
    end
end

function love.draw()
    --show status info
    love.window.setTitle('Breakout:   FPS: ' .. love.timer.getFPS() .. '    ' .. string.upper(gameState))


    push:start()

    love.graphics.clear(0, 0, 0, 1)

    if gameState == 'start' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('BREAKOUT', 0, 50, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter for start game!', 0, 120, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'pause' then
        displayStatus()
        love.graphics.setFont(largeFont)
        love.graphics.printf('Pause', 0, 50, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'gameover' then
        love.graphics.printf('Game Over', 0, 50, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        displayStatus()
    elseif gameState == 'play' then
        displayStatus()
    end




    renderObjects = { leftWall, rightWall, topWall, ball, paddleLeft, paddleRight }
    for _, obj in pairs(renderObjects) do
        obj:render()
    end
    push:finish()
end

function displayStatus()
    love.graphics.setFont(scoreFont)
    love.graphics.printf(score, 0, 8, VIRTUAL_WIDTH - 13, 'right')
    love.graphics.printf('Live: ' .. life, 13, 8, VIRTUAL_WIDTH, 'left')
end
