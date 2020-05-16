-- TODO
-- make binaries and document build instructions
-- polish game source
-- improve code maintainability and readability
-- merge branches and archive repo



-- LOAD --
function love.load()
	-- player table
    pl = {  
        -- player motion
        max_v = 5, dv = 65, kf = 0.75,
        dx = 0, dy = 0,
        x = 200, y = 200,
        r = 10,

        -- player state
        hit = false,
        timeout = 0,
        max_hp = 100, hp = 100,
    }
    -- player score record
    score = 0
    if not love.filesystem.getInfo("score.txt") then
        love.filesystem.write("score.txt", score)
    end
    high_score = tonumber(love.filesystem.read("score.txt"), 10)


	-- bullet table
	bullets = {}
    gun = { 
        cooldown = 0,
        fire_rate = 1 / 16 -- number of shots per second
    }


    -- enemies table
    enemies = {
        score = 0, -- keeps track of every 10 points scored
        cooldown = 0,
        freq = 0.2, -- spawn rate
    }


    -- color definitions
    silver = {250, 250, 250, 255}
    terminal = {0, 255, 0, 250}
    virus = {255, 0, 0, 255}
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

    -- machine gun
    if love.mouse.isDown(1) then
        if gun.cooldown > 0 then
            gun.cooldown = gun.cooldown - 1 * dt
        else
            local mouse = {
                x = love.mouse.getX(),
                y = love.mouse.getY(),
            }
            love.event.push("shoot", mouse.x, mouse.y)
            gun.cooldown = gun.fire_rate
        end
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
                enemy.hit = true
                enemy.hp = enemy.hp - bullet.power
                table.remove(bullets, bullet_index)
            else
                enemy.hit = false
            end
        end
    end

    pl.timeout = pl.timeout - 1 * dt
    for index, enemy in ipairs(enemies) do
        -- update enemy movement
        local angle = math.atan2((pl.y - enemy.y), (pl.x - enemy.x))
        enemy.dx = enemy.dv * math.cos(angle)
        enemy.dy = enemy.dv * math.sin(angle)
        enemy.x = enemy.x + enemy.dx * dt
        enemy.y = enemy.y + enemy.dy * dt
        -- check if enemy collied with player
        if collision(enemy, pl) then
            pl.hp = pl.hp - (enemy.power - 1 * dt)
            pl.hit = true
        else
            pl.hit = false
        end
        -- reap souls
        if enemy.hp < 0 then
            score = score + 1
            enemies.score = enemies.score + 1
            table.remove(enemies, index)
        end
    end
    -- end game if player dies
    if pl.hp < 0 then
        love.event.push("game_over")
    end





    ----- SPAWN ENEMIES -----
    if enemies.cooldown > 0 then
       enemies.cooldown = enemies.cooldown - enemies.freq * dt
    else
        if #enemies < 2^12 then
            love.event.push("spawn_enemies")
        end
        enemies.cooldown = 1
    end
    -- double spawn rate every 5 points
    if enemies.score >= 5 then
        enemies.score = 0
        enemies.freq = enemies.freq + 0.2
    end
end

-- DRAW --
function love.draw()
	-- draw bullets
	for _, bullet in ipairs(bullets) do
        love.graphics.setColor(terminal)
        love.graphics.circle("fill", bullet.x, bullet.y, bullet.r)
	end

    -- draw enemies
    for _, enemy in ipairs(enemies) do
        love.graphics.setColor(virus)
        love.graphics.circle("line", enemy.x, enemy.y, enemy.r + enemy.hp / enemy.max_hp)
    end

    -- draw player
    love.graphics.setColor(terminal)
    love.graphics.circle("line", pl.x, pl.y, pl.r)

    -- draw hud
    -- reset color to opaque white
    love.graphics.setColor(255, 255, 255, 255)
    -- draw health bar with coloration
    greenp = pl.hp / pl.max_hp
    redp = (pl.max_hp - pl.hp) / pl.max_hp
    love.graphics.setColor(redp, greenp, 0, 255)
    love.graphics.rectangle("fill", 5, 5, pl.hp, 4) -- health bar
    -- show score
    love.graphics.setColor(terminal)
    love.graphics.print("score: "..score, 0, 15)
    love.graphics.print("high score: "..high_score, 0, 30)
end





-- HELPER FUNCTIONS --
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
        power = 50
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

function love.handlers.spawn_enemies()
    -- create enemy
    local enemy = {
        -- enemy motion
        x = 0, y = 0,
        dv = 100, dx = 0, dy = 0,
        -- enemy state
        hit = false,
        max_hp = 100, hp = 100, 
        power = 0.25,
        r = 10,
    }

    -- set enemy a certain radius outside screen
    local x, y = love.graphics.getDimensions()
    local spawn_radian = 2*math.pi * math.random()
    local offset = { x = x / 2, y = y / 2 }
    local spawn_radius = math.sqrt(offset.x^2 + offset.y^2)
    local spawn_x = spawn_radius * math.cos(spawn_radian)
    local spawn_y = spawn_radius * math.sin(spawn_radian)
    spawn_x = spawn_x + offset.x
    spawn_y = spawn_y + offset.y
    enemy.x = spawn_x
    enemy.y = spawn_y


    -- set initial position offscreen
    -- local median = {
        -- x = love.graphics.getWidth() / 2,
        -- y = love.graphics.getHeight() / 2
    -- }
    -- set enemy outside screen edge (more or less)
    -- enemy.x = median.x + (math.random(-1, 1) * median.x + enemy.r)
    -- enemy.y = median.y + (math.random(-1, 1) * median.y + enemy.r)

    -- set initial enemy movement towards player
    local angle = math.atan2((pl.y - enemy.y), (pl.x - enemy.x))
    enemy.dx = enemy.dv * math.cos(angle)
    enemy.dy = enemy.dv * math.sin(angle)

    -- add enemy to the collective
    table.insert(enemies, enemy)
end
