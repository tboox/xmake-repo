package("ninja")

    set_kind("binary")
    set_homepage("https://ninja-build.org/")
    set_description("Small build system for use with gyp or CMake.")

    if is_host("windows") then
        set_urls("https://github.com/ninja-build/ninja/releases/download/v$(version)/ninja-win.zip")
        add_versions("1.9.0", "2d70010633ddaacc3af4ffbd21e22fae90d158674a09e132e06424ba3ab036e9")
        add_versions("1.10.1", "5d1211ea003ec9760ad7f5d313ebf0b659d4ffafa221187d2b4444bc03714a33")
    elseif is_host("macosx") then
        set_urls("https://github.com/ninja-build/ninja/releases/download/v$(version)/ninja-mac.zip")
        add_versions("1.9.0", "26d32a79f786cca1004750f59e545199bf110e21e300d3c2424c1fddd78f28ab")
        add_versions("1.10.1", "0bd650190d4405c15894055e349d9b59d5690b0389551d757c5ed2d3841972d1")
    elseif is_host("linux") then
        add_urls("https://github.com/ninja-build/ninja/archive/v$(version).tar.gz",
                 "https://github.com/ninja-build/ninja.git")
        add_versions("1.9.0", "5d7ec75828f8d3fd1a0c2f31b5b0cea780cdfe1031359228c428c1a48bfcd5b9")
        add_versions("1.10.1", "a6b6f7ac360d4aabd54e299cc1d8fa7b234cd81b9401693da21221c62569a23e")
    end

    if is_host("linux") then
        add_deps("python2", {kind = "binary"})
    end

    on_install("@windows", "@msys", "@cygwin", function (package)
        os.cp("./ninja.exe", package:installdir("bin"))
    end)

    on_install("@macosx", function (package)
        os.cp("./ninja", package:installdir("bin"))
    end)

    on_install("@linux", function (package)
        os.vrun("python2 configure.py --bootstrap")
        os.cp("./ninja", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("ninja --version")
    end)
