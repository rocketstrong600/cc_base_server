return function(self)

    local idInput
    local passwordInput
    local url = "http://celtis.alcorlabs:35535/auth"

    local function sendUserData(user, password, url)

        local data = {
            user = user,
            pass = password
        }

        local jsonData = textutils.serializeJSON(data)

        local response, err = http.post(url, jsonData, { ["Content-Type"] = "application/json"})

        if not response then
            Basalt.debug("HTTP request failed: " .. (err or "unknown error"))
            return nil
        end

        if response then
            local body = response.readAll()
            response.close()
            local table = textutils.unserializeJSON(body).pages
            return table
        else
            Basalt.debug("Error: No response received.")
        end

    end

    local mainScreenWidth, mainScreenHeight = Main:getSize();

    local screenWidth, screenHeight = self:getSize();

    local padding = PaddingTool.PadWindowPercent(screenWidth, screenHeight, 100, 100, 10, 10, 33, 33)

    local usrId = self:addInput()
        :setInputType("text")
        :setDefaultText("Staff ID")
        :setInputLimit(10)
        :setPosition(padding[1], padding[2])
        :setSize(padding[3], 1)
        :setBackground(colors.black)
        :setForeground(colors.lightGray)
        :onChange(function(text)
        idInput = text.getValue()
    end)

    local usrPswd = self:addInput()
        :setInputType("password")
        :setDefaultText("Password")
        :setInputLimit(10)
        :setPosition (padding[1],  padding[2] + 2)
        :setSize(padding[3], 1)
        :setBackground(colors.black)
        :setForeground(colors.lightGray)
        :onChange(function(text)
        passwordInput = text.getValue()
    end)

    local submitBtn = self:addButton()
        :setText("submit")
        :setSize(padding[3], 1)
        :setPosition(padding[1], padding[2] + 4)
        :setBackground(colors.lightGray)
        :setForeground(colors.black)
        :onClick(function()

        local result = sendUserData(idInput, passwordInput, url)

        if result then
            -- Process the result if the function returned successfully
            Basalt.debug(result)
            os.queueEvent("login_success", result)
        end
    end)
end