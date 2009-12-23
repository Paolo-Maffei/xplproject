using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing;
using System.Diagnostics;

namespace xPLHalScriptHelper {
    class CloseLabel : Label {
        public CloseLabel() {
            this.BackColor = System.Drawing.Color.Transparent;
            this.Font = new System.Drawing.Font("Webdings", 8.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(2)));
            this.Location = new System.Drawing.Point(591, 76);
            this.Name = "label1";
            this.Size = new System.Drawing.Size(19, 18);
            this.TabIndex = 5;
            this.Text = "r";
            this.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.MouseLeave += new EventHandler(CloseLabel_MouseLeave);
            this.MouseMove += new MouseEventHandler(CloseLabel_MouseMove);
        }

        void CloseLabel_MouseMove(object sender, MouseEventArgs e) {
            this.BackColor = Color.FromKnownColor(KnownColor.GradientActiveCaption);
        }

        void CloseLabel_MouseLeave(object sender, EventArgs e) {
            this.BackColor = Color.Transparent;
        }
    }
}
