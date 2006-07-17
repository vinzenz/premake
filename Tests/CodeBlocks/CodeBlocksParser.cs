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

			while (!Match("\t</Workspace>", true))
			{
				string[] matches = Regex("\t\t<Project filename=\"(.+?)\"(.*)/>");

				Package package = new Package();
				project.Package.Add(package);

				package.Name = Path.GetFileNameWithoutExtension(matches[0]);
				package.Path = Path.GetDirectoryName(matches[0]);
				package.ScriptName = Path.GetFileName(matches[0]);
			}

			Match("</CodeBlocks_workspace_file>");

			foreach (Package package in project.Package)
			{
				filename = Path.Combine(Path.Combine(project.Path, package.Path), package.ScriptName);
				ParseCpp(project, package, filename);
			}
		}
		#endregion

		#region C++ Parsing
		private void ParseCpp(Project project, Package package, string filename)
		{
			Begin(filename);

			Match("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>");
			Match("<CodeBlocks_project_file>");
			Match("\t<FileVersion major=\"1\" minor=\"4\" />");
			Match("\t<Project>");
			Match("\t\t<Option title=\"" + package.Name + "\" />");
			Match("\t\t<Option pch_mode=\"0\" />");
			Match("\t\t<Option default_target=\"-1\" />");
			Match("\t\t<Option compiler=\"gcc\" />");
			Match("\t\t<Build>");

		}
		#endregion

	}
}
