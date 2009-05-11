--
-- gcc.lua
-- Provides GCC-specific configuration strings.
-- Copyright (c) 2002-2008 Jason Perkins and the Premake project
--

	
	premake.gcc = { }
	premake.gcc.targetstyle = "linux"
	

--
-- Set default tools
--

	premake.gcc.cc     = "gcc"
	premake.gcc.cxx    = "g++"
	premake.gcc.ar     = "ar"
	
	
--
-- Translation of Premake flags into GCC flags
--

	local cflags =
	{
		ExtraWarnings  = "-Wall",
		FatalWarnings  = "-Werror",
		NoFramePointer = "-fomit-frame-pointer",
		Optimize       = "-O2",
		OptimizeSize   = "-Os",
		OptimizeSpeed  = "-O3",
		Symbols        = "-g",
	}

	local cxxflags =
	{
		NoExceptions   = "-fno-exceptions",
		NoRTTI         = "-fno-rtti",
	}
	
	
--
-- Map platforms to flags
--

	premake.gcc.platforms = 
	{
		Native = { 
			cppflags = "-MMD", 
		},
		x32 = { 
			cppflags = "-MMD",	
			flags    = "-m32",
			ldflags  = "-L/usr/lib32", 
		},
		x64 = { 
			cppflags = "-MMD",
			flags    = "-m64",
			ldflags  = "-L/usr/lib64",
		},
		Universal = { 
			cppflags = "",
			flags    = "-arch i386 -arch x86_64 -arch ppc -arch ppc64",
		},
		Universal32 = { 
			cppflags = "",
			flags    = "-arch i386 -arch ppc",
		},
		Universal64 = { 
			cppflags = "",
			flags    = "-arch x86_64 -arch ppc64",
		},
		PS3 = {
			cc         = "ppu-lv2-g++",
			cxx        = "ppu-lv2-g++",
			ar         = "ppu-lv2-ar",
			cppflags   = "-MMD",
		}
	}

	local platforms = premake.gcc.platforms
	

--
-- Returns a list of compiler flags, based on the supplied configuration.
--

	function premake.gcc.getcppflags(cfg)
		return platforms[cfg.platform].cppflags
	end


	function premake.gcc.getcflags(cfg)
		local result = table.translate(cfg.flags, cflags)
		table.insert(result, platforms[cfg.platform].flags)
		if cfg.kind == "SharedLib" then
			table.insert(result, "-fPIC")
		end
		return result		
	end

	
	function premake.gcc.getcxxflags(cfg)
		local result = table.translate(cfg.flags, cxxflags)
		return result
	end
	


--
-- Returns a list of linker flags, based on the supplied configuration.
--

	function premake.gcc.getldflags(cfg)
		local result = { }
		
		-- OS X has a bug, see http://lists.apple.com/archives/Darwin-dev/2006/Sep/msg00084.html
		if not cfg.flags.Symbols then
			if cfg.system == "macosx" then
				table.insert(result, "-Wl,-x")
			else
				table.insert(result, "-s")
			end
		end
	
		if cfg.kind == "SharedLib" then
			if cfg.system == "macosx" then
				result = table.join(result, { "-dynamiclib", "-flat_namespace" })
			else
				table.insert(result, "-shared")
			end
				
			if cfg.system == "windows" and not cfg.flags.NoImportLib then
				table.insert(result, '-Wl,--out-implib="'..premake.gettarget(cfg, "link", "linux").fullpath..'"')
			end
		end

		if cfg.kind == "WindowedApp" then
			if cfg.system == "windows" then
				table.insert(result, "-mwindows")
			end
		end
		
		local platform = platforms[cfg.platform]
		table.insert(result, platform.flags)
		table.insert(result, platform.ldflags)
		return result
	end
		
	
--
-- Returns a list of linker flags for library search directories and library
-- names. See bug #1729227 for background on why the path must be split.
--

	function premake.gcc.getlinkflags(cfg)
		local result = { }
		for _, value in ipairs(premake.getlinks(cfg, "all", "directory")) do
			table.insert(result, '-L' .. _MAKE.esc(value))
		end
		for _, value in ipairs(premake.getlinks(cfg, "all", "basename")) do
			table.insert(result, '-l' .. _MAKE.esc(value))
		end
		return result
	end
	
	

--
-- Decorate defines for the GCC command line.
--

	function premake.gcc.getdefines(defines)
		local result = { }
		for _,def in ipairs(defines) do
			table.insert(result, '-D' .. def)
		end
		return result
	end


	
--
-- Decorate include file search paths for the GCC command line.
--

	function premake.gcc.getincludedirs(includedirs)
		local result = { }
		for _,dir in ipairs(includedirs) do
			table.insert(result, "-I" .. _MAKE.esc(dir))
		end
		return result
	end

--
-- Method used during configure checks. Attempts to compile the file
--
	function premake.gcc._compile(options)
		local self = premake.gcc
		local cmd

		if not options.working_dir or not options.source then
			error("gcc._compile needs a working_dir and source options", 0)
		end

		if not options.target then
			if os.is("windows") then
				options.target = "premake_test.exe"
			else
				options.target = "premake_test"
			end
		end
		dump(options)
		
		-- First work out if we are compiling C or C++
		if path.getextension(file) == ".c" then
			cmd = { self.cc }
		else
			cmd = { self.cxx }
		end

		cmd = table.join( cmd, {
			"-o",
			path.join(options.working_dir, options.target)
		} )

		if options.includedirs then
			cmd = table.join(cmd, self.getincludedirs(options.includedirs))
		end

		if options.defines then
			cmd = table.join(cmd, self.getincludedirs(options.defines))
		end


		cmd = table.join(cmd, " ")
		premake.compiler.log("Running: %s\n", cmd)

	end
