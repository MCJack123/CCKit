if _G._PID == nil then error("CCKit is disabled") end
local CCKitGlobals = require "CCKitGlobals"
local CCKernel = require "CCKernel"

local args = {...}
if #args < 1 then error("Usage: kill <PID>") end
CCKernel.kill(tonumber(args[1]))