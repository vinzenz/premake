--
-- tests/test_gcc.lua
-- Automated test suite for the GCC toolset interface.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.gcc = { }
	local suite = T.gcc

	local cfg
	function suite.setup()
		cfg = { }
		cfg.basedir    = "."
		cfg.location   = "."
		cfg.language   = "C++"
		cfg.project    = { name = "MyProject" }
		cfg.flags      = { }
		cfg.objectsdir = "obj"
		cfg.platform   = "Native"
		cfg.links      = { }
		cfg.libdirs    = { }
		cfg.linktarget = { fullpath="libMyProject.a" }
	end


	function suite.cflags_SharedLib_Windows()
		cfg.kind = "SharedLib"
		cfg.system = "windows"
		local r = premake.gcc.getcflags(cfg)
		test.isequal('-fPIC', table.concat(r,"|"))
	end


	function suite.ldflags_SharedLib_Windows()
		cfg.kind = "SharedLib"
		cfg.system = "windows"
		local r = premake.gcc.getldflags(cfg)
		test.isequal('-s|-shared|-Wl,--out-implib="libMyProject.a"', table.concat(r,"|"))
	end


	function suite.cflags_OnFpFast()
		cfg.flags = { "FloatFast" }
		local r = premake.gcc.getcflags(cfg)
		test.isequal('-ffast-math', table.concat(r,"|"))
	end


	function suite.cflags_OnFpStrict()
		cfg.flags = { "FloatStrict" }
		local r = premake.gcc.getcflags(cfg)
		test.isequal('-ffloat-store', table.concat(r,"|"))
	end


	function suite.linkflags_OnFrameworks()
		cfg.links = { "Cocoa.framework" }
		local r = premake.gcc.getlinkflags(cfg)
		test.isequal('-framework Cocoa', table.concat(r,"|"))
	end
