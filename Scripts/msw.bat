echo off
echo Windows Build v%1

rem ------------------------------------------------------------
rem Make sure all prerequisites are met
rem ------------------------------------------------------------

echo .
echo Did you test against EVERY project?
pause
echo .
echo Did you create a release branch?
pause
echo .
echo Have you updated the version number in premake.c?
pause
echo .
echo Did you update README.txt?
pause
echo .
echo Did you update CHANGES.txt?
pause
echo.
echo Ready to build Windows package for version %1.
pause

echo .
echo RETRIEVING SOURCE CODE FROM REPOSITORY...
echo .

cd ..\..
C:\Cygwin\bin\svn co https://svn.berlios.de/svnroot/repos/premake/Branches/%1 Premake-%1

echo .
echo BUILDING RELEASE BINARY...
echo .

cd Premake-%1
premake --target gnu
make CONFIG=Release

cd bin
zip -j9 ..\..\Premake\Scripts\premake-win32-%1.zip premake.exe

echo .
echo CLEANING UP...
echo .
cd ..\..
rmdir /s /q Premake-%1

cd Premake\Scripts
echo .
echo Ready to upload package to SourceForce.
pause
ftp -s:ftp_msw.txt upload.sourceforge.net

