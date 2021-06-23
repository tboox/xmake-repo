import("core.package.package")
import("core.base.semver")

function main()
    local files = os.iorun("git diff --name-only HEAD^")
    for _, file in ipairs(files:split('\n'), string.trim) do
       if file:find("packages", 1, true) and path.filename(file) == "xmake.lua" then
           assert(file == file:lower(), "%s must be lower case!", file)
           local packagedir = path.directory(file)
           local packagename = path.filename(packagedir)
           local instance = package.load_from_repository(packagename, nil, packagedir, file)
           print(instance:plat())
           if instance and instance:script("install")
              and (instance.is_headeronly and not instance:is_headeronly()) then
               print(instance:name())
               local versions = instance:versions()
               table.sort(versions, function (a, b) return semver.compare(a, b) < 0 end)
               print(versions)
           end
       end
    end
end
