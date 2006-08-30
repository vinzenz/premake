/**********************************************************************
 * Premake - cb_cpp.c
 * The Code::Blocks C/C++ target
 *
 * Copyright (c) 2002-2006 Jason Perkins and the Premake project
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License in the file LICENSE.txt for details.
 **********************************************************************/

#include <stdio.h>
#include <string.h>
#include "premake.h"
#include "cb.h"

static const char* filterLinks(const char* name);
static void print_opt(const char* opt);


static const char* listFiles(const char* filename)
{
	int i;

	io_print("\t\t<Unit filename=\"%s\">\n", filename);
	io_print("\t\t\t<Option compilerVar=\"%s\" />\n", prj_is_lang("c") ? "CC" : "CPP");
	if (!is_cpp(filename))
	{
		io_print("\t\t\t<Option compile=\"0\" />\n");
		io_print("\t\t\t<Option link=\"0\" />\n");
	}
	
	for (i = 0; i < prj_get_numconfigs(); ++i)
	{
		Package* pkg = prj_get_package();
		io_print("\t\t\t<Option target=\"%s\" />\n", pkg->configs[i]->prjConfig->name);
	}

	io_print("\t\t</Unit>\n");
	return NULL;
}


int cb_cpp()
{
	int i;

	/* Write the file */
	if (!io_openfile(path_join(prj_get_pkgpath(), prj_get_pkgname(), "cbp")))
		return 0;

	io_print("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>\n");
	io_print("<CodeBlocks_project_file>\n");
	io_print("\t<FileVersion major=\"1\" minor=\"5\" />\n");
	io_print("\t<Project>\n");
	io_print("\t\t<Option title=\"%s\" />\n", prj_get_pkgname());
	io_print("\t\t<Option pch_mode=\"2\" />\n");
	io_print("\t\t<Option default_target=\"\" />\n");
	io_print("\t\t<Option compiler=\"gcc\" />\n");
	io_print("\t\t<Option virtualFolders=\"\" />\n");
	io_print("\t\t<Build>\n");

	for (i = 0; i < prj_get_numconfigs(); ++i)
	{
		int kindCode;

		prj_select_config(i);

		io_print("\t\t\t<Target title=\"%s\">\n", prj_get_cfgname());
		io_print("\t\t\t\t<Option output=\"%s\" />\n", prj_get_target());
		io_print("\t\t\t\t<Option object_output=\"%s\" />\n", prj_get_objdir());

		if (prj_is_kind("winexe")) 
			kindCode = 0;
		else if (prj_is_kind("exe"))    
			kindCode = 1;
		else if (prj_is_kind("lib"))    
			kindCode = 2;
		else if (prj_is_kind("dll"))    
			kindCode = 3;
		else
		{
			printf("** Unsupported project kind %s\n", prj_get_kind());
			return 0;
		}
		io_print("\t\t\t\t<Option type=\"%d\" />\n", kindCode);

		io_print("\t\t\t\t<Option compiler=\"gcc\" />\n");

		if (prj_is_kind("dll"))
		{
			io_print("\t\t\t\t<Option createDefFile=\"0\" />\n");
			io_print("\t\t\t\t<Option createStaticLib=\"0\" />\n");
		}

		io_print("\t\t\t\t<Compiler>\n");
		if (prj_has_flag("extra-warnings"))
			print_opt("-Wall");
		if (prj_has_flag("fatal-warnings"))
			print_opt("-Werror");
		if (prj_has_flag("no-exceptions"))
			print_opt("--no-exceptions");
		if (prj_has_flag("no-frame-pointer"))
			print_opt("-fomit-frame-pointer");
		if (prj_has_flag("no-rtti"))
			print_opt("--no-rtti");
		if (!prj_has_flag("no-symbols"))
			print_opt("-g");
		if (prj_has_flag("optimize-size"))
			print_opt("-Os");
		if (prj_has_flag("optimize-speed"))
			print_opt("-O3");
		if (prj_has_flag("optimize") && !prj_has_flag("optimize-size") && !prj_has_flag("optimize-speed"))
			print_opt("-O");
		print_list(prj_get_defines(), "\t\t\t\t\t<Add option=\"-D", "\" />\n", "", NULL);
		print_list(prj_get_buildoptions(), "\t\t\t\t\t<Add option=\"", "\" />\n", "", NULL);
		print_list(prj_get_incpaths(), "\t\t\t\t\t<Add directory=\"", "\" />\n", "", NULL); 
		io_print("\t\t\t\t</Compiler>\n");

		io_print("\t\t\t\t<Linker>\n");
		if (prj_has_flag("no-symbols"))
			print_opt("-s");
		print_list(prj_get_libpaths(), "\t\t\t\t\t<Add directory=\"", "\" />\n", "", NULL);
		print_list(prj_get_links(), "\t\t\t\t\t<Add library=\"", "\" />\n", "", filterLinks);
		io_print("\t\t\t\t</Linker>\n");

		io_print("\t\t\t</Target>\n");
	}

	io_print("\t\t</Build>\n");

	print_list(prj_get_files(), "", "", "", listFiles);

	io_print("\t\t<Extensions />\n");
	io_print("\t</Project>\n");
	io_print("</CodeBlocks_project_file>\n");

	io_closefile();
	return 1;
}


static void print_opt(const char* opt)
{
	io_print("\t\t\t\t\t<Add option=\"%s\" />\n", opt);
}


/************************************************************************
 * Checks each entry in the list of package links. If the entry refers
 * to a sibling package, returns the path to that package's output
 ***********************************************************************/

static const char* filterLinks(const char* name)
{
	int i = prj_find_package(name);
	if (i >= 0)
	{
		const char* lang = prj_get_language_for(i);
		if (matches(lang, "c++") || matches(lang, "c"))
		{
			return prj_get_target_for(i);
		}
		else
		{
			return NULL;
		}
	}
	else
	{
		return name;
	}
}
