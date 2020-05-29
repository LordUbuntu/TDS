-- TODO
-- merge branches and archive repo

-- changes => polished source code and added final features
-- "updated conf.lua and main.lua"
-- set enemy spawn radius to the hypotenuse of first screens width and height
-- removed dead code
-- renamed variables
-- added bullet and enemy timeout to improve performance and experience
-- added item drops and powerups
-- changed movement patterns to be linear
-- made love.update more concise
-- added pause feature (press p to pause the game)
-- documented code
-- no config files added, chiken and egg problem
-- cleaned up code



-- MAIN GAME LOOP
function love.load()
    -- runtime variables
    paused = false

    -- color definitions
    terminal = {0, 255, 0, 250} -- green
    virus = {255, 0, 0, 255} -- red
    heal = {255, 0, 255, 255} -- magenta
    special = {0, 255, 255, 255} -- cyan

	-- bullet table
	bullets = {
        template = { -- default bullet template
            -- motion
            x = 0, y = 0,
            dv = 1000, dx = 0, dy = 0,
            -- state
            r = 2,
            power = 50, -- how much damange it deals
            timeout = 5, -- how many seconds before despawning
            color = terminal,
        }
    }

    -- enemy table
    enemies = {
        anger = 0, -- every 10 this resets to 0 and freq increases
        anger_threshold = 5, -- how angry enemies have to be to ++freq
        cooldown = 0, -- cooldown between enemy spawn events
        freq = 0.2, -- the rate of enemy spawns per second
        template = { -- default enemy template
            -- motion
            x = 0, y = 0,
            speed = 100, dx = 0, dy = 0,
            -- state
            hp = 100,
            power = 0.25, -- how much damage enemies deal per tick
            r = 12, color = virus,
            potential = 1, -- max seconds of persistent damage allowed
        }
    }

    -- powerups table
    powerups = {
        special = { -- object template for special attack powerups
            type = "special",
            x = 0, y = 0, r = 3,
            color = special,
        },
        heal = { -- object template for healing powerups
            type = "heal",
            x = 0, y = 0, r = 3,
            color = heal,
        },
        cooldown = 0, -- cooldown between drops
    }

    -- gun table
    gun = { 
       cooldown = 0, -- cooldown between shoot events
       freq = 1 / 32, -- rate of fire
       specials = 3, -- how many special attacks the player has
    }
    
	-- player table
    pl = {
        -- player motion
        speed = enemies.template.speed * 3,
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        -- player state
        max_hp = 100, hp = 100,
        r = 10, color = terminal,
    }

    -- player score keeping
    score = 0
    if not love.filesystem.getInfo("score.txt") then
        love.filesystem.write("score.txt", score)
    end
    high_score = tonumber(love.filesystem.read("score.txt"), 10)
end

function love.update(dt)
    -- skip love.update if game is paused
    if paused then
        return
    end
    
    -- handle player movement
    if love.keyboard.isDown('d') then
        pl.x = pl.x + pl.speed * dt
    end
    if love.keyboard.isDown('a') then
        pl.x = pl.x - pl.speed * dt
    end
    if love.keyboard.isDown('w') then
        pl.y = pl.y - pl.speed * dt
    end
    if love.keyboard.isDown('s') then
        pl.y = pl.y + pl.speed * dt
    end
    -- keep player in visible window boundaries
    local width, height = love.graphics.getDimensions()
    local buffer = 3
    if pl.x - pl.r * 2 < buffer then
        pl.x = pl.x + pl.r * 2
    end
    if pl.x + pl.r * 2 > width - buffer then
        pl.x = pl.x - pl.r * 2
    end
    if pl.y - pl.r * 2 < buffer then
        pl.y = pl.y + pl.r * 2
    end
    if pl.y + pl.r * 2 > height - buffer then
        pl.y = pl.y - pl.r * 2
    end

    -- handle machine gun behaviour
    if love.mouse.isDown(1) then
        -- shoot at gun.freq rate of fire while lmb is held down
        if gun.cooldown > 0 then
            gun.cooldown = gun.cooldown - 1 * dt
        else
            love.event.push("shoot", love.mouse.getX(), love.mouse.getY())
            gun.cooldown = gun.freq
        end
    end


    -- handle bullet movement and state
    for bullet_index, bullet in ipairs(bullets) do
        -- update bullet positions
		bullet.x = bullet.x + bullet.dx * dt
        bullet.y = bullet.y + bullet.dy * dt

        -- hurt enemy if bullet collides with them
        for enemy_index, enemy in ipairs(enemies) do
            if collision(bullet, enemy) then
                enemy.hp = enemy.hp - bullet.power
                table.remove(bullets, bullet_index)
            end
        end

        -- remove stray bullets that have timed out
        if bullet.timeout > 0 then
            bullet.timeout = bullet.timeout - 1 * dt
        else
            table.remove(bullets, bullet_index)
        end
    end

    -- handle enemy movement and state
    for index, enemy in ipairs(enemies) do
        -- direct enemy movement towards player
        local angle = math.atan2((pl.y - enemy.y), (pl.x - enemy.x))
        enemy.dx = enemy.speed * math.cos(angle)
        enemy.dy = enemy.speed * math.sin(angle)
        -- update enemy position based on current movement
        enemy.x = enemy.x + enemy.dx * dt
        enemy.y = enemy.y + enemy.dy * dt

        -- deal damage to player and enemy if they collide
        if collision(enemy, pl) then
            pl.hp = pl.hp - enemy.power
            enemy.hp = enemy.hp - enemy.power * 4
        end

        -- reap souls
        if enemy.hp < 0 then -- drop powerups and boost score
            -- 40% chance on each death to drop powerups 
            if math.random(0, 100) >= 70 then
                -- 5% chance for specials
                if math.random(0, 100) <= 5 then
                    love.event.push("drop", powerups.special, enemy.x, enemy.y)
                end
                -- 10% chance for heals
                if math.random(0, 100) >= 90 then
                    love.event.push("drop", powerups.heal, enemy.x, enemy.y)
                end
            end
            table.remove(enemies, index)
            score = score + 1
            enemies.anger = enemies.anger + 1
        end
        if pl.hp < 0 then -- end game if player dies
            love.event.push("game_over")
        end
    end

    -- apply powerups to player on pickup
    for index, powerup in ipairs(powerups) do
        if collision(pl, powerup) then
            if powerup.type == "special" then
                gun.specials = gun.specials + 1
            elseif powerup.type == "heal" then
                pl.hp = pl.hp < pl.max_hp and pl.hp + 10 or pl.hp
            end
            table.remove(powerups, index)
        end
    end

    -- spawn enemies
    if enemies.cooldown > 0 then
       -- counting down between spawn events
       enemies.cooldown = enemies.cooldown - enemies.freq * dt
    else
        -- not spawning them if there are currently too many
        if #enemies < 2^12 then
            love.event.push("spawn_enemy")
        end
        enemies.cooldown = 1
    end
    if enemies.anger >= enemies.anger_threshold then -- increase the frequency of spawn events
        enemies.freq = enemies.freq + 0.2
        enemies.anger = 0
    end
end

function love.draw()
    -- show if game is paused
    if paused then
        local width, height = love.graphics.getDimensions()
        love.graphics.setColor(virus)
        love.graphics.print("PAUSED", width - 50, 0)
    end

	-- draw bullets
	for _, bullet in ipairs(bullets) do
        love.graphics.setColor(bullet.color)
        love.graphics.circle("fill", bullet.x, bullet.y, bullet.r)
	end

    -- draw enemies
    for _, enemy in ipairs(enemies) do
        love.graphics.setColor(enemy.color)
        love.graphics.circle("line", enemy.x, enemy.y, enemy.r)
    end

    -- draw powerups
    for _, item in ipairs(powerups) do
        love.graphics.setColor(item.color)
        love.graphics.circle("fill", item.x, item.y, item.r)
    end

    -- draw player
    love.graphics.setColor(pl.color)
    love.graphics.circle("line", pl.x, pl.y, pl.r)

    -- draw hud
    red = (pl.max_hp - pl.hp) / pl.max_hp
    green = pl.hp / pl.max_hp
    love.graphics.setColor(red, green, 0, 255) -- health bar color
    love.graphics.rectangle("fill", 5, 5, pl.hp, 4) -- health bar
    love.graphics.setColor(terminal)
    love.graphics.print("score: "..score, 5, 15)
    love.graphics.print("high score: "..high_score, 5, 30)
    love.graphics.print("specials: "..gun.specials, 5, 45)
end





-- HELPER FUNCTIONS --
--[[ collision
desc
  a collision detection function that detects when two circles overlap
takes
  entity1 : circular entity object
  entity2 : circular entity object
assumes
  entity1 and entity2 are both circles
]]--
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
    -- disable shooting while paused
    if paused then
        return
    end

    -- handle events
	if button == 1 then	-- lmb click
        love.event.push("shoot", x, y)
    end
    if button == 2 then -- rmb click
        love.event.push("special")
    end
end

function love.keypressed(key)
    if key == "p" then -- pause game
        paused = not paused
    end
	if key == "escape" then -- end game
        love.event.push("game_over")
	end
end





-- EVENT HANDLERS --
--[[ shoot
desc
  a love event handler that creates a bullet entity object with an initial
  position and speed corresponding to the cartesian vector derived from the
  difference between the player and mouse position on the screen.
takes
  x : the x pos of the mouse on the screen
  y : the y pos of the mouse on the screen
--]]
function love.handlers.shoot(x, y)
    -- create local bullet using template
    local bullet = {}
    i, v = next(bullets.template, nil)
    while i do
        bullet[i] = v
        i, v = next(bullets.template, i)
    end

    -- set initial position where player is
    bullet.x = pl.x
    bullet.y = pl.y

    -- set initial deltas
    local angle = math.atan2((y - bullet.y), (x - bullet.x))
    bullet.dx = bullet.dv * math.cos(angle)
    bullet.dy = bullet.dv * math.sin(angle)

    -- record bullet 
    table.insert(bullets, bullet)
end

--[[ special
desc
  a love event handler that creates a shockwave of bullets going 
  out radially from the player 360deg around them.
--]]
function love.handlers.special()
    if gun.specials <= 0 then
        return
    end

    local angle = 0
    while angle < 2 * math.pi do
        -- create local bullet using template
        local bullet = {}
        i, v = next(bullets.template, nil)
        while i do
            bullet[i] = v
            i, v = next(bullets.template, i)
        end
        bullet.color = special -- set color to special color

        -- set initial position where player is
        bullet.x = pl.x
        bullet.y = pl.y

        -- set initial deltas
        bullet.dx = bullet.dv * math.cos(angle)
        bullet.dy = bullet.dv * math.sin(angle)

        -- record bullet 
        table.insert(bullets, bullet)

        -- increase angle by 1 degree in radians
        angle = angle + 0.0174533
    end

    gun.specials = gun.specials - 1
end

--[[ drop
desc
  a love event handler that places an item on the ground at a given location.
takes
  item_template : a table template/object describing the item
  x : the x position to place the item
  y : the y position to place the item
--]]
function love.handlers.drop(item_template, x, y)
    -- create local item using template
    local item = {}
    i, v = next(item_template, nil)
    while i do
        item[i] = v
        i, v = next(item_template, i)
    end

    -- set item position
    item.x = x
    item.y = y

    -- add it to powerups table
    table.insert(powerups, item)

    -- reduce probability of pickup for simultaneous kills temporarily
    powerups.cooldown = 1
end

--[[ spawn_enemy
desc
  a love event handler that spawns an enemy at a random angle outside the
  computer window at a radius equal to half the diagonal of said window.
--]]
function love.handlers.spawn_enemy()
    -- create local enemy using template
    local enemy = {}
    i, v = next(enemies.template, nil)
    while i do
        enemy[i] = v
        i, v = next(enemies.template, i)
    end

    -- spawn the enemy outside the screen at a random angle from an
    --      an origin at the centre of said window
    local width, height = love.window.getDesktopDimensions(1)
    local origin = { 
        x = width / 2,
        y = height / 2,
    }
    local spawn = { -- out from such at a given radius and random angle
        r = math.sqrt(width^2 + height^2),
        theta = 2*math.pi * math.random(),
    }
    enemy.x = origin.x + (spawn.r * math.cos(spawn.theta))
    enemy.y = origin.y + (spawn.r * math.sin(spawn.theta))

    -- add enemy to the horde
    table.insert(enemies, enemy)
end

--[[ game_over
desc
  a love event handler that does final checks and then quits the game.
--]]
function love.handlers.game_over()
    -- set new high score if attained
    if high_score < score then
        love.window.showMessageBox("High Score", "You got a new High Score: "..score, "info", true)
        love.filesystem.write("score.txt", score)
    end
    -- quit game
    love.window.showMessageBox("Game Over", "You managed to survive while defeating "..score.." enemies!", "info", true)
    love.event.push("quit")
end
