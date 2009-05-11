
premake.compiler = {}

function premake.compiler.log(fmt, ...)
	local self = premake.compiler
	if not self.logfile then
		local loc = solution() or { ['location'] = '.' }
		loc = path.join(loc.location, '.premake-build')
		os.mkdir(loc)
		self.logfile = path.join(loc, "build.log")
	end

  fh = assert(io.open(logfile, "w+"))
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

    -- if still no cc, then we can't continue
    if not cc then error("Error: boost requires a C/C++ project") end

  end
  return cc
end

