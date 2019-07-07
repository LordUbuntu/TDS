--[[
TODO:
- Express player motion as the sum of y and x velocity vectors
- take y and x input independently and simultaneously
- limit player speed, and provide friction (also limit player position within window)
- implement bullets
- implement enemies
]]--

-- LOAD --
function love.load()
	width, height = love.graphics.getDimensions()
	text = "none"

	-- global properties
	speed = 1
	max_speed = 5
	friction = 0.5

	-- player properties
	player = {
		x = 50,
		y = 50,
		velocity = { x = 0, y = 0 }
	}

end

-- DRAW --
function love.draw()
	-- draw placeholder player
	love.graphics.rectangle("fill", player.x-5, player.y-5, 10, 10)
	love.graphics.line(player.x, player.y, mouse_x, mouse_y)

	-- print information
	love.graphics.print("player: "..player.x..", "..player.y, 0, 0)
	love.graphics.print("mouse: "..mouse_x..", "..mouse_y, 0, 10)

	love.graphics.print("key: "..text, 0, 30)
end

-- UPDATE --
function love.update(dt)
	mouse_x, mouse_y = love.mouse.getPosition()

	-- move player by velocity amount
	player.y = player.y + player.velocity.y
	player.x = player.x + player.velocity.x
	
	-- apply friction to player motion
	if player.velocity.y > 0 then
		player.velocity.y = player.velocity.y - friction
	elseif player.velocity.y < 0 then
		player.velocity.y = player.velocity.y + friction
	elseif player.velocity.x > 0 then
		player.velocity.x = player.velocity.x - friction
	elseif player.velocity.x < 0 then
		player.velocity.x = player.velocity.x + friction
	end

	-- FIXME momvement is wonky, figure out x and y vector motion
	if love.keyboard.isDown('w') then
		player.velocity.y = player.velocity.y - speed
	end
	if love.keyboard.isDown('s') then
		player.velocity.y = player.velocity.y + speed 
	end
	if love.keyboard.isDown('a') then
		player.velocity.x = player.velocity.x - speed
	end
	if love.keyboard.isDown('d') then
		player.velocity.x = player.velocity.x + speed
	end


	-- TODO cap speed
	-- TODO boundry collision for window
end
