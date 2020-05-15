package("zeromq")

    set_homepage("https://zeromq.org/")
    set_description("High-performance, asynchronous messaging library")

    set_urls("https://github.com/zeromq/libzmq/releases/download/v$(version)/zeromq-$(version).tar.gz",
             "https://github.com/zeromq/libzmq.git")

    add_versions("4.3.2", "ebd7b5c830d6428956b67a0454a7f8cbed1de74b3b01e5c33c5378e22740f763")

    if is_host("windows") then
        add_deps("cmake")
    end

    on_install("windows", function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("linux", "macosx", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end
        import("package.tools.autoconf").install(package, configs)
    end)
 
    on_test(function (package)
        assert(package:has_cfuncs("zmq_msg_init_size", {includes = "zmq.h"}))
    end)
