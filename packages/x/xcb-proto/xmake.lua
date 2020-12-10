package("xcb-proto")

    set_homepage("https://www.x.org/")
    set_description("X.Org: XML-XCB protocol descriptions for libxcb code generation")

    set_urls("https://xcb.freedesktop.org/dist/xcb-proto-$(version).tar.gz")
    add_versions("1.13", "0698e8f596e4c0dbad71d3dc754d95eb0edbb42df5464e0f782621216fa33ba7")
    add_versions("1.14", "1c3fa23d091fb5e4f1e9bf145a902161cec00d260fabf880a7a248b02ab27031")

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "python 3.x", {kind = "binary"})
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-silent-rules",
                         "PYTHON=python3"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        local envs = {PKG_CONFIG_PATH = path.join(package:installdir(), "lib", "pkgconfig")}
        os.vrunv("pkg-config", {"--exists", "xcb-proto"}, {envs = envs})
    end)
