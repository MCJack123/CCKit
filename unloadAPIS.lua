for _,f in ipairs(fs.list(fs.getDir(shell.getRunningProgram()))) do if f:match("^CC%a+%.lua$") then package.loaded[f:match("^(CC%a+)%.lua$")] = nil end end
