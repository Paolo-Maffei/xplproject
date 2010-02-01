How to update the solution
==========================

The Solution consists of 4 projects;
 - xPLHubVerifier; the actual application doing the checks and containing the installers of 
            the Hub and Diag tools.
 - xPLCheckPackage; a wrapper, a single EXE that is the main result of this solution. It 
            can be added to a deployment project for distribution with xPL applications.
            It contains the output of xPLHubVerifier.
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


Adding the xPL check package to the installation of your xPL application
========================================================================

 1) add an 'Installer Class' to your project
       - right click the project; Add - New Item...
       - in VS2008 go to category 'Common items - General'
       - select "Installer class"

 2) Open Installer code
       - Rightclick newly added installer and select 'View Code'

 3) add/update the code of this class
       - Rightclick the Installer1.vb file of the 'Demo_Project_Empty' project
         and select 'view code'
       - copy the 'Sub Commit' and paste it into the code file opened in step 2
 
  4) In your projects deployment project go to the File System Editor
        - Right click "File System on Target Machine"
        - select Add Special Folder - Program Files folder
        - Right click the added branch in the tree and select Add - File...
        - browse to the "xPLCheckPackage.exe" and add it.
        
  5) In your projects deployement project go to the Custom Actions Editor
        - Right click the 'Install' branch and click Add custom action
        - In the dialog select the 'Application folder' and from that folder select the primary output
        - Repeat these 2 steps for the 'Commit' branch
        
Now rebuild the solution and the deployment project, when you now install the application it will end
with the xPL network check prompt.
