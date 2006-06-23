#!/bin/sh

script_dir=`pwd`

# Make sure a build number is supplied
if [ $# -ne 1 ]; then
  echo 1>&2 "Usage: $0 version"
  exit 1
fi

echo "POSIX BUILD $1"
echo ""

# Make sure all prerequisites are met
echo "Did you test against EVERY project?"
read line
echo ""
echo "Did you create a release branch?"
read line
echo ""
echo "Have you updated the version number in premake.c?"
read line
echo ""
echo "Did you update README.txt?"
read line
echo ""
echo "Did you update CHANGES.txt?"
read line
echo ""
echo "Ready to build Source Code and POSIX executable for version $1."
echo "Press [Enter] to begin."
read line


#####################################################################
# Stage 1: Preparation
#
# Pull the source code from Subversion.
#####################################################################

echo ""
echo "RETRIEVING SOURCE CODE FROM REPOSITORY..."
echo ""
cd ../..
svn co https://svn.berlios.de/svnroot/repos/premake/Branches/$1 Premake-$1

echo ""
echo "REMOVING PRIVATE FILES..."
echo ""

cd Premake-$1
rm -rf `find . -name .svn`
rm -rf Scripts
rm -f  TODO.txt


#####################################################################
# Stage 2: Source Code Package
#####################################################################

echo ""
echo "PACKAGING SOURCE CODE..."
echo ""

premake --os linux --target gnu
premake --target vs6
premake --target vs2002

unix2dos Premake.dsw
unix2dos Premake.sln
unix2dos Src/Premake.dsp
unix2dos Src/Premake.vcproj

cd ..
zip -r9 $script_dir/premake-src-$1.zip Premake-$1/*


#####################################################################
# Stage 3: Binary Package
#####################################################################

echo ""
echo "BUILDING RELEASE BINARY..."
echo ""

cd Premake-$1
premake --target gnu
make CONFIG=Release


#####################################################################
# Stage 4: Pack Release
#####################################################################

cd bin
tar czvf $script_dir/premake-linux-$1.tar.gz premake


#####################################################################
# Stage 5: Publish Files
#
# Send the files to SourceForge
#####################################################################

cd $script_dir
echo ""
echo "Upload packages to SourceForge?"
read line
if [ $line = "y" ]; then
	echo "Uploading to SourceForge..."
	ftp -n upload.sourceforge.net < ftp_x11.txt
fi


#####################################################################
# All done
#####################################################################

echo ""
echo "CLEANING UP..."
echo ""
cd ../..
rm -rf Premake-$1

cd $script_dir
echo ""
echo "Done - NOW CREATE A TAG"

