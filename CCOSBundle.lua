-- CCOSBundle.lua
-- CCKitOS
--
-- This file creates the CCOSBundle class, which allows applications to access
-- resources inside a special folder called a bundle. Each application run under
-- CCKitOS is automatically assigned a CCOSBundle that allows accessing the
-- app's bundle.
--
-- Copyright (c) 2018 JackMacWindows.

os.loadAPI("CCKit/CCKitGlobals.lua")
loadAPI("CCOSCrypto")
loadAPI("CCKernel")

CCOSBundle = {}

-- right now signing is only using plaintext sha256 hashes, encryption coming soon

local function signDir(path, key)
    local kkeys = {}
    local files = fs.list(path)
    for k,v in pairs(files) do
        if fs.isDir(path .. "/" .. v) then kkeys[v] = signDir(path .. "/" .. v, key)
        else
            local file = fs.open(path .. "/" .. v, "r")
            local hash = CCOSCrypto.sha256(file.readAll())
            file.close()
            kkeys[v] = CCOSCrypto.encrypt(hash, key)
        end
    end
    os.queueEvent("no_sleep")
	os.pullEvent()
    return kkeys
end

local hexDigits = "0123456789abcdef"

local function verifyDir(path, key, kkeys)
    local files = fs.list(path)
    --print(textutils.serialize(kkeys))
    for k,v in pairs(files) do if kkeys[v] == nil and v ~= "CodeSignature" then 
        print("Missing file: " .. path .. "/" .. v)
        return false
    end end
    for k,v in pairs(kkeys) do if k ~= "key" then
        if not fs.exists(path .. "/" .. k) then 
            print("Not found: " .. path .. "/" .. k)
            return false 
        end 
        if fs.isDir(path .. "/" .. k) then 
            if not verifyDir(path .. "/" .. k, key, v) then return false end
        else
            local file = fs.open(path .. "/" .. k, "r")
            local hash = CCOSCrypto.sha256(file.readAll())
            file.close()
            if hash ~= CCOSCrypto.decrypt(v, key) then 
                print(path .. "/" .. k)
                return false 
            end
        end
    end end
    os.queueEvent("no_sleep")
	os.pullEvent()
    return true
end

function CCOSBundle:new(path)
    local retval = {}
    fs.makeDir(path)
    retval.path = path
    retval.info = {}
    function retval:openResource(name)
        if not fs.exists(self.path .. "/Resources/" .. name) then return nil end
        return fs.open(self.path .. "/Resources/" .. name, "r")
    end
    function retval:loadAPI(name)
        if not fs.exists(self.path .. "/APIs/" .. name .. ".lua") then return false end
        return os.loadAPI(self.path .. "/APIs/" .. name .. ".lua")
    end
    function retval:executeProgram(name, env, ...)
        if not fs.exists(self.path .. "/Executables/" .. name .. ".lua") then return false end
        env = env or {}
        env._bundlePath = self.path
        CCKernel.exec(self.path .. "/Executables/" .. name .. ".lua", env, ...)
        return true
    end
    function retval:sign(keypair)
        local signature = signDir(self.path, keypair.private_key)
        signature.key = keypair.public_key
        local file = fs.open(self.path .. "/CodeSignature", "w")
        file.write(textutils.serialize(signature))
        file.close()
    end
    function retval:verify()
        if not fs.exists(self.path .. "/CodeSignature") then 
            print("No signature")
            return false 
        end
        local file = fs.open(self.path .. "/CodeSignature", "r")
        local contents = textutils.unserialize(file.readAll())
        file.close()
        return verifyDir(self.path, contents.key, contents)
    end
    function retval:saveInfo()
        local file = fs.open(self.path .. "/Info.table", "w")
        file.write(textutils.serialize(self.info))
        file.close()
    end
    if fs.exists(retval.path .. "/Info.table") then 
        local file = fs.open(retval.path .. "/Info.table", "r")
        retval.info = textutils.unserialize(file.readAll())
        file.close()
    end
    return retval
end

function CCOSBundle.current()
    if _G._bundlePath == nil then return nil end
    return CCOSBundle:new(_G._bundlePath)
end

setmetatable(CCOSBundle, {__call = CCOSBundle.new})