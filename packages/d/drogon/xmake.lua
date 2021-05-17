package("drogon")

    set_homepage("https://github.com/an-tao/drogon/")
    set_description("Drogon: A C++14/17 based HTTP web application framework running on Linux/macOS/Unix/Windows")
    set_license("MIT")

    add_urls("https://github.com/an-tao/drogon/archive/refs/tags/$(version).tar.gz",
             "https://github.com/an-tao/drogon.git")
    add_versions("v1.4.1", "ad794d7744b600240178348c15e216c919fe7a2bc196cf1239f129aee2af19c7")
    add_versions("v1.6.0", "9f8802b579aac29e9eddfb156e432276727a3d3c49fffdf453a2ddcd1cb69093")

    add_patches("1.4.1", path.join(os.scriptdir(), "patches", "1.4.1", "trantor.patch"), "7f9034a27bb63de8dedb80dd9f246ea7aa7724c87f2c0d0054f4b6097ea2a862")
    add_patches("1.4.1", path.join(os.scriptdir(), "patches", "1.4.1", "resolv.patch"), "84bff60e9ad632f585fadc2384eccb193aec95ccc14ec9c18196cd40a527538c")
    add_patches("1.6.0", path.join(os.scriptdir(), "patches", "1.6.0", "trantor.patch"), "87e317bf5e45b3f3dfe781db8a0af9603ebdab057a6aedbc36d8aec9e0da58a7")
    add_patches("1.6.0", path.join(os.scriptdir(), "patches", "1.6.0", "resolv.patch"), "834c212a14da8371ce82946287bb4be1471c90f385a70bb9f6191a3a5566cdc2")

    add_deps("cmake")
    add_deps("trantor", "jsoncpp", "brotli", "zlib")
    add_deps("c-ares", "sqlite3", "openssl", {optional = true})
    add_deps("postgresql", {optional = true, system = true})
    if is_plat("windows") then
        add_syslinks("ws2_32", "rpcrt4", "crypt32", "advapi32")
    else
        add_deps("libuuid")
        if is_plat("linux") then
            add_syslinks("pthread")
        end
    end

    on_install("windows|x64", "macosx", "linux", function (package)
        io.replace("cmake/templates/config.h.in", "\"@COMPILATION_FLAGS@@DROGON_CXX_STANDARD@\"", "R\"(@COMPILATION_FLAGS@@DROGON_CXX_STANDARD@)\"", {plain = true})
        io.replace("CMakeLists.txt", "else(BUILD_DROGON_SHARED)\n", "if(APPLE)\ntarget_link_libraries(${PROJECT_NAME} PUBLIC resolv)\nendif(APPLE)\nelse(BUILD_DROGON_SHARED)\n", {plain = true})

        local configs = {"-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        -- no support for windows shared library
        if not package:is_plat("windows") then
            table.insert(configs, "-DBUILD_DROGON_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        end
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("drogon::getVersion()", {configs = {languages = "c++17"}, includes = "drogon/drogon.h"}))
    end)
