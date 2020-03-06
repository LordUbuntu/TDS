-- TODO improve offset of bullets and set them in radius around player
-- TODO ^^^ with line for player shoot too
-- TODO make specialized bullet types
-- TODO make specialized gun types
-- TODO set up mechanics to allow for bullet-gun combinaitons
-- TODO add player and projectile momentum
-- TODO delete bullets that go past window from table
-- XXX try having the bullets bounce against the screen boarders

-- LOAD --
function love.load()
	-- player properties
    player = { speed = 100, width = 20, height = 50 }
    player.x = 50
    player.y = 50

	-- bullet table
	bullets = {}

    -- other
    shotgun_splash = 123
end

-- UPDATE --
function love.update(dt)
	-- update player movement
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

    -- update bullet position
	for _, bullet in ipairs(bullets) do
		bullet.x = bullet.x + bullet.dx * dt
        bullet.y = bullet.y + bullet.dy * dt
	end
end

-- DRAW --
function love.draw()
	-- bullet
	for _, bullet in ipairs(bullets) do
        love.graphics.circle("line", bullet.x, bullet.y, bullet.radius)
	end

	-- player
	love.graphics.rectangle("fill", player.x-10, player.y-25, player.width, player.height)

	mouse_x, mouse_y = love.mouse.getPosition()
	love.graphics.print("player: "..player.x..", "..player.y, 0, 0)
	love.graphics.print("mouse: "..mouse_x..", "..mouse_y, 0, 15)
	love.graphics.line(player.x - 10, player.y - 25, mouse_x, mouse_y)
end





-- EVENTS --
function love.mousepressed(x, y, button, istouch)
	if button == 1 then	-- lmb click
        love.event.push("shoot", x, y)
	elseif button == 2 then -- rmb click
        for i = 1, 7 do
            love.event.push("shoot", 
                            x + math.random(-shotgun_splash, shotgun_splash), 
                            y + math.random(-shotgun_splash, shotgun_splash))
        end
    end
end

-- handle movement events?
function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	end
end

-- HANDLERS --
function love.handlers.shoot(x, y)
    -- TODO set bullet outside radius from player
    local bullet = { radius = 5, speed = 500 }
    bullet.x = player.x + 40 / 2
    bullet.y = player.y + 40 / 2
    -- determine Δy and Δx from atan
    local angle = math.atan2((y - bullet.y), (x - bullet.x))
    bullet.dx = bullet.speed * math.cos(angle)
    bullet.dy = bullet.speed * math.sin(angle)
    -- record bullet 
    table.insert(bullets, bullet)
end
