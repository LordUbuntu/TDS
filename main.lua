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
-- TODO make player redirection smoother (going in the opposite direction of ρ)



-- XXX think about how player momentum is implemented,
-- consider reimplementing with momentum being inherent in entities, acceleration
-- then should also be inherent.
-- dx = dx >= max_dv and max_dv or dx + dv * dt
-- dy = dy >= max_dv and max_dv or dx + dv * dt
--  decrement dx and dy relative to the proportion of the momentum in their
--  respective vector accounting for the kf of the entity.
--  implement intertia





-- LOAD --
function love.load()
	-- player table
    player = {  dv = 50, max_dv = 10, kf = 0.5,
                dx = 0, dy = 0, 
                x = 50, y = 50, 
                w = 20, h = 50, }

    -- constants
    -- g = 9.89
    -- initial player state
    -- pl = {  max_v = 10, m = 10, kf = 0.5, dv = 50,
            -- vx = 0, vy = 0,
            -- x = 50, y = 50,
            -- w = 20, h = 50, }
    -- initial player forces
    -- pl.F = pl.m * pl.dv
    -- pl.Fn = pl.m * g
    -- pl.Ff = pl.kf * pl.Fn

    -- notes:
    -- v = sqrt( vx^2 + vy^2 )
    -- if v >= max_v then v = max_v
    --      limit proportion of vx and vy by their proportion from v by max_v
    -- if 'a' or 'd' then vx +- F * dt and dp = F * dt
    -- if 'w' or 's' then vy +- F * dt and dp = F * dt
    -- dp = F * dt
    -- F = m * dv
    -- Ff = kf * Fn


	-- bullet table
	bullets = {}

    -- other
    shotgun_splash = 123
end

-- UPDATE --
function love.update(dt)
    -- cap speed for dy
    if player.dy > player.max_dv or player.dy < -player.max_dv then
        player.dy = player.dy
    else
        -- otherwise accelerate in given direction
        if love.keyboard.isDown('w') then
            player.dy = player.dy - player.dv * dt
        end
        if love.keyboard.isDown('s') then
            player.dy = player.dy + player.dv * dt
        end
    end
    -- cap speed for dx
    if player.dx > player.max_dv or player.dx < -player.max_dv then
        player.dx = player.dx
    else
        -- otherwise accelerate in given direction
        if love.keyboard.isDown('a') then
            player.dx = player.dx - player.dv * dt
        end
        if love.keyboard.isDown('d') then
            player.dx = player.dx + player.dv * dt
        end
    end

    -- decay player dx
    if player.dx > 0 then
        player.dx = player.dx - player.kf
    elseif player.dx < 0 then
        player.dx = player.dx + player.kf
    end
    -- decay player dy
    if player.dy > 0 then
        player.dy = player.dy - player.kf
    elseif player.dy < 0 then
        player.dy = player.dy + player.kf
    end
    -- stop if dx or dy is too small rel to kf
    if player.dx > -player.kf^2 and player.dx < player.kf^2 then
        player.dx = 0
    end
    if player.dy > -player.kf^2 and player.dy < player.kf^2 then
        player.dy = 0
    end

    -- update player position
    player.x = player.x + player.dx
    player.y = player.y + player.dy 
    
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
	love.graphics.rectangle("fill", player.x-10, player.y-25, player.w, player.h)

	mouse_x, mouse_y = love.mouse.getPosition()
	love.graphics.print("player: "..player.x..", "..player.y, 0, 0)
	love.graphics.print("dx: "..player.dx..", dy: "..player.dy, 0, 15)
	love.graphics.print("mouse: "..mouse_x..", "..mouse_y, 0, 30)
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

function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	end
end





-- HANDLERS --
function love.handlers.shoot(x, y)
    -- TODO set bullet outside radius from player
    local bullet = { radius = 5, speed = 250, kf = 1 }
    bullet.x = player.x + 40 / 2
    bullet.y = player.y + 40 / 2
    -- determine dy and dx from atan
    local angle = math.atan2((y - bullet.y), (x - bullet.x))
    bullet.dx = bullet.speed * math.cos(angle)
    bullet.dy = bullet.speed * math.sin(angle)
    -- record bullet 
    table.insert(bullets, bullet)
end
