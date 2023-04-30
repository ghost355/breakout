Paddle = Class{}

function Paddle:init(x,y,width,height)
    self.x = x
    self.y = y 
    self.width = width
    self.height = height 
    self.dx = 0
end

function Paddle:update(dt)
    -- paddle must not move through the side walls
    self.x = self.x +self.dx * dt
    if self.dx < 0 then
        self.x = math.max(WALL_WIDTH, self.x)
    else
        self.x = math.min(VIRTUAL_WIDTH-WALL_WIDTH-self.width, self.x)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end