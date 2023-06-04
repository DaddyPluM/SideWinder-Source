return {
    save = function (filename, _data)      --This saves the player's HighScore to a JSON file in a folder that you can acces by with the command Win+R then typing %appdata% in the dialog box and looking for a folder called "LOVE".
        love.filesystem.write(filename..".JSON", _data)
    end,

    load = function (filename)     --This loads the player's HighScore
        if love.filesystem.getInfo(filename..".JSON")  and love.filesystem.read(filename..".JSON") ~= nil then
            return tonumber((love.filesystem.read(filename..".JSON")))
        else
            return 0
        end
    end
}