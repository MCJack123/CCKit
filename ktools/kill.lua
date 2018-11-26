if _G._PID == nil then error("CCKit is disabled") end
os.loadAPI("CCKit/CCKitGlobals.lua")
loadAPI("CCKernel")

local args = {...}
if #args < 1 then error("Usage: kill <PID>") end
CCKernel.kill(tonumber(args[1]))