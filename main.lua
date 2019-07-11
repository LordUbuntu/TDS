-- IDEA: instead of creating bullets, draw a shiny line for a moment and then do a quick calculation to determine if an enemy was in the line of fire
-- TODO if mouse is held down go full auto with cooldown between shots
-- TODO boundry collision for window
-- improve movement ??
-- TODO fix line to centre of character
-- TODO find a way to abstract player movement or switch between controll modes (keyboard+mouse VS joystick)
-- TODO collision detection (remove bullets from table on collision)


-- HANDLERS --

-- handle movement events?
-- handle shoot event?
-- etc?





-- ??? --
function make_bullet()
	bullet = { x = player.x-5, y = player.y-2.5, speed = 1500 }
	bullet.width = 10
	bullet.height = 5
	return bullet
end





-- LOAD --
function love.load()
	love.mouse.setGrabbed(false)

	-- player properties
	player = { x = 50, y = 50, speed = 100, shoot = function() end }
	player.width = 20
	player.height = 50

	-- bullet properties
	bullets = {}
end





-- DRAW --
function love.draw()
	for i, bullet in ipairs(bullets) do
		love.graphics.rectangle("line", bullet.x, bullet.y, bullet.width, bullet.height)
	end
	love.graphics.rectangle("fill", player.x-10, player.y-25, player.width, player.height)

	mouse_x, mouse_y = love.mouse.getPosition()
	love.graphics.print("player: "..player.x..", "..player.y, 0, 0)
	love.graphics.print("mouse: "..mouse_x..", "..mouse_y, 0, 10)
	love.graphics.line(player.x, player.y, mouse_x, mouse_y)
end





-- UPDATE --
function love.update(dt)

	-- player movement
	if love.keyboard.isDown('w') then
		player.y = player.y - player.speed * dt
	end
	if love.keyboard.isDown('s') then
		player.y = player.y + player.speed * dt
	end
	if love.keyboard.isDown('a') then
		player.x = player.x - player.speed * dt
	end
	if love.keyboard.isDown('d') then
		player.x = player.x + player.speed * dt
	end

	-- move bullets
	function oob(object)
		if object.x < 0 or object.x > love.graphics.getWidth() then
			return true
		elseif object.y < 0 or object.y > love.graphics.getHeight() then
			return true
		end
		return false
	end

	for i, bullet in ipairs(bullets) do
		bullet.x = bullet.x + bullet.speed * dt
		if oob(bullet) then
			table.remove(bullets, i)
		end
	end

end





-- ??? --

function love.mousepressed(x, y, button, istouch)
	if button == 1 then	-- lmb click
		-- determine direction
		-- set speed according to x and y velocity from sin and cos of mouse x,y relative to player
		-- set bullet to that area just outside player hitbox
		table.insert(bullets, make_bullet())
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	end
end