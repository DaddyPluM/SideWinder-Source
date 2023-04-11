--This is how we make buttons
local font = love.graphics.newFont(18)
function button(text, func, param, width, height)
    return{
        width = width or 100,
        height = height or 50,
        func = func or function ()
            print("This button has no function attached")   --This appears in the console when you click a button that doesn't have a function
        end,
        param = param or nil,
        text = text or "No text",
        buttonX = 0,
        buttonY = 0,
        textX = 0,
        textY = 0,

        checkPressed = function(self, mouseX, mouseY)   --This checks if a button has been pressed
            if (mouseX  >=  self.buttonX and mouseX <  self.width + self.buttonX)
            and
            (mouseY  >=  self.buttonY and mouseY <  self.height + self.buttonY) then
				self.func(self.param)
			end
        end,

        draw = function(self, buttonX, buttonY)    --This displays the button on the y
            self.buttonX = buttonX or self.buttonX
            self.buttonY = buttonY or self.buttonY

            if textX then
                self.textX = textX + self.buttonX
            else
                self.textX = self. buttonX
            end

            if textY then
                self.textY = textY + self.buttonY
            else
                self.textY = self. buttonY
            end

            love.graphics.setColor(.4,.4,.4)
            love.graphics.rectangle(
                "fill",
                self.buttonX,
                self.buttonY,
                self.width,
                self.height
            )
            love.graphics.setColor(.7,.9,.7)
			love.graphics.printf(text, font, buttonX, buttonY - 1, width, "center")

        end
    }
end

return button