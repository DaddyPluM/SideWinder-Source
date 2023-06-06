function createParticle(x, y, speed, spread, number, size1, size2, lifetime, alpha, fade, image)
	local timer = 0
    local particle = love.graphics.newParticleSystem(image, 32)
	return{
	x = x,
	y = y,
	speed = speed,
	size1 = size1,
	size2 = size2 or size1,
	lifetime = lifetime,
	image = image,
	finished = false,
	fade = fade,
    alpha = alpha or 1,
    particle:setParticleLifetime(lifetime),
    particle:setSpeed(speed),
    particle:setSizes(size1, size2),
    particle:setSpread(spread),
    particle:setPosition(x, y),
    particle:emit(number),
	
	update = function(self, dt)
		particle:update(dt)
		timer = timer + dt
		if timer >= self.lifetime then
			self.finished = true
		end
		if fade == true then
			self.alpha = self.alpha - .015
		end
	end,
	
	draw = function(self)
		particle:setColors(1, 1, 1, self.alpha)
		love.graphics.draw(particle)
	end,
	}
end