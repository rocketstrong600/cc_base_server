Basalt = require("/api/basalt")
PaddingTool = require("/api/paddingTool")
PageLoader = require("/api/pageLoader")

-- Table of tasks to wait for in parallel
local tasks = {Basalt.autoUpdate}

-- Add a task to the table
function AddTask(func)
    table.insert(tasks, func)
end

-- Remove a task from the table
function RemoveTask(func)
    for i, f in ipairs(tasks) do
        if f == func then
            table.remove(tasks, i)
            break
        end
    end
end

Main = Basalt.createFrame()
--HostUrl = "http://celtis.alcorlabs.com:35535"
HostUrl = "http://localhost:35535"

local page = PageLoader.requestPage(HostUrl .. "/home")
if page then
    page()
end

-- Wait for all tasks to complete
for _, task in ipairs(tasks) do
    parallel.waitForAny(table.unpack(tasks))
end
