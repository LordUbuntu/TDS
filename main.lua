-- TODO
-- add enemies
-- add collision detection for bullets and enemies, and for enemies and player (none for player and bullet)
-- make enemies move towards player


-- XXX done
-- score is recorded and reported
-- improved gun kickback
-- gun spread for all weapons
-- removed shotgun, cooldowns, kickbacks, and bullet deviance




-- LOAD --
function love.load()
	-- player table
    pl = {  max_v = 10, dv = 30, kf = 0.5,
            dx = 0, dy = 0,
            x = 100, y = 100,
            w = 5, h = 5 }
    pl.sprite = love.graphics.newImage("assets/sprites/player.png")
    -- player score record
    score = 0
    high_score = tonumber(love.filesystem.read("score.txt"), 10)


	-- bullet table
	bullets = {}
end

-- UPDATE --
function love.update(dt)

    ------ HANDLE PLAYER MOTION ------
    -- apply motion
    if love.keyboard.isDown('d') then
        pl.dx = pl.dx + pl.dv * dt
    end
    if love.keyboard.isDown('a') then
        pl.dx = pl.dx - pl.dv * dt
    end
    if love.keyboard.isDown('w') then
        pl.dy = pl.dy - pl.dv * dt
    end
    if love.keyboard.isDown('s') then
        pl.dy = pl.dy + pl.dv * dt
    end

    -- stop player at window edge
    width, height = love.graphics.getDimensions()
    if pl.x - pl.w < 0 then
        pl.dx = 0
        pl.x = pl.x + pl.w
    end
    if pl.x + pl.w > width then
        pl.dx = 0
        pl.x = pl.x - pl.w
    end
    if pl.y - pl.h < 0 then
        pl.dy = 0
        pl.y = pl.y + pl.h
    end
    if pl.y + pl.h > height then
        pl.dy = 0
        pl.y = pl.y - pl.h
    end

    -- apply position
    pl.x = pl.x + pl.dx
    pl.y = pl.y + pl.dy

    -- cap speed
    pl.dx = pl.dx > pl.max_v and pl.max_v or pl.dx
    pl.dx = pl.dx < -pl.max_v and -pl.max_v or pl.dx
    pl.dy = pl.dy > pl.max_v and pl.max_v or pl.dy
    pl.dy = pl.dy < -pl.max_v and -pl.max_v or pl.dy

    -- apply friction proportional to vector
    local py = math.abs(pl.dy / (math.sqrt(pl.dx^2 + pl.dy^2)))
    local px = math.abs(pl.dx / (math.sqrt(pl.dx^2 + pl.dy^2)))

    if pl.dy > -pl.kf and pl.dy < pl.kf then
        pl.dy = 0
    elseif pl.dy < -pl.kf^2 then
        pl.dy = pl.dy + pl.kf^2 * py
    elseif pl.dy > pl.kf^2 then
        pl.dy = pl.dy - pl.kf^2 * py
    end

    if pl.dx > -pl.kf and pl.dx < pl.kf then
        pl.dx = 0
    elseif pl.dx < -pl.kf^2 then
        pl.dx = pl.dx + pl.kf^2 * px
    elseif pl.dx > pl.kf^2 then
        pl.dx = pl.dx - pl.kf^2 * px
    end 



    ----- HANDLE BULLET MOVEMENT -----
	for _, bullet in ipairs(bullets) do
		bullet.x = bullet.x + bullet.dx * dt
        bullet.y = bullet.y + bullet.dy * dt
	end
end

-- DRAW --
function love.draw()
	-- bullet
	for _, bullet in ipairs(bullets) do
        love.graphics.circle("fill", bullet.x, bullet.y, bullet.radius)
	end

	mouse_x, mouse_y = love.mouse.getPosition()

    local angle = math.atan2(mouse_y - pl.y, mouse_x - pl.x) + math.pi / 2
    love.graphics.draw(pl.sprite, pl.x, pl.y, angle, 1, 1, pl.w, pl.h)

    love.graphics.print(score, 0, 0)
    love.graphics.print(high_score, 0, 15)
end





-- EVENTS --
function love.mousepressed(x, y, button)
	if button == 1 then	-- lmb click
        love.event.push("shoot", x, y)
    end
end

function love.keypressed(key)
	if key == "escape" then
        if high_score < score then
            love.window.showMessageBox("High Score", "You got a new High Score: "..score, "info", false)
            love.filesystem.write("score.txt", score)
        end
		love.event.push("quit")
	end
end





-- HANDLERS --
function love.handlers.shoot(x, y)
    -- create bullet table
    local bullet = {
        radius = 2,
        x = 0, y = 0,
        dv = 1000, dx = 0, dy = 0,
    }

    -- set initial bullet position
    bullet.x = pl.x
    bullet.y = pl.y

    -- set bullet delta velocities
    local angle = math.atan2((y - bullet.y), (x - bullet.x))
    bullet.dx = bullet.dv * math.cos(angle)
    bullet.dy = bullet.dv * math.sin(angle)

    -- record bullet 
    table.insert(bullets, bullet)
end
