if _G._PID == nil then error("CCKit is disabled") end
os.loadAPI("CCKit/CCKitGlobals.lua")
loadAPI("CCKernel")

CCKernel.exec(...)