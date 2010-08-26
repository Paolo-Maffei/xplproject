/*
'* xPL CM11
'*
'* Written by Tom Van den Panhuyzen
'* Version 1.00 - 5/feb/2005
'* Version 1.01 - 20/mar/2005  (modified timeout settings)
'* Version 1.02 - 02/oct/2005  (recompiled with xpllib V4.1)
'* Version 1.03 - 16/dec/2005  (PREDIM1/2 now use the level attribute)
'* Version 1.04 - 11/feb/2007  (no more timeout when sending commands to the CM11 while a message arrives at powerline)
'*
'* For more information on the serial communications library (CommBase), see:
'* "Serial Comm: Use P/Invoke to Develop a .NET Base Class Library
'* for Serial Device Communications" John Hind, MSDN Magazine, Oct 2002
'*
'*/

/*
 Copyright 2007 Tom Van den Panhuyzen
 
 This file is part of Medusa.XPLCM11.

    Medusa.XPLCM11 is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    Medusa.XPLCM11 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
using System;
using System.Collections;
using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace Medusa.XPLCM11
{
	/// <summary>
	/// Summary description for ProjectInstaller.
	/// </summary>
	[RunInstaller(true)]
	public class ProjectInstaller : System.Configuration.Install.Installer
	{
		private System.ServiceProcess.ServiceProcessInstaller serviceProcessInstaller1;
		private System.ServiceProcess.ServiceInstaller serviceInstaller1;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public ProjectInstaller()
		{
			// This call is required by the Designer.
			InitializeComponent();

			// TODO: Add any initialization after the InitializeComponent call
		}

		/// <summary> 
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if(components != null)
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}


		#region Component Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.serviceProcessInstaller1 = new System.ServiceProcess.ServiceProcessInstaller();
			this.serviceInstaller1 = new System.ServiceProcess.ServiceInstaller();
			// 
			// serviceProcessInstaller1
			// 
			this.serviceProcessInstaller1.Account = System.ServiceProcess.ServiceAccount.LocalSystem;
			this.serviceProcessInstaller1.Password = null;
			this.serviceProcessInstaller1.Username = null;
			// 
			// serviceInstaller1
			// 
			this.serviceInstaller1.ServiceName = "XPLCM11";
			this.serviceInstaller1.StartType = System.ServiceProcess.ServiceStartMode.Automatic;
			this.serviceInstaller1.BeforeUninstall += new System.Configuration.Install.InstallEventHandler(this.serviceInstaller1_BeforeUninstall);
			this.serviceInstaller1.AfterInstall += new System.Configuration.Install.InstallEventHandler(this.serviceInstaller1_AfterInstall);
			// 
			// ProjectInstaller
			// 
			this.Installers.AddRange(new System.Configuration.Install.Installer[] {
																					  this.serviceProcessInstaller1,
																					  this.serviceInstaller1});

		}
		#endregion

		private void serviceInstaller1_AfterInstall(object sender, System.Configuration.Install.InstallEventArgs e)
		{
			try
			{
				ServiceController s = new ServiceController("XPLCM11");
				s.Start();
			}
			catch{}

		}

		private void serviceInstaller1_BeforeUninstall(object sender, System.Configuration.Install.InstallEventArgs e)
		{
			try
			{
				ServiceController s = new ServiceController("XPLCM11");
				if (s.Status!=ServiceControllerStatus.Stopped)
				{
					s.Stop();
					s.WaitForStatus(ServiceControllerStatus.Stopped);
				}
			}
			catch{}
		}
	}
}
