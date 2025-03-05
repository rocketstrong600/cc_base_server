local basalt = require("/api/basalt")
local paddingTool = require("/api/paddingTool")
local pageLoader = require("/api/pageLoader")
local main = basalt.createFrame():setTheme({FrameBG = colors.gray, FrameFG = colors.white})

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

    local padding = paddingTool.PadWindowPercent(screenWidth, screenHeight, maxW, maxH, 15, 15, 20, 20)

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
            :execute(page)
            :onDone(function()
                f:remove()
            end)

    return f
end

local loginPage = pageLoader.requestPage("http://celtis.alcorlabs.com:35535/login")
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
        basalt.autoUpdate()
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
