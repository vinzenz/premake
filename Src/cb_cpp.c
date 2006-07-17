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

int cb_cpp()
{
	/* Write the file */
	if (!io_openfile(path_join(prj_get_pkgpath(), prj_get_pkgname(), "cbp")))
		return 0;

	io_print("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>\n");
	io_print("<CodeBlocks_project_file>\n");
	io_print("\t<FileVersion major=\"1\" minor=\"4\" />\n");
	io_print("\t<Project>\n");
	io_print("\t\t<Option title=\"%s\" />\n", prj_get_pkgname());
	io_print("\t\t<Option pch_mode=\"0\" />\n");
	io_print("\t\t<Option default_target=\"-1\" />\n");
	io_print("\t\t<Option compiler=\"gcc\" />\n");
	io_print("\t\t<Build>\n");

	io_closefile();
	return 1;
}
