

local idInput = ""
local passwordInput = ""
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

local framePadding = PaddingTool.PadWindowPercent(mainScreenWidth, mainScreenHeight, 30, 12, 15, 15, 20, 20)

local frame = Main:addMovableFrame()
:setSize(framePadding[3], framePadding[4])
:setPosition(framePadding[1]+1, framePadding[2] )
:setBackground(colors.gray)

frame:addLabel()
:setSize("parent.w", 1)
:setBackground(colors.lightGray)
:setForeground(colors.black)
:setText("Sign In")

local loginPage = frame:addFrame()
:setSize("parent.w -1","parent.h -2")
:setBackground(colors.white)
:setPosition(1, 2)

local screenWidth, screenHeight = frame:getSize();

local padding = PaddingTool.PadWindowPercent(screenWidth, screenHeight, 100, 100, 10, 10, 33, 33)

local usrId = loginPage:addInput()
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

local usrPswd = loginPage:addInput()
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

local submitBtn = loginPage:addButton()
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
