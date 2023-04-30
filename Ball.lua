Ball = Class {}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dx = 0
    self.dy = 0
end

function Ball:collides(object)
    if self.x > object.x + object.width or object.x > self.x + self.width then
        return false
    end

    if self.y > object.y + object.height or object.y > self.y + self.height then
        return false
    end
    return true
end

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - BALL_SIZE / 2
    self.y = VIRTUAL_HEIGHT - PADDLE_HEIGHT - BALL_SIZE - 6
    self.dx = 0
    self.dy = 0
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
