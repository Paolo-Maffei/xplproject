/*
'* xPL CM11
'*
'* Written by Tom Van den Panhuyzen
'* Version 1.00 - 5/feb/2005
'* Version 1.01 - 20/mar/2005  (modified timeout settings)
'* Version 1.02 - 02/oct/2005  (recompiled with xpllib V4.1)
'* Version 1.03 - 16/dec/2005  (PREDIM1/2 now use the level attribute)
'* Version 1.04 - 11/feb/2007  (no more timeout when sending commands to the CM11 while a message arrives at powerline)
'* Version 1.05 - 01/aug/2008  (recompiled with xpllib V4.4)
'*
'* For more information on the serial communications library (CommBase), see:
'* "Serial Comm: Use P/Invoke to Develop a .NET Base Class Library
'* for Serial Device Communications" John Hind, MSDN Magazine, Oct 2002
'*
'*/

/*
 Copyright 2007, 2008 Tom Van den Panhuyzen
 tomvdp at gmail(dot)com
 http://blog.boxedbits.com/xpl
 
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

using System.Reflection;
using System.Runtime.CompilerServices;

[assembly: AssemblyTitle("XPLCM11")]
[assembly: AssemblyDescription("")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("Medusa")]
[assembly: AssemblyProduct("")]
[assembly: AssemblyCopyright("")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]		

//
// Version information for an assembly consists of the following four values:
//
//      Major Version
//      Minor Version 
//      Build Number
//      Revision
//
// You can specify all the values or you can default the Revision and Build Numbers 
// by using the '*' as shown below:

[assembly: AssemblyVersion("1.05.*")]

//
// In order to sign your assembly you must specify a key to use. Refer to the 
// Microsoft .NET Framework documentation for more information on assembly signing.
//
// Use the attributes below to control which key is used for signing. 
//
// Notes: 
//   (*) If no key is specified, the assembly is not signed.
//   (*) KeyName refers to a key that has been installed in the Crypto Service
//       Provider (CSP) on your machine. KeyFile refers to a file which contains
//       a key.
//   (*) If the KeyFile and the KeyName values are both specified, the 
//       following processing occurs:
//       (1) If the KeyName can be found in the CSP, that key is used.
//       (2) If the KeyName does not exist and the KeyFile does exist, the key 
//           in the KeyFile is installed into the CSP and used.
//   (*) In order to create a KeyFile, you can use the sn.exe (Strong Name) utility.
//       When specifying the KeyFile, the location of the KeyFile should be
//       relative to the project output directory which is
//       %Project Directory%\obj\<configuration>. For example, if your KeyFile is
//       located in the project directory, you would specify the AssemblyKeyFile 
//       attribute as [assembly: AssemblyKeyFile("..\\..\\mykey.snk")]
//   (*) Delay Signing is an advanced option - see the Microsoft .NET Framework
//       documentation for more information on this.
//
[assembly: AssemblyDelaySign(false)]
[assembly: AssemblyKeyFile("")]
[assembly: AssemblyKeyName("")]
