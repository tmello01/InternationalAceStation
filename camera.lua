camera = {}
camera.x = 0
camera.y = 0
camera.xvel = 0
camera.yvel = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0
camera.speed = 1500

function camera:set()
	love.graphics.push()
	love.graphics.rotate(-self.rotation)
	love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
	love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
	love.graphics.pop()
end

function camera:move(dx, dy)
	self.x = math.floor(self.x + (dx or 0))
	self.y = math.floor(self.y + (dy or 0))
end

function camera:rotate(dr)
	self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
	sx = sx or 1
	self.scaleX = self.scaleX * sx
	self.scaleY = self.scaleY * (sy or sx)
end

function camera:setPosition(x, y)
	self.x = x or self.x
	self.y = y or self.y
end

function camera:setScale(sx, sy)
	self.scaleX = sx or self.scaleX
	self.scaleY = sy or self.scaleY
end

function camera:boundries(dt)
	if char.x < display.width / 2 - (char.w/2) then
		camera.x = char.x - ((g.getWidth() / 2) - (char.w/2))
	end
	if char.x > display.width / 2 - (char.w/2) then
		camera.x = char.x - ((g.getWidth() / 2) - (char.w/2))
	end
	if char.y < display.height / 2 - (char.h/2) then
		camera.y = char.y - ((g.getHeight() / 2) - (char.h/2))
	end
	if char.y > display.height / 2 - (char.h/2) then
		camera.y = char.y - ((g.getHeight() / 2) - (char.h/2))
	end
end