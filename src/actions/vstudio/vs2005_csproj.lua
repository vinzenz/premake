--
-- vs2005_csproj.lua
-- Generate a Visual Studio 2005/2008 C# project.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	--
	-- Figure out what elements a particular source code file need in its item
	-- block, based on its build action and any related files in the project.
	-- 
	
	local function getelements(prj, action, fname)
	
		if action == "Compile" and fname:endswith(".cs") then
			if fname:endswith(".Designer.cs") then
				-- is there a matching *.cs file?
				local basename = fname:sub(1, -13)
				local testname = basename .. ".cs"
				if premake.findfile(prj, testname) then
					return "Dependency", testname
				end
				-- is there a matching *.resx file?
				testname = basename .. ".resx"
				if premake.findfile(prj, testname) then
					return "AutoGen", testname
				end
			else
				-- is there a *.Designer.cs file?
				local basename = fname:sub(1, -4)
				local testname = basename .. ".Designer.cs"
				if premake.findfile(prj, testname) then
					return "SubTypeForm"
				end
			end
		end

		if action == "EmbeddedResource" and fname:endswith(".resx") then
			-- is there a matching *.cs file?
			local basename = fname:sub(1, -6)
			local testname = path.getname(basename .. ".cs")
			if premake.findfile(prj, testname) then
				if premake.findfile(prj, basename .. ".Designer.cs") then
					return "DesignerType", testname
				else
					return "Dependency", testname
				end
			else
				-- is there a matching *.Designer.cs?
				testname = path.getname(basename .. ".Designer.cs")
				if premake.findfile(prj, testname) then
					return "AutoGenerated"
				end
			end
		end
				
		if action == "Content" then
			return "CopyNewest"
		end
		
		return "None"
	end


	function premake.vs2005_csproj(prj)
		io.eol = "\r\n"

		local vsversion, toolversion
		if _ACTION == "vs2005" then
			vsversion   = "8.0.50727"
			toolversion = nil
		elseif _ACTION == "vs2008" then
			vsversion   = "9.0.21022"
			toolversion = "3.5"
		end
		
		if toolversion then
			_p('<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="%s">', toolversion)
		else
			_p('<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">')
		end

		_p('  <PropertyGroup>')
		_p('    <Configuration Condition=" \'$(Configuration)\' == \'\' ">%s</Configuration>', premake.esc(prj.solution.configurations[1]))
		_p('    <Platform Condition=" \'$(Platform)\' == \'\' ">AnyCPU</Platform>')
		_p('    <ProductVersion>%s</ProductVersion>', vsversion)
		_p('    <SchemaVersion>2.0</SchemaVersion>')
		_p('    <ProjectGuid>{%s}</ProjectGuid>', prj.uuid)
		_p('    <OutputType>%s</OutputType>', premake.csc.getkind(prj))
		_p('    <AppDesignerFolder>Properties</AppDesignerFolder>')
		_p('    <RootNamespace>%s</RootNamespace>', prj.buildtarget.basename)
		_p('    <AssemblyName>%s</AssemblyName>', prj.buildtarget.basename)
		_p('  </PropertyGroup>')

		for cfg in premake.eachconfig(prj) do
			_p('  <PropertyGroup Condition=" \'$(Configuration)|$(Platform)\' == \'%s|AnyCPU\' ">', premake.esc(cfg.name))
			if cfg.flags.Symbols then
				_p('    <DebugSymbols>true</DebugSymbols>')
				_p('    <DebugType>full</DebugType>')
			else
				_p('    <DebugType>pdbonly</DebugType>')
			end
			_p('    <Optimize>%s</Optimize>', iif(cfg.flags.Optimize or cfg.flags.OptimizeSize or cfg.flags.OptimizeSpeed, "true", "false"))
			_p('    <OutputPath>%s</OutputPath>', cfg.buildtarget.directory)
			_p('    <DefineConstants>%s</DefineConstants>', table.concat(premake.esc(cfg.defines), ";"))
			_p('    <ErrorReport>prompt</ErrorReport>')
			_p('    <WarningLevel>4</WarningLevel>')
			if cfg.flags.Unsafe then
				_p('    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>')
			end
			if cfg.flags.FatalWarnings then
				_p('    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>')
			end
			_p('  </PropertyGroup>')
		end

		_p('  <ItemGroup>')
		for _, ref in ipairs(premake.getlinks(prj, "siblings", "object")) do
			_p('    <ProjectReference Include="%s">', path.translate(path.getrelative(prj.location, _VS.projectfile(ref)), "\\"))
			_p('      <Project>{%s}</Project>', ref.uuid)
			_p('      <Name>%s</Name>', premake.esc(ref.name))
			_p('    </ProjectReference>')
		end
		for _, linkname in ipairs(premake.getlinks(prj, "system", "basename")) do
			_p('    <Reference Include="%s" />', premake.esc(linkname))
		end
		_p('  </ItemGroup>')

		_p('  <ItemGroup>')
		for fcfg in premake.eachfile(prj) do
			local action = premake.csc.getbuildaction(fcfg)
			local fname  = path.translate(premake.esc(fcfg.name), "\\")
			local elements, dependency = getelements(prj, action, fcfg.name)
			if elements == "None" then
				_p('    <%s Include="%s" />', action, fname)
			else
				_p('    <%s Include="%s">', action, fname)
				if elements == "AutoGen" then
					_p('      <AutoGen>True</AutoGen>')
				elseif elements == "AutoGenerated" then
					_p('      <SubType>Designer</SubType>')
					_p('      <Generator>ResXFileCodeGenerator</Generator>')
					_p('      <LastGenOutput>%s.Designer.cs</LastGenOutput>', premake.esc(path.getbasename(fcfg.name)))
				elseif elements == "SubTypeDesigner" then
					_p('      <SubType>Designer</SubType>')
				elseif elements == "SubTypeForm" then
					_p('      <SubType>Form</SubType>')
				elseif elements == "PreserveNewest" then
					_p('      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>')
				end
				if dependency then
					_p('      <DependentUpon>%s</DependentUpon>', path.translate(premake.esc(dependency), "\\"))
				end
				_p('    </%s>', action)
			end
		end
		_p('  </ItemGroup>')

		_p('  <Import Project="$(MSBuildBinPath)\\Microsoft.CSharp.targets" />')
		_p('  <!-- To modify your build process, add your task inside one of the targets below and uncomment it.')
		_p('       Other similar extension points exist, see Microsoft.Common.targets.')
		_p('  <Target Name="BeforeBuild">')
		_p('  </Target>')
		_p('  <Target Name="AfterBuild">')
		_p('  </Target>')
		_p('  -->')
		_p('</Project>')
		
	end

