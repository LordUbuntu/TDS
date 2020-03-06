-- Features
-- TODO improve offset of bullets and set them in radius around player
-- TODO ^^^ with line for player shoot too
-- TODO make specialized bullet types
-- TODO make specialized gun types
-- TODO set up mechanics to allow for bullet-gun combinaitons
-- TODO add player and projectile momentum
-- TODO delete bullets that go past window from table
-- XXX try having the bullets bounce against the screen boarders

-- This Patch
-- TODO rename player.speed and player.decay
-- TODO make player redirection smoother (going in the opposite direction of ρ)









-- LOAD --
function love.load()
	-- player properties
    player = { speed = 50, width = 20, height = 50, x = 50, y = 50 }
    player.dx = 0
    player.dy = 0
    player.decay = 0.5
    player.maxspeed = 20

	-- bullet table
	bullets = {}
    bullets.decay = 0.25

    -- other
    shotgun_splash = 123
end

-- UPDATE --
function love.update(dt)
    -- cap speed
    if player.dy > player.maxspeed or player.dy < -player.maxspeed then
        player.dy = player.dy
    else
        -- otherwise accelerate in given direction
        if love.keyboard.isDown('w') then
            player.dy = player.dy - player.speed * dt
        end
        if love.keyboard.isDown('s') then
            player.dy = player.dy + player.speed * dt
        end
    end
    -- cap speed
    if player.dx > player.maxspeed or player.dx < -player.maxspeed then
        player.dx = player.dx
    else
        -- otherwise accelerate in given direction
        if love.keyboard.isDown('a') then
            player.dx = player.dx - player.speed * dt
        end
        if love.keyboard.isDown('d') then
            player.dx = player.dx + player.speed * dt
        end
    end

    -- decay player movement
    if player.dx > 0 then
        player.dx = player.dx - player.decay
    elseif player.dx < 0 then
        player.dx = player.dx + player.decay
    end

    if player.dy > 0 then
        player.dy = player.dy - player.decay
    elseif player.dy < 0 then
        player.dy = player.dy + player.decay
    end

    if player.dx > -player.decay^2 and player.dx < player.decay^2 then
        player.dx = 0
    end
    if player.dy > -player.decay^2 and player.dy < player.decay^2 then
        player.dy = 0
    end

    -- update player position
    player.x = player.x + player.dx
    player.y = player.y + player.dy 
    
    tempspeed = player.speed * dt

    -- wrap player position
    -- height, width = love.graphics.getDimensions()
    -- if player.y > height then
        -- player.y = 0
    -- elseif player.y < 0 then
        -- player.y = height
    -- end
    -- if player.x > width then
        -- player.x = 0
    -- elseif player.x < 0 then
        -- player.x = width
    -- end



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
	love.graphics.print("dx: "..player.dx..", dy: "..player.dy, 0, 15)
	love.graphics.print("speed: "..tempspeed, 0, 30)
	love.graphics.print("mouse: "..mouse_x..", "..mouse_y, 0, 45)
	love.graphics.line(player.x - 10, player.y - 25, mouse_x, mouse_y)
end





-- EVENTS --
function love.mousepressed(x, y, button)
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
    -- determine dy and dx from atan
    local angle = math.atan2((y - bullet.y), (x - bullet.x))
    bullet.dx = bullet.speed * math.cos(angle)
    bullet.dy = bullet.speed * math.sin(angle)
    -- record bullet 
    table.insert(bullets, bullet)
end
