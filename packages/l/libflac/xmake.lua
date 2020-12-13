package("libflac")

    set_homepage("https://xiph.org/flac")
    set_description("Free Lossless Audio Codec")
    set_license("BSD")

    set_urls("https://github.com/xiph/flac/archive/$(version).tar.gz",
             "https://github.com/xiph/flac.git")

    add_versions("1.3.3", "668cdeab898a7dd43cf84739f7e1f3ed6b35ece2ef9968a5c7079fe9adfe1689")
    add_patches("1.3.3", path.join(os.scriptdir(), "patches", "1.3.3", "cmake.patch"), "480e1645aa80d64526ba45c73a00703843a6b1764e4e3444b6115d1ead0a90c0")

    add_deps("cmake", "libogg")

    if is_plat("linux") then
        add_syslinks("m")
    end

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "FLAC__NO_DLL")
        end
    end)

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_CXXLIBS=OFF")
        table.insert(configs, "-DBUILD_DOCS=OFF")
        table.insert(configs, "-DBUILD_PROGRAMS=OFF")
        table.insert(configs, "-DBUILD_EXAMPLES=OFF")
        table.insert(configs, "-DBUILD_TESTING=OFF")
        table.insert(configs, "-DBUILD_UTILS=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")

        local libogg = package:dep("libogg")
        if (libogg) then
            local liboggFiles = libogg:fetch()
            if (liboggFiles and liboggFiles.libfiles[1]) then
                table.insert(configs, "-DOGG_INCLUDE_DIR=" .. libogg:installdir("include"))
                table.insert(configs, "-DOGG_LIBRARY=" .. liboggFiles.libfiles[1])
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FLAC__format_sample_rate_is_valid", {includes = "FLAC/format.h"}))
    end)