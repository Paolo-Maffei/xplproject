How to create a new release;

1 - Update version numbering in code
      - check the assembly info on the project tab (the build number is going to be the build number
        shown +1 if auto increment is used)
      - update all code; comments at the top include version info to be updated
      - update xPL_Base module: constant XPL_LIB_VERSION

2 - Verify that the following methods;
      - xPLDevice.New(ByVal SavedState As String, ByVal RestoreEnabled As Boolean)
      - xPLListener.RestoreFromState(ByVal SavedState As String, ByVal RestoreEnabled As Boolean)
    are capable of parsing any changes in the State strings, as they include version info.
    
2 - update the readme file, with changelog for buildnumber xxx

3 - set type to "release" and Rebuild solution

4 - commit changes to SVN repository, and create a new TAG for the new release

5 - exit Visual Studio, saving any changes

6 - package the following files from the bin/release folder
       xpllib.dll        : the actual library
       xpllib.xml        : documentation file
       gpl.txt           : license document
       readme.txt        : readme documentation

7 - publish the package on the website

8 - update the xml plugin file with the updated versions


