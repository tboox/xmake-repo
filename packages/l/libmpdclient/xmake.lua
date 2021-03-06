package("libmpdclient")
    set_homepage("https://musicpd.org/libs/libmpdclient/")
    set_description("A stable, documented, asynchronous API library for interfacing MPD in the C, C++ & Objective C languages.")
    add_urls("https://musicpd.org/download/libmpdclient/2/libmpdclient-$(version).tar.xz")
    add_versions("2.19", "158aad4c2278ab08e76a3f2b0166c99b39fae00ee17231bd225c5a36e977a189")
    add_deps("meson", "ninja")

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "--libdir=lib")
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
        os.cp("include", package:installdir())
        os.cp("build_*/version.h", package:installdir() .. "/include/mpd")
        os.rm(package:installdir() .. "/include/mpd/version.h.in")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mpd_connection_new", {includes = "mpd/connection.h"}))
    end)
