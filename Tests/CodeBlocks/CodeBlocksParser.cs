using System;
using System.Collections;
using System.IO;
using Premake.Tests.Framework;

namespace Premake.Tests.CodeBlocks
{
	public class CodeBlocksParser : Parser
	{
		#region Parser Methods
		public override string TargetName
		{
			get { return "cb"; }
		}
		#endregion

		#region Workspace Parsing
		public override void Parse(Project project, string filename)
		{
			/* File header */
			Begin(filename + ".workspace");
			Match("<?xml version=\"1.0\"?>");
			Match("<!DOCTYPE CodeBlocks_workspace_file>");
			Match("<CodeBlocks_workspace_file>");
			Match("\t<Workspace title=\"" + project.Name + "\">");
		}
		#endregion

	}
}
