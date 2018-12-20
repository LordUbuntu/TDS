-- Filler text for the moment, saw it on a web page somewhere


function love.load()
    x, y, w, h = 20, 20, 60, 20
end

function love.update(dt)
    x = x + 1
    y = y * 1.005
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", x, y, w, h)
end