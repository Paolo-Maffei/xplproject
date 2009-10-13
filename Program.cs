using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Threading;

namespace xPLBalloon
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            bool newMutexCreated = false;
            string mutexName = "Local\\" + System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;

            Mutex mutex = null;
            try
            {
                // Create a new mutex object with a unique name
                mutex = new Mutex(false, mutexName, out newMutexCreated);
            }
            catch (Exception ex)
            {
                Application.Exit();
            }

            // When the mutex is created for the first time
            // we run the program since it is the first instance.
            if (newMutexCreated)
            {            
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new frmxPLBalloon());
            }
        }
    }
}
