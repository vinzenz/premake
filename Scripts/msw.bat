@echo off
rem ***********************************************************
rem * Premake Windows Binary Release Script
rem * Originally written by Jason Perkins (starkos@gmail.com)
rem *
rem * Prerequisites:
rem *  Command-line svn installed on path
rem *  Command-line zip installed on path
rem *  MinGW MSYS installed and on path
rem ***********************************************************

rem * Check arguments
if "%1"=="" goto show_usage


rem ***********************************************************
rem * Pre-build checklist
rem ***********************************************************

echo. 
echo STARTING PREBUILD CHECKLIST, PRESS ^^C TO ABORT.
echo.
echo Is the version number "%1" correct?
pause
echo.
echo Have you created a release branch named "%1" in SVN?
pause
echo.
echo Have you run all of the tests?
pause
echo.
echo Did you update README.txt?
pause
echo.
echo Did you update CHANGES.txt?
pause
echo.
echo Are 'svn' and '7z' on the path?
pause
echo.
echo Okay, ready to build the Windows binary packages for version %1!
pause


rem ***********************************************************
rem * Retrieve source code
rem ***********************************************************

echo.
echo RETRIEVING SOURCE CODE FROM REPOSITORY...
echo.

svn export https://svn.sourceforge.net/svnroot/premake/Branches/%1 Premake-%1


rem ***********************************************************
rem * Build the binaries
rem ***********************************************************

echo.
echo BUILDING RELEASE BINARIES...
echo.

cd Premake-%1
premake --target gnu
make CONFIG=Release


rem ***********************************************************
rem * Package things up
rem ***********************************************************

echo.
echo CREATING PACKAGE...
echo.

cd bin
7z a -tzip ..\..\premake-win32-%1.zip premake.exe


rem ***********************************************************
rem * Clean up
rem ***********************************************************

echo.
echo CLEANING UP...
echo.

cd ..\..
rmdir /s /q Premake-%1


rem ***********************************************************
rem * Upload to SF.net
rem ***********************************************************

echo.
echo Ready to upload package to SourceForce, press ^^C to abort.
pause

ftp -s:ftp_msw.txt upload.sourceforge.net
goto done


rem ***********************************************************
rem * Error messages
rem ***********************************************************

:show_usage
echo Usage: msw.bat version_number
goto done

:done
