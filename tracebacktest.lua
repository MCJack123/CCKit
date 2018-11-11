os.loadAPI("CCKit/CCLog.lua")
local logger = CCLog.CCLog("tracebacktest")
logger.shell = shell
CCLog.default.shell = shell
logger:open()

local function d()
    logger:traceback("Testing")
end

local function c()
    d()
end

local function b()
    c()
end

local function a()
    b()
end

a()
logger:close()
CCLog.default:close()