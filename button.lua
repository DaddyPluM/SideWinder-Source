function button(text, func, param, width, height)
    return{
        width = width or 100,
        height = height or 50,
        func = func or function ()
            print("THis button has no function attached")
        end,
        param = param or nil,
        text = text or "No text",
        buttonX = 0,
        buttonY = 0,
        textX = 0,
        textY = 0,

        checkPressed = function(self, mouseX, mouseY)
            if (mouseX  >=  self.buttonX and mouseX <  self.width + self.buttonX)
            and
            (mouseY  >=  self.buttonY and mouseY <  self.height + self.buttonY) then
                if self.func then
                    self.func(self.param)
                else
                    self.func()
                end
            end
        end,

        draw = function(self, buttonX, buttonY, textX,textY)
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
         love.graphics.setColor(1,1,1)
         love.graphics.print(self.text, self.textX, self.textY)

        end
    }
end

return button