--[[
    * Define a class with `class.<name> {<contents>}`
        * This class will be available in the global namespace
    * Set inherited classes by adding `{extends = <class>}` or `{extends = {<classes...>}}` between the name and contents
    * To create a new object, call the class by name: `object = <name>()`
    * The initializer is named __init, and it will be called after creating the object
    * Metamethods are available as class methods or static methods
    * Static properties and methods may be defined in a static block inside the class definition
        * These are not synced to an object's namespace: when `class.a {static {foo = "bar"}}`, `a.foo` is nil
    * The super variable can be used to access methods/properties of the parent class(es)
    * Methods will automatically get self/super variables in their environment
        * Methods should not have a self argument in their definition
        * Do not call methods with the : operator, as self is already handled
    * Multiple inheritance follows the order given in the table
    * Initializer chaining is available by calling the name of the parent class in the initializer
        * `class.a {__init = function(name) self.name = name end}; class.b {__init = function(name, type) a(name); self.type = type end}`
]]
local metamethods = {__add=true, __sub=true, __mul=true, __div=true, __mod=true, __pow=true, __unm=true, __concat=true, __len=true, __eq=true, __lt=true, __le=true, __newindex=true, __call=true, __metatable=true}
local function tabset(t, k, v) t[k] = v; return t end
local function _wrap_method(obj, func, ...) return setfenv(func, tabset(tabset(getfenv(func), "self", obj), "super", setmetatable({}, {__index = getmetatable(obj).__index})))(...) end
local function defineClass(name, meta, def)
    local c, cmt = {__class = name}, {}
    if def.static then for k,v in pairs(def.static) do if metamethods[k] then cmt[k] = v else c[k] = v end end end
    def.static = nil
    if meta.extends then if meta.extends[1] then cmt.__index = function(self, name) for i,v in ipairs(meta.extends) do if v[name] then return v[name] end end end else cmt.__index = meta.extends end end
    local __init = def.__init
    def.__init = nil
    cmt.__call = function(self, ...)
        local omt, supers = {}, {}
        local obj = setmetatable({__class = name}, omt)
        if meta.extends and not __init then if meta.extends[1] then for i,v in ipairs(meta.extends) do supers[i] = v() end omt.__index = function(self, name) for i,v in ipairs(supers) do if v[name] then return v[name] end end end else omt.__index = meta.extends(...) end end
        for k,v in pairs(def) do if type(v) == "function" then obj[k] = function(...) _wrap_method(obj, v, ...) end elseif k ~= "__class" then obj[k] = v end if metamethods[k] then omt[k] = obj[k]; obj[k] = nil end end
        if __init then 
            local env = tabset(tabset(getfenv(__init), "self", obj), "super", setmetatable({}, {__index = omt.__index}))
            if meta.extends then if meta.extends[1] then omt.__index = function(self, name) if #supers < #meta.extends then for i,v in ipairs(meta.extends) do supers[i] = v() end end for i,v in ipairs(supers) do if v[name] then return v[name] end end end for i,v in ipairs(meta.extends) do env[v.__class] = function(...) supers[i] = v(...) end end else omt.__index = function(self, name) omt.__index = meta.extends(); return omt.__index[name] end env[meta.extends.__class] = function(...) omt.__index = meta.extends(...) end end end
            setfenv(__init, env)(...)
            if meta.extends and meta.extends[1] then omt.__index = function(self, name) for i,v in ipairs(supers) do if v[name] then return v[name] end end end end
        end
        return obj
    end
    --return tabset(_G, name, setmetatable(c, cmt))[name]
    return setmetatable(c, cmt)
end
return setmetatable({}, {__call = function(self, name) return function(tab) if tab.extends or tab.implements then return function(impl) return defineClass(name, tab, impl) end else return defineClass(name, {}, tab) end end end})