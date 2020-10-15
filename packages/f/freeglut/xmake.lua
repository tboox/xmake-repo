package("freeglut")

    set_homepage("http://freeglut.sourceforge.net")
    set_description("A free-software/open-source alternative to the OpenGL Utility Toolkit (GLUT) library.")

    set_urls("https://github.com/dcnieho/FreeGLUT/archive/FG_$(version).zip",
            {version = function (version) return (version:gsub("%.", "_")) end})
    add_versions("3.0.0", "050e09f17630249a7d2787c21691e4b7d7b86957a06b3f3f34fa887b561d8e04")

    if is_plat("linux", "windows") then
        add_deps("cmake")
    end

    if is_plat("linux") then
        add_deps("libx11", "libxi")
    end

    on_install("linux", "windows", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("glutInit", {includes = "GL/glut.h"}))
    end)
