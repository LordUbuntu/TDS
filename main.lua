-- Features
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
	-- player table
    pl = {  max_v = 10, dv = 30, kf = 0.5,
            dx = 0, dy = 0,
            x = 100, y = 100,
            w = 20, h = 50, }

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

    -- apply position
    pl.x = pl.x + pl.dx
    pl.y = pl.y + pl.dy

    -- cap speed
    pl.dx = pl.dx > pl.max_v and pl.max_v or pl.dx
    pl.dx = pl.dx < -pl.max_v and -pl.max_v or pl.dx
    pl.dy = pl.dy > pl.max_v and pl.max_v or pl.dy
    pl.dy = pl.dy < -pl.max_v and -pl.max_v or pl.dy

    -- apply friction
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
	love.graphics.rectangle("fill", pl.x, pl.y, pl.w, pl.h)

	mouse_x, mouse_y = love.mouse.getPosition()
	love.graphics.print("player: "..pl.x..", "..pl.y, 0, 0)
	love.graphics.print("dx: "..pl.dx..", dy: "..pl.dy, 0, 30)
	love.graphics.print("mouse: "..mouse_x..", "..mouse_y, 0, 45)
	love.graphics.line(pl.x - 10, pl.y - 25, mouse_x, mouse_y)
end





-- EVENTS --
function love.mousepressed(x, y, button)
	if button == 1 then	-- lmb click
        love.event.push("shoot", x, y)
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
