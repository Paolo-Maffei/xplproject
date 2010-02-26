How to update the solution
==========================

The Solution consists of 3 projects;
 - xPLHubVerifier; the actual application doing the checks and containing the installers of 
            the Hub and Diag tools.
 - xPLCheckPackage; a wrapper, a single EXE that is the main application of this solution.
            It contains the output of xPLHubVerifier.
 - xPLCheckPackageMM; Deployment project that generates a Merge Module, which can be integrated
            when distributing other applications

Mind the dependencies:
The 'xPLCheckPackage' project has both a prebuild and postbuild command;
 - Prebuild: getting the output of xPLHubVerifier
 - Postbuild: storing its own output at the xPLCheckPackageMM project
The 'xPLCheckPackageMM' project has a postbuild command
 - Postbuild: opens the final .msm file in Orca for the required manual update of the "KeyPath"

Solution build order is; xPLHubVerifier -> xPLCheckPackage -> xPLCheckPackageMM

To build the solution;
1) You must rebuild the entire solution (all three projects)
2) When the build is complete the "KeyPath" must be removed from the MergeModule before it can
   be used. If you don't, then everytime the application (that uses this mergemodule) is being 
   started, the windows installer popsup and starts a repair action (based upon the "KeyPath").
   To remove the KeyPath, edit the final .msm file in Orca (Orca is a tool thats available in
   Windows SDK, free download from Microsoft).
     - Open the .MSM file with Orca
     - On the left hand side click the table "Component"
     - On the right hand side, the table will now show a single row, with one column
       named "KeyPath"
     - Select the row, and edit the value under "KeyPath", remove the value (empty)
     - Save the file and exit.
   The .MSM merge module is now ready for distribution. Follow the instructions in the readme
   file on how to integrate the mergemodule into your application.
