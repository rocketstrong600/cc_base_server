--Basalt = require("/api/basalt")
--PaddingTool = require("/api/paddingTool")
--PageLoader = require("/api/pageLoader")

Main:setTheme({FrameBG = colors.gray, FrameFG = colors.white})

local tabs = {}
local screenWidth, screenHeight = Main:getSize();

local function createMovableWindow(page, title, maxW, maxH, paddingL, paddingR, paddingT, paddingB)

    local ok, pageFunc = pcall(page)
    if not ok then
        print("Failed to load page: " .. pageFunc)
        return
    end

    local framePadding = PaddingTool.PadWindowPercent(screenWidth, screenHeight, maxW, maxH, paddingL, paddingR, paddingT, paddingB)

    local frame = Main:addMovableFrame()
    :setSize(framePadding[3], framePadding[4])
    :setPosition(framePadding[1]+1, framePadding[2] )
    :setBackground(colors.gray)

    frame:addLabel()
    :setSize("parent.w", 1)
    :setBackground(colors.lightGray)
    :setForeground(colors.black)
    :setText(title)

    local iFrame = frame:addFrame()
    :setSize("parent.w -1","parent.h -2")
    :setBackground(colors.white)
    :setPosition(1, 2)

    pageFunc(iFrame)

end

local loginPage = createMovableWindow(PageLoader.requestPage("http://celtis.alcorlabs.com:35535/login"), "Sign In", 30, 14, 10, 10, 20, 20)

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
