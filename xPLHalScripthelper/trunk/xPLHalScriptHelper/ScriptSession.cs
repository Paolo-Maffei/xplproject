using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Management.Automation.Runspaces;
using System.Management.Automation;

namespace xPLHalScriptHelper {
    public class ScriptSession {
        Runspace runspace;
        private bool isNewScript;

        bool SETTING_ALWAYS_INIT_RUNSPACE = true;

        public DebugScriptInfo ScriptInfo { get; set; }
        public bool IsNewScript { get { return isNewScript; } }

        /// <summary>
        /// C'tor
        /// </summary>
        /// <param name="dsi"></param>
        public ScriptSession(DebugScriptInfo dsi) {
            if (dsi.SourceFile == null) {
                //new script
                dsi.ScriptName = "New Script";
                isNewScript = true;
            }
            
            ScriptInfo = dsi;
        }
        
        private void InitRunSpace() {
            //create Powershell runspace
            runspace = null;
            runspace = RunspaceFactory.CreateRunspace();
            runspace.Open();

            //expose the xPL message this rule reacted on
            if (ScriptInfo.xPLMessageString != null) {
                XplMsg xpl = new XplMsg(ScriptInfo.xPLMessageString);
                runspace.SessionStateProxy.SetVariable("Msg", xpl);
            } else {
                //provide the object anyway
                runspace.SessionStateProxy.SetVariable("Msg", null);
            }

            runspace.SessionStateProxy.SetVariable("Sys", new Sys(ScriptInfo.HalIPAddress));
        }

        public string RunScript(string scriptSource) {
            if (scriptSource.Trim().Length == 0)
                return String.Empty;

            if (runspace == null || SETTING_ALWAYS_INIT_RUNSPACE)
                InitRunSpace();

            Pipeline pipeline = runspace.CreatePipeline();

            pipeline.Commands.AddScript(ScriptInfo.GlobalScriptSource);
            pipeline.Commands.AddScript(scriptSource);

            //add extra command to transform the script output
            //objects into nicely formatted strings
            pipeline.Commands.Add("Out-String");

            //Merge all buffers
            pipeline.Commands[0].MergeMyResults(PipelineResultTypes.Error, PipelineResultTypes.Output);

            try {
                var results = pipeline.Invoke();
                //convert the script result into a single string
                System.Text.StringBuilder stringBuilder = new System.Text.StringBuilder();
                foreach (PSObject obj in results) {
                    stringBuilder.AppendLine(obj.ToString());
                }
                return stringBuilder.ToString();
            } catch (Exception ex) {
                return ex.Message;
            } finally {
                if (SETTING_ALWAYS_INIT_RUNSPACE) {
                    runspace.Close();
                }
            }
        }


        internal bool SaveScript() {
            if (ScriptInfo.HalIPAddress != null) {
                Sys ho = new Sys(ScriptInfo.HalIPAddress);
                if (ScriptInfo.SourceFile == null) {
                    //new file..
                    using (frmSaveDialog dlg = new frmSaveDialog()) {
                        if (dlg.ShowDialog() == System.Windows.Forms.DialogResult.OK) {
                            ScriptInfo.SourceFile = dlg.textBox1.Text;
                        }
                    }
                }

                //try to save
                object retval = ho.PutScript(ScriptInfo.SourceFile, ScriptInfo.ModifiedScript);
                if ((bool)retval == true) return true; //ok

                if (retval.ToString() != "")
                    throw new Exception(retval.ToString());
            }

            return false;
        }

        internal bool ReloadScripts() {
            if (ScriptInfo.HalIPAddress != null) {
                Sys ho = new Sys(ScriptInfo.HalIPAddress);
                return (bool)ho.ReloadScripts();
            }

            return false;
        }
    }
}
