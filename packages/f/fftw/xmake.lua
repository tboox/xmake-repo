package("fftw")

    set_homepage("http://fftw.org/")
    set_description("A C subroutine library for computing the discrete Fourier transform (DFT) in one or more dimensions.")
    set_license("GPL-2.0")

    add_urls("http://fftw.org/fftw-$(version).tar.gz")
    add_versions("3.3.8", "6113262f6e92c5bd474f2875fa1b01054c4ad5040f6b0da7c03c98821d9ae303")
    add_versions("3.3.9", "bf2c7ce40b04ae811af714deb512510cc2c17b9ab9d6ddcf49fe4487eea7af3d")

    add_configs("precision", {description = "Float number precision.", default = "double", type = "string", values = {"float", "double", "quad", "long"}})
    add_configs("thread", {description = "Thread model used.", default = "fftw", type = "string", values = {"none", "fftw", "openmp"}})
    add_configs("enable_mpi", {description = "Enable MPI support.", default = false, type = "boolean"})
    add_configs("simd", {description = "SIMD instruction sets used.", default = "avx2", type = "string", values = {"none", "sse", "sse2", "avx", "avx2", "avx512", "avx-128-fma", "kcvi", "altivec", "vsx", "neon", "generic-simd128", "generic-simd256"}})

    if is_plat("windows") then
        add_deps("cmake")
    end

    on_install("windows", function (package)
        local configs = {"-DBUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") then
            package:add("defines", "FFTW_DLL")
            table.insert(configs, "-DWITH_COMBINED_THREADS=ON")
        end
        if package:config("precision") == "float" then
            table.insert(configs, "-DENABLE_FLOAT=ON")
        elseif package:config("precision") == "quad" then
            table.insert(configs, "-DENABLE_QUAD_PRECISION=ON")
        elseif package:config("precision") == "long" then
            table.insert(configs, "-DENABLE_LONG_DOUBLE=ON")
        end
        if package:config("thread") == "fftw" then
            table.insert(configs, "-DENABLE_THREADS=ON")
        elseif package:config("thread") == "openmp" then
            table.insert(configs, "-DENABLE_OPENMP=ON")
        end
        local simds = import("core.base.hashset").of("sse", "sse2", "avx", "avx2")
        local simd = package:config("simd")
        if simd ~= "none" and simds:has(simd) then
            table.insert(configs, "-DENABLE_" .. string.upper(simd) .. "=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("linux", "macosx", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared")
        end
        if package:config("precision") == "float" then
            table.insert(configs, "--enable-float")
        elseif package:config("precision") == "quad" then
            table.insert(configs, "--enable-quad-precision")
        elseif package:config("precision") == "long" then
            table.insert(configs, "--enable-long-double")
        end
        if package:config("thread") == "fftw" then
            table.insert(configs, "--enable-threads")
        elseif package:config("thread") == "openmp" then
            table.insert(configs, "--enable-openmp")
        end
        if package:config("enable_mpi") then
            table.insert(configs, "--enable-mpi")
        end
        if package:config("simd") ~= "none" then
            table.insert(configs, "--enable-" .. package:config("simd"))
        end
        import("lib.detect.find_tool")
        local fortran = find_tool("gfortran")
        if fortran then
            table.insert(configs, "F77=" .. fortran.program)
        else
            table.insert(configs, "--disable-fortran")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fftw_execute", {includes = "fftw3.h"}))
    end)
