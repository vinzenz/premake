/**********************************************************************
 * Premake - cb.c
 * The Code::Blocks target
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
#include "premake.h"
#include "cb.h"

int cb_generate()
{
	int i;

	puts("Generating Code::Blocks workspace and project files:");

	if (!io_openfile(path_join(prj_get_path(), prj_get_name(), "workspace")))
		return 0;

	io_print("<?xml version=\"1.0\"?>\n");
	io_print("<!DOCTYPE CodeBlocks_workspace_file>\n");
	io_print("<CodeBlocks_workspace_file>\n");
	io_print("\t<Workspace title=\"%s\">\n", prj_get_name());

	io_closefile();
	return 1;
}
