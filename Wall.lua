Wall = Class{}

function Wall:init(x,y,width,height,color)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.color = color or {1,1,1,1}
end

-- Wall is static object, it doesn't update in play, so update is empty
-- function Wall:update(dt)
-- end

function Wall:render()
    local r,g,b,a = love.graphics.getColor()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(r,g,b,a)
end