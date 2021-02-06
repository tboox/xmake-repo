package("cef")

    set_homepage("https://bitbucket.org/chromiumembedded")
    set_description("Chromium Embedded Framework (CEF). A simple framework for embedding Chromium-based browsers in other applications.")
    set_license("BSD-3-Clause")

    add_versions("88.2.1", "8ed01da6327258536c61ada46e14157149ce727e7729ec35a30b91b3ad3cf555")

    set_urls("https://cef-builds.spotifycdn.com/cef_binary_$(version).tar.bz2", {version = function (version)
        if version:eq("88.2.1") then
            return "88.2.1+g0b18d0b+chromium-88.0.4324.146_windows64"
        end
        return ""
    end})

    add_includedirs(".", "include")

    if is_plat("windows") then
        add_syslinks("user32", "advapi32")
    end

    on_install("windows", function (package)
        package:addenv("PATH", "bin")
        os.cp("Release/*.lib", package:installdir("lib"))
        os.cp("Release/*.dll", package:installdir("bin"))
        os.cp("Resources/*", package:installdir("bin"))
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("CefEnableHighDPISupport", {includes = "cef_app.h"}))
    end)
