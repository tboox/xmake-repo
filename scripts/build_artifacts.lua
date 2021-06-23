
function main()

    -- get packages
    local packages = {}
    local files = os.iorun("git diff --name-only HEAD^")
    for _, file in ipairs(files:split('\n'), string.trim) do
       if file:find("packages", 1, true) and path.filename(file) == "xmake.lua" then
           assert(file == file:lower(), "%s must be lower case!", file)
           local package = path.filename(path.directory(file))
           table.insert(packages, package)
       end
    end

    if #packages == 0 then
        print("no testable packages on %s!", argv.plat or os.subhost())
        return
    end
    print(packages)
end
