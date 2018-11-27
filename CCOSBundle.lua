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
loadAPI("sha256")
loadAPI("rsa")

CCOSBundle = {}

-- right now signing is only using plaintext sha256 hashes, encryption coming soon

function signDir(path, key)
    local kkeys = {}
    local files = fs.list(path)
    for k,v in pairs(files) do
        if fs.isDir(path .. "/" .. v) then kkeys[v] = encryptDir(path .. "/" .. v, key)
        else
            local file = fs.open(path .. "/" .. v, "r")
            local hash = sha256.sha256(file.readAll())
            file.close()
            --local hashstr = ""
            --local i = 1
            --while i <= 64 do
            --    hashstr = hashstr .. string.char(tonumber(string.sub(hash, i, i+1), 16))
            --    i=i+2
            --end
            --print("Hash for " .. path .. "/" .. v .. ": " .. hash)
            --kkeys[v] = rsa.crypt(key, rsa.bytesToNumber(rsa.stringToBytes(hashstr), 256, 8))
            kkeys[v] = hash
        end
    end
    os.queueEvent("no_sleep")
	os.pullEvent()
    return kkeys
end

local hexDigits = "0123456789abcdef"

function verifyDir(path, key, kkeys)
    local files = fs.list(path)
    for k,v in pairs(files) do if kkeys[v] == nil then return false end end
    for k,v in pairs(kkeys) do 
        if not fs.exists(path .. "/" .. k) then return false end 
        if fs.isDir(path .. "/" .. k) then 
            if not verifyDir(path .. "/" .. k, key, v) then return false end
        else
            local file = fs.open(path .. "/" .. k, "r")
            local hash = sha256.sha256(file.readAll())
            file.close()
            --local decrypt = rsa.bytesToString(rsa.numberToBytes(rsa.crypt(key, v), 256, 8))
            --local hashstr = ""
            --local i = 1
            --while i <= 32 do
            --    local c = string.byte(string.sub(decrypt, i, i))
            --    local c1 = bit.band(bit.brshift(c, 4), 0x0F) + 1
            --    local c2 = bit.band(c, 0x0F) + 1
            --    hashstr = hashstr .. string.sub(hexDigits, c1, c1) .. string.sub(hexDigits, c2, c2)
            --    i=i+1
            --end
            --print("File: " .. hash)
            --print("Decrypted: " .. decrypt)
            --if hashstr ~= hash then return false end
            if hash ~= v then return false end
        end
    end
    os.queueEvent("no_sleep")
	os.pullEvent()
    return true
end

function CCOSBundle:new(path)
    local retval = {}
    fs.makeDir(path)
    retval.path = path
    retval.info = {}
    function retval:openResource(name, mode)
        if not fs.exists(self.path .. "/Resources/" .. name) then return nil end
        return fs.open(self.path .. "/Resources/" .. name, mode)
    end
    function retval:loadAPI(name)
        if not fs.exists(self.path .. "/APIs/" .. name .. ".lua") then return nil end
        return os.loadAPI(self.path .. "/APIs/" .. name .. ".lua")
    end
    function retval:executeProgram(name, env, ...)
        if not fs.exists(self.path .. "/Executables/" .. name .. ".lua") then return nil end
        os.run(env or _G, name, ...)
    end
    function retval:signBundle(pubkey)
        local file = fs.open(self.path .. "/CodeSignature", "w")
        file.write(textutils.serialize(signDir(self.path, pubkey)))
        file.close()
    end
    function retval:verifyBundle(prikey)
        if not fs.exists(self.path .. "/CodeSignature") then return false end
        local file = fs.open(self.path .. "/CodeSignature", "r")
        local contents = textutils.unserialize(file.readAll())
        file.close()
        return verifyDir(self.path, prikey, contents)
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
