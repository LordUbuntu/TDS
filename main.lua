-- TODO
-- spawn enemies just outside screen
-- make enemies move towards player
-- make binaries and document build instructions
-- polish game
-- improve code maintainability and readability
-- merge branches and archive repo


-- XXX DONE: feature --> collision detection and damage implemented
-- add health for player and enemies
-- add damage for bullets
-- add damage for enemies
-- remove bullet if it hits the enemy
-- remove enemy if their hp is low enough
-- give hit debuff after player hit
-- end game on player death
--



-- LOAD --
function love.load()
	-- player table
    pl = {  
        -- player motion
        max_v = 10, dv = 30, kf = 0.5,
        dx = 0, dy = 0,
        x = 100, y = 100,
        r = 10,

        -- player state
        hit = false,
        timeout = 0,
        max_hp = 100, hp = 100,
    }
    pl.sprite = love.graphics.newImage("assets/sprites/player.png")
    -- player score record
    score = 0
    if not love.filesystem.getInfo("score.txt") then
        love.filesystem.write("score.txt", score)
    end
    high_score = tonumber(love.filesystem.read("score.txt"), 10)


	-- bullet table
	bullets = {}


    -- enemies table
    enemies = {}
    enemy = {
        -- enemy motion
        x = 200,
        y = 50,
        r = 10,

        -- enemy state
        hit = false,
        max_hp = 100, hp = 100, 
        power = 10,
    }
    table.insert(enemies, enemy)
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
    if pl.x - pl.r * 2 < 0 + 5 then
        pl.dx = 0
        pl.x = pl.x + pl.r * 2
    end
    if pl.x + pl.r * 2 > width - 5 then
        pl.dx = 0
        pl.x = pl.x - pl.r * 2
    end
    if pl.y - pl.r * 2 < 0 + 5 then
        pl.dy = 0
        pl.y = pl.y + pl.r * 2
    end
    if pl.y + pl.r * 2 > height - 5 then
        pl.dy = 0
        pl.y = pl.y - pl.r * 2
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



    ----- HANDLE COLLISION DETECTION -----
    for _, bullet in ipairs(bullets) do
        for bullet_index, enemy in ipairs(enemies) do
            -- check if bullet collides with enemy
            if collision(bullet, enemy) then
                print("collision: bullet, enemy")
                enemy.hit = true
                enemy.hp = enemy.hp - bullet.power
                table.remove(bullets, bullet_index)
            else
                enemy.hit = false
            end
        end
    end
    for _, enemy in ipairs(enemies) do
        -- check if enemy collied with player
        if collision(enemy, pl) then
                print("collision: enemy, player")
                pl.hit = true
        else
                pl.hit = false
        end
    end
    if pl.hit then
        if pl.timeout <= 0 then
            pl.hp = pl.hp - (enemy.power - 1 * dt)
            pl.timeout = 1
        end
    end
    if pl.timeout > 0 then
        pl.timeout = pl.timeout - 1 * dt
    end

    ----- REAP SOULS -----
    for index, enemy in ipairs(enemies) do
        if enemy.hp < 0 then
            score = score + 1
            table.remove(enemies, index)
        end
    end
    if pl.hp < 0 then
        love.event.push("game_over")
    end
end

-- DRAW --
function love.draw()
	-- draw bullets
	for _, bullet in ipairs(bullets) do
        love.graphics.circle("fill", bullet.x, bullet.y, bullet.r)
	end

    -- draw enemies
    for _, enemy in ipairs(enemies) do
        redp = enemy.hp / enemy.max_hp
        greenp = (enemy.max_hp - enemy.hp) / enemy.max_hp
        love.graphics.setColor(redp, greenp, 0, 255)
        love.graphics.circle("line", enemy.x, enemy.y, enemy.r)
        love.graphics.setColor(255, 255, 255, 255)
    end

    -- draw player
    if pl.hit then
        love.graphics.setColor(255, 0, 0, 255)
    else
        love.graphics.setColor(255, 255, 255, 255)
    end
	mouse_x, mouse_y = love.mouse.getPosition()
    local angle = math.atan2(mouse_y - pl.y, mouse_x - pl.x) + math.pi / 2
    love.graphics.draw(pl.sprite, pl.x, pl.y, angle, 1, 1, pl.r, pl.r)
    love.graphics.reset()

    ----- PRINT HUD -----
    -- reset color to opaque white
    love.graphics.setColor(255, 255, 255, 255)
    -- draw health bar with coloration
    greenp = pl.hp / pl.max_hp
    redp = (pl.max_hp - pl.hp) / pl.max_hp
    love.graphics.setColor(redp, greenp, 0, 255)
    love.graphics.rectangle("fill", 5, 5, pl.hp, 4) -- health bar
    love.graphics.setColor(255, 255, 255, 255)
    -- show score
    love.graphics.print("score: "..score, 0, 15)
end

function collision(entity1, entity2)
    -- assumes all entities are spheres and checks if they overlap
    local dx = entity1.x - entity2.x
    local dy = entity1.y - entity2.y
    local distance = math.sqrt(dx^2 + dy^2)
    if distance < entity1.r + entity2.r then
        return true
    else
        return false
    end
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
        -- bullet movement
        r = 2,
        x = 0, y = 0,
        dv = 1000 / 2, dx = 0, dy = 0,
        
        -- bullet state
        power = 20
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

function love.handlers.game_over()
    -- check score
    if high_score < score then
        love.window.showMessageBox("High Score", "You got a new High Score: "..score, "info", false)
        love.filesystem.write("score.txt", score)
    end
    love.window.showMessageBox("Game Over", "You managed to survive while defeating "..score.." enemies. However, your time has come to an end", "info", false)
    love.event.push("quit")
end
