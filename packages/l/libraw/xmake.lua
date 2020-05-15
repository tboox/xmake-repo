package("libraw")
    set_homepage("http://www.libraw.org")
    set_description("LibRaw is a library for reading RAW files from digital cameras.")

    add_urls("https://github.com/LibRaw/LibRaw/archive/$(version).tar.gz")
    add_urls("https://github.com/LibRaw/LibRaw.git")
    
    add_versions("0.19.5", "9a2a40418e4fb0ab908f6d384ff6f9075f4431f8e3d79a0e44e5a6ea9e75abdc")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    on_load(function (package)
        if package:is_plat("windows") then
            package:add("defines", "WIN32")
        end
        if not package:config("shared") then
            package:add("defines", "LIBRAW_NODLL")
        end
    end)

    on_install("macosx", "linux", "windows", "mingw", "iphoneos", function(package)
        io.writefile("xmake.lua", [[
            target("libraw")
                set_kind("$(kind)")
                if is_kind("shared") then
                    add_defines("LIBRAW_BUILDLIB")
                else
                    add_defines("LIBRAW_NODLL")
                end
                if is_plat("windows") then
                    add_defines("WIN32")
                end
                add_headerfiles("(libraw/*.h)")
                add_includedirs(".")
                add_files("src/libraw_cxx.cpp", "src/libraw_datastream.cpp", "src/libraw_c_api.cpp")
                add_files("internal/dcraw_common.cpp", "internal/dcraw_fileio.cpp", "internal/demosaic_packs.cpp")
        ]])
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--kind=shared")
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("libraw_version", {includes = "libraw/libraw.h"}))
    end)
