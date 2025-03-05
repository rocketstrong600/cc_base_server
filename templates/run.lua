Basalt = require("/api/basalt")
PaddingTool = require("/api/paddingTool")
PageLoader = require("/api/pageLoader")

Main = Basalt.createFrame()

local page = PageLoader.requestPage("http://celtis.alcorlabs.com:35535/home")
if page then
    page()
end

Basalt.autoUpdate()
