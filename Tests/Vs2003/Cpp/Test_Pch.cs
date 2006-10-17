using System;
using NUnit.Framework;
using Premake.Tests.Framework;

namespace Premake.Tests.Vs2003.Cpp
{
	[TestFixture]
	public class Test_Pch
	{
		Script _script;
		Project _expects;
		Parser _parser;

		#region Setup and Teardown
		[SetUp]
		public void Test_Setup()
		{
			_script = Script.MakeBasic("exe", "c++");

			_expects = new Project();
			_expects.Package.Add(1);
			_expects.Package[0].Config.Add(2);

			_parser = new Vs2003Parser();
		}

		public void Run()
		{
			TestEnvironment.Run(_script, _parser, _expects, null);
		}
		#endregion

		[Test]
		public void Test_SetOnPackage()
		{
			_script.Replace("'somefile.txt'", "'MyPch.h','MyPch.cpp'");
			_script.Append("package.pchheader = 'MyPch.h'");
			_script.Append("package.pchsource = 'MyPch.cpp'");
			_expects.Package[0].Config[0].PchHeader = "MyPch.h";
			_expects.Package[0].Config[0].PchSource = "MyPch.cpp";
			_expects.Package[0].Config[1].PchHeader = "MyPch.h";
			_expects.Package[0].Config[1].PchSource = "MyPch.cpp";
			Run();
		}
	}
}
