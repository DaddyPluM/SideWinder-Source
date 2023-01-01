function save(filename, _data)
    love.filesystem.write(filename..".JSON", _data)
end

function load(filename)
    if love.filesystem.getInfo(filename..".JSON") then
        highScore = tonumber((love.filesystem.read(filename..".JSON")))
        print(highScore)
    end
end