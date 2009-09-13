
premake.compiler = {}

function premake.compiler.log(fmt, ...)
	local self = premake.compiler
	if not self.logfile then
		local loc = solution() or { ['location'] = '.' }
		loc = path.join(loc.location, '.premake-build')
		os.mkdir(loc)
		self.logfile = path.join(loc, "build.log")
	end

  fh = assert(io.open(self.logfile, "w›+"))
  fh:write(fmt:format(...))
  fh:close()

end

function premake.compiler.get_compiler()
  local cc = premake[_OPTIONS.cc]

  if not cc then
    local ok, err
    ok, err = premake.checktools()
    if (not ok) then error("Error: " .. err, 0) end

    cc = premake[_OPTIONS.cc]

    -- 
    -- well it's not all about boost ;-)
    -- if still no cc, then we can't continue
    -- if not cc then error("Error: boost requires a C/C++ project") end
    -- 
    
  end
  return cc
end


function premake.compiler.process_compile_options( options )
        -- Parameter checks
		if not options.working_dir then
            -- Need to work somewhere
			error("Compiler needs a working_dir option", 0)
        elseif not ( options.source and options.language ) and not options.sourcefile then
            -- We need work to do 

            if not options.source and not options.sourcefile then
                -- at least one must be specified - source or sourcefile 
                error("Compiler needs a sourcefile or a source option", 0)            
            end

            if options.source and not options.language then
                -- if source was specified it is mandatory to specify a language
                error("Compiler needs to have a language option if code is passed directly by options.source", 0)
            end

        elseif options.sourcefile then

            -- Let's check if this file really exists
            if not os.dirent( options.sourcefile ) then
                 if not os.dirent( path.join( options.working_dir, options.sourcefile ) ) then

                    local msg = "Specified sourcefile '%s' does not exist or not found"
                    error( msg:format( options.sourcefile ) )

                end
            end

		elseif options.sourcefile and not options.language then

            -- We're going to set options.language as none is specified

            if path.iscfile(options.sourcefile) then
                options.language = "C"
            elseif path.iscppfile(options.sourcefile) then
                options.language = "C++"
            else 
                local msg = "Error: '%s' is either an unknown file or not and C or C++ extension"
                error( msg:format( path.getextension(options.sourcefile) ) )
            end
        end

		if not options.target then
			if os.is("windows") then
				options.target = "premake_test.exe"
			else
				options.target = "premake_test"
			end
		end

		-- work out if we are compiling C or C++
        local ext = nil
		if options.language == "C" then
			cmd = { self.cc }
            ext = ".c"
		elseif options.language == "C++" then
			cmd = { self.cxx }
            ext = ".cpp"
        else 
            local fmt = "Compiler does not support '%s' as Language"
            error(fmt:format(options.language))
		end

        -- If we got passed source code directly then
        if options.source then
            options.sourcefile = path.join( options.working_dir, "test_source" .. ext )            
            local sf = io.open( options.sourcefile, "w" )
            sf:write( options.source )
            sf:close()
        end

        return options
end

