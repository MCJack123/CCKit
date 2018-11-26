if _G._PID == nil then error("CCKit is disabled") end
os.loadAPI("CCKit/CCKitGlobals.lua")
loadAPI("CCKernel")

local ptable = CCKernel.get_processes()
local ttable = {{"PID", "Name"}}
for k,v in pairs(ptable) do 
    if k == 0 then table.insert(ttable, 2, {tostring(k), CCKernel.basename(v.path)}) 
    else table.insert(ttable, {tostring(k), CCKernel.basename(v.path)}) end
end
textutils.tabulate(unpack(ttable))
