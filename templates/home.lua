--Basalt = require("/api/basalt")
--PaddingTool = require("/api/paddingTool")
--PageLoader = require("/api/pageLoader")
local main = Basalt.createFrame():setTheme({FrameBG = colors.gray, FrameFG = colors.white})

local tabs = {}
local screenWidth, screenHeight = term.getSize();

local function openProgram(page, title, maxW, maxH, x, y)

    local defaultWidthMax = 100
    local defaultHeightMax = 100

    if maxW == nil then
        maxW = defaultWidthMax
    end
    if maxH == nil then
        maxH = defaultHeightMax
    end

    local padding = PaddingTool.PadWindowPercent(screenWidth, screenHeight, maxW, maxH, 15, 15, 20, 20)

    local f = main:addMovableFrame()
            :setSize(padding[3], padding[4])
            :setPosition(x or padding[1]+1, y or padding[2] )

        f:addLabel()
            :setSize("parent.w", 1)
            :setBackground(colors.lightGray)
            :setForeground(colors.black)
            :setText(title or " Sign In")

        f:addProgram()
            :setSize("parent.w -1","parent.h -2")
            :setPosition(1, 2)
            :execute(function() ---TEMPORARY

                local main = Basalt.createFrame():setBackground(colors.white)

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

                local screenWidth, screenHeight = term.getSize();
                local padding = PaddingTool.PadWindowPercent(screenWidth, screenHeight, 100, 100, 10, 10, 33, 33)

                local usrId = main:addInput()
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

                local usrPswd = main:addInput()
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

                local submitBtn = main:addButton()
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

            end)
            :onDone(function()
                f:remove()
            end)
    return f
end

local loginPage = PageLoader.requestPage("http://celtis.alcorlabs.com:35535/login")
if loginPage then
    openProgram(loginPage, "Sign In", 30, 12)
end

local function initEnv(tabs)
    
    local frames = {}
    
    local menubar = main:addMenubar():setScrollable()
        :setSize("parent.w")
        :onChange(function(self, val)
        end)
        
    for k, tab in pairs(tabs) do
        local newFrame = main:addFrame():setPosition(1,2):setSize("parent.w", "parent.h-1")
        newFrame:addProgram():setSize("parent.w", "parent.h"):execute(tab.program)
        if (k ~= 1) then
            newFrame:hide()
        end
        table.insert(frames, newFrame)
        menubar:addItem(tab.name)
    end
    menubar:onChange(function(self, val) 
        for k, v in pairs(frames) do
            v:hide()
        end
        frames[self:getItemIndex()]:show()
    end)
end
    
parallel.waitForAny(
    function()
        Basalt.autoUpdate()
    end,
    function()
        while true do
            local event, receivedTabs = os.pullEvent("login_success")
            tabs = receivedTabs
            table.insert(tabs, 1, {name="Shell", page="rom/programs/shell.lua"})
            initEnv(tabs)
        end
    end
)
