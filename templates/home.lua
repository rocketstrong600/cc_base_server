--Basalt = require("/api/basalt")
--PaddingTool = require("/api/paddingTool")
--PageLoader = require("/api/pageLoader")

Main:setTheme({FrameBG = colors.gray, FrameFG = colors.white})

local tabs = {}
local screenWidth, screenHeight = Main:getSize();

local loginPage = PageLoader.requestPage("http://celtis.alcorlabs.com:35535/login")
if loginPage then
    --openProgram(loginPage, "Sign In", 30, 12)
    loginPage()
end

local function initEnv(tabs)
    
    local frames = {}
    
    local menubar = Main:addMenubar():setScrollable()
        :setSize("parent.w")
        :onChange(function(self, val)
        end)
        
    for k, tab in pairs(tabs) do
        local newFrame = Main:addFrame():setPosition(1,2):setSize("parent.w", "parent.h-1")
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
