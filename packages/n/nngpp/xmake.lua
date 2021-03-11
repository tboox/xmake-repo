package("nngpp")

    set_homepage("https://github.com/cwzx/nngpp")
    set_description("C++ wrapper around the nanomsg NNG API.")

    add_urls("https://github.com/cwzx/nngpp.git")

    on_load(function (package)
        package:add("deps", "nng")
    end)

    add_deps("cmake")
    on_install("windows", "linux", "macosx", "android", "iphoneos", function(package)
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <nngpp/nngpp.h>
            static void test() {
                nng::aio aio = nng::make_aio();
            }
        ]]}, {includes = "nngpp/nngpp.h",configs = {languages = "c++11"}}))
    end)
