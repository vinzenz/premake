#!/bin/sh
###################################################################
# Premake Source Code and Linux Binary Release Script
# Originally written by Jason Perkins (starkos@gmail.com)
#
# Prerequisites:
#  svn, zip
###################################################################

# Check arguments
if [ $# -ne 1 ]; then
  echo 1>&2 "Usage: $0 version_number"
  exit 1
fi


###################################################################
# Pre-build checklist
###################################################################

echo "" 
echo "STARTING PREBUILD CHECKLIST, PRESS ^^C TO ABORT."
echo ""
echo "Is the version number '$1' correct?"
read line
echo ""
echo "Have you created a release branch named '$1' in SVN?"
read line
echo ""
echo "Have you run all of the tests?"
read line
echo ""
echo "Is the version number in premake.c correct?"
read line
echo ""
echo "Is README.txt up to date?"
read line
echo ""
echo "Is CHANGES.txt up to date?"
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

svn export https://premake.svn.sourceforge.net/svnroot/premake/branches/$1 Premake-$1

echo ""
echo "REMOVING PRIVATE FILES..."
echo ""

cd Premake-$1
rm -rf Scripts
rm -f  TODO.txt


#####################################################################
# Stage 2: Source Code Package
#####################################################################

echo ""
echo "PACKAGING SOURCE CODE..."
echo ""

premake --os linux --target gnu
premake --os windows --target vs6
premake --os windows --target vs2002

unix2dos Premake.dsw
unix2dos Premake.sln
unix2dos Src/Premake.dsp
unix2dos Src/Premake.vcproj

cd ..
zip -r9 premake-src-$1.zip Premake-$1/*


#####################################################################
# Stage 3: Binary Package
#####################################################################

echo ""
echo "BUILDING RELEASE BINARY..."
echo ""

cd Premake-$1
make CONFIG=Release


#####################################################################
# Stage 4: Pack Release
#####################################################################

cd bin
tar czvf ../../premake-linux-$1.tar.gz premake


#####################################################################
# Stage 5: Publish Files
#
# Send the files to SourceForge
#####################################################################

cd ../.. 
echo ""
echo "Upload packages to SourceForge?"
read line
if [ $line = "y" ]; then
	echo "Uploading to SourceForge..."
	ftp -n -p upload.sourceforge.net < ftp_x11.txt
fi


#####################################################################
# All done
#####################################################################

echo ""
echo "CLEANING UP..."
echo ""
cd ../..
rm -rf Premake-$1

