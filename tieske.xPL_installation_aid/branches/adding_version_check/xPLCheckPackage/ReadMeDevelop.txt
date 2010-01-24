How to update the solution;

The Solution consists of 4 projects;
 - xPLHubVerifier; the actual application doing the checks and containing the installers
 - xPLCheckPackage; a wrapper, a single EXE that is the main result of this solution. It 
            can be added to a deployment project for distribution with xPL applications.
            It contains the output op xPLHubVerifier.
 - Demo_Project_Empty; empty demo project, just for test purposes, but also contains the specific
            code required in the 'Installer class'. (demonstrates how to do it)
 - Demo_Project_Installer; deployement project for Demo_Project_Empty, to be used for testing 
            (demonstrates how to do it)

Mind the dependencies:
The 'xPLCheckPackage' project has both a prebuild and postbuild command;
 - Prebuild: getting the output of xPLHubVerifier
 - Postbuild: storing its own output at the Demo_Project_Installer
Build order is; xPLHubVerifier -> xPLCheckPackage -> Demo_Project_Empty -> Demo_Project_Installer

You must rebuild the entire solution!