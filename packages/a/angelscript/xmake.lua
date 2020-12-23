package("angelscript")

    set_homepage("http://angelcode.com/angelscript/")
    set_description("Extremely flexible cross-platform scripting library designed to allow applications to extend their functionality through external scripts")
    set_license("zlib")

    add_urls("http://angelcode.com/angelscript/sdk/files/angelscript_$(version).zip")
    add_versions("2.35.0", "010dd45e23e734d46f5891d70e268607a12cb9ab12503dda42f842d9db7e8857")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        os.cd("angelscript/projects/cmake")
        local configs = {}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:is_plat("android") then
            io.gsub("CMakeLists.txt", "set_property", "#set_property")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include "angelscript.h"
            static void test() {
                std::cout << asGetLibraryVersion() << "\n";
            }
        ]]}, {configs = {languages = "c++11"}, includes = "angelscript.h"}))
    end)