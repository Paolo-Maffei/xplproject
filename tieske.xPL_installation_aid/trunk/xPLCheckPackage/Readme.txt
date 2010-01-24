
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
