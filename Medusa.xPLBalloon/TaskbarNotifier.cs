// C# TaskbarNotifier Class v1.0
// by John O'Byrne - 02 december 2002
// 01 april 2003 : Small fix in the OnMouseUp handler
// 11 january 2003 : Patrick Vanden Driessche  added a few enhancements
//           Small Enhancements/Bugfix
//           Small bugfix: When Content text measures larger than the corresponding ContentRectangle
//                         the focus rectangle was not correctly drawn. This has been solved.
//           Added KeepVisibleOnMouseOver
//           Added ReShowOnMouseOver
//           Added If the Title or Content are too long to fit in the corresponding Rectangles,
//                 the text is truncateed and the ellipses are appended (StringTrimming).
// Rev 003-CrustyAppleSniffer: Sliding or fading effect
// Rev 004-CrustyAppleSniffer: New Property: Padding
// Rev 005-CrustyAppleSniffer: New feature: Management of Toasts' Collection and last position storage
// Rev 006-CrustyAppleSniffer: New feature: Content alignement
// Rev 007-Tom VdP: Deleted the ability to move the notifiers (added in Rev 005), added ShowNoActivate()
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace CustomUIControls
{
    /// 
    /// TaskbarNotifier allows to display Skinned instant messaging popups
    /// 
    public class TaskbarNotifier : Form
    {
        #region TaskbarNotifier Protected Members
        protected Bitmap BackgroundBitmap = null;
        protected Bitmap CloseBitmap = null;
        protected Point CloseBitmapLocation;
        protected Size CloseBitmapSize;
        protected Rectangle RealTitleRectangle;
        protected Rectangle RealContentRectangle;
        protected Rectangle WorkAreaRectangle;
        protected Timer timer = new Timer();
        protected TaskbarStates taskbarState = TaskbarStates.hidden;
        protected string titleText;
        protected string contentText;
        protected Color normalTitleColor = Color.FromArgb(255, 255, 255);
        protected Color hoverTitleColor = Color.FromArgb(255, 0, 0);
        protected Color normalContentColor = Color.FromArgb(0, 0, 0);
        protected Color hoverContentColor = Color.FromArgb(0, 0, 0x66);
        protected Font normalTitleFont = new Font("Arial", 11, FontStyle.Regular | FontStyle.Bold, GraphicsUnit.Pixel);
        protected Font hoverTitleFont = new Font("Arial", 12, FontStyle.Bold, GraphicsUnit.Pixel);
        protected Font normalContentFont = new Font("Arial", 11, FontStyle.Regular, GraphicsUnit.Pixel);
        protected Font hoverContentFont = new Font("Arial", 11, FontStyle.Regular, GraphicsUnit.Pixel);
        protected int nShowEvents;
        protected int nHideEvents;
        protected int nVisibleEvents;
        protected int nIncrementShow;
        protected int nIncrementHide;
        protected bool bIsMouseOverPopup = false;
        protected bool bIsMouseOverClose = false;
        protected bool bIsMouseOverContent = false;
        protected bool bIsMouseOverTitle = false;
        protected bool bIsMouseDown = false;
        protected bool bKeepVisibleOnMouseOver = true;		// Added Rev 002
        protected bool bReShowOnMouseOver = false;		// Added Rev 002
        protected bool bAppearBySliding = true;		// Rev 003-CAS: Sliding or fading effect
        protected int nPadding = 10;				// Rev 004-CAS: New Property: Padding
        protected int nBaseWindowBottom = 0;			// Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
        protected int nBaseWindowRight = 0;			// Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
        protected ToastCollection colBase = null;		// Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
        protected bool bMoving = false;			// Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
        protected int nMouseDownX;				// Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
        protected int nMouseDownY;				// Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
        protected ContentAlignment caContentAlignement;         // Rev 006-CAS: New feature: Content alignement

        #endregion

        public void ShowNoActivate()
        {
            ShowWindow(Handle, 4);//SW_SHOWNOACTIVATE
        }
        protected override void SetVisibleCore(bool value)
        {
            if (value)
            {
                ShowWindow(Handle, 4);//SW_SHOWNOACTIVATE
            }
            else base.SetVisibleCore(value);
        }

        [DllImport("user32.dll")]
        private extern static int ShowWindow(IntPtr hWnd, int nCmdShow);

        #region TaskbarNotifier Public Members
        public Rectangle TitleRectangle;
        public Rectangle ContentRectangle;
        public bool TitleClickable = false;
        public bool ContentClickable = true;
        public bool CloseClickable = true;
        public bool EnableSelectionRectangle = true;
        public event EventHandler CloseClick = null;
        public event EventHandler TitleClick = null;
        public event EventHandler ContentClick = null;
        #endregion

        #region TaskbarNotifier Enums
        /// 
        /// List of the different popup animation status
        /// 
        public enum TaskbarStates
        {
            hidden = 0,
            appearing = 1,
            visible = 2,
            disappearing = 3
        }
        #endregion

        #region TaskbarNotifier Constructor
        /// 
        /// The Constructor for TaskbarNotifier
        /// 
        public TaskbarNotifier()
        {
            // Window Style
            FormBorderStyle = FormBorderStyle.None;
            WindowState = FormWindowState.Minimized;
            //-CAS 29/08/2007: avoid taskbar flickering each time a Notifier is displayed
            // base.Show();
            base.Hide();
            WindowState = FormWindowState.Normal;
            ShowInTaskbar = false;
            TopMost = true;
            MaximizeBox = false;
            MinimizeBox = false;
            ControlBox = false;

            timer.Enabled = true;
            timer.Tick += new EventHandler(OnTimer);
        }
        #endregion

        #region TaskbarNotifier Properties
        /// 
        /// Get the current TaskbarState (hidden, showing, visible, hiding)
        /// 
        public TaskbarStates TaskbarState
        {
            get
            {
                return taskbarState;
            }
        }

        /// 
        /// Get/Set the popup Title Text
        /// 
        public string TitleText
        {
            get
            {
                return titleText;
            }
            set
            {
                titleText = value;
                Refresh();
            }
        }

        /// 
        /// Get/Set the popup Content Text
        /// 
        public string ContentText
        {
            get
            {
                return contentText;
            }
            set
            {
                contentText = value;
                Refresh();
            }
        }

        /// 
        /// Get/Set the Normal Title Color
        /// 
        public Color NormalTitleColor
        {
            get
            {
                return normalTitleColor;
            }
            set
            {
                normalTitleColor = value;
                Refresh();
            }
        }

        /// 
        /// Get/Set the Hover Title Color
        /// 
        public Color HoverTitleColor
        {
            get
            {
                return hoverTitleColor;
            }
            set
            {
                hoverTitleColor = value;
                Refresh();
            }
        }

        /// 
        /// Get/Set the Normal Content Color
        /// 
        public Color NormalContentColor
        {
            get
            {
                return normalContentColor;
            }
            set
            {
                normalContentColor = value;
                Refresh();
            }
        }

        /// 
        /// Get/Set the Hover Content Color
        /// 
        public Color HoverContentColor
        {
            get
            {
                return hoverContentColor;
            }
            set
            {
                hoverContentColor = value;
                Refresh();
            }
        }

        /// 
        /// Get/Set the Normal Title Font
        /// 
        public Font NormalTitleFont
        {
            get
            {
                return normalTitleFont;
            }
            set
            {
                normalTitleFont = value;
                Refresh();
            }
        }

        /// 
        /// Get/Set the Hover Title Font
        /// 
        public Font HoverTitleFont
        {
            get
            {
                return hoverTitleFont;
            }
            set
            {
                hoverTitleFont = value;
                Refresh();
            }
        }

        /// 
        /// Get/Set the Normal Content Font
        /// 
        public Font NormalContentFont
        {
            get
            {
                return normalContentFont;
            }
            set
            {
                normalContentFont = value;
                Refresh();
            }
        }

        /// 
        /// Get/Set the Hover Content Font
        /// 
        public Font HoverContentFont
        {
            get
            {
                return hoverContentFont;
            }
            set
            {
                hoverContentFont = value;
                Refresh();
            }
        }

        /// 
        /// Indicates if the popup should remain visible when the mouse pointer is over it.
        /// Added Rev 002
        /// 
        public bool KeepVisibleOnMousOver
        {
            get
            {
                return bKeepVisibleOnMouseOver;
            }
            set
            {
                bKeepVisibleOnMouseOver = value;
            }
        }

        /// 
        /// Indicates if the popup should appear again when mouse moves over it while it's disappearing.
        /// Added Rev 002
        /// 
        public bool ReShowOnMouseOver
        {
            get
            {
                return bReShowOnMouseOver;
            }
            set
            {
                bReShowOnMouseOver = value;
            }
        }

        /// 
        /// Indicates if the popup should diplayed with fadding or slidding effect
        /// Added Rev 003-CAS
        /// 
        public bool AppearBySliding
        {
            get
            {
                return bAppearBySliding;
            }
            set
            {
                bAppearBySliding = value;
            }
        }
        /// 
        /// Get/Set the popup padding (distance between 2 popups)
        /// Added Rev 004-CAS: New Property: Padding
        /// 
        public new int Padding
        {
            get
            {
                return nPadding;
            }
            set
            {
                nPadding = value;
                Refresh();
            }
        }
        /// 
        /// Get/Set the popup distance from the working area bottom border due to popup stacking
        /// Added Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
        /// 
        public int BaseWindowBottom
        {
            get
            {
                return nBaseWindowBottom;
            }
            set
            {
                nBaseWindowBottom = value;
                Refresh();
            }
        }
        /// 
        /// Get/Set the popup distance from the working area right border due to popup stacking
        /// Added Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
        /// 
        public int BaseWindowRight
        {
            get
            {
                return nBaseWindowRight;
            }
            set
            {
                nBaseWindowRight = value;
                Refresh();
            }
        }
        /// 
        /// Get/Set the toast collection the popup belongs to
        /// Added Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
        /// 
        public ToastCollection Base
        {
            get
            {
                return colBase;
            }
            set
            {
                colBase = value;
                Refresh();
            }
        }
        /// 
        /// Get/Set the Content alignement property
        /// Added Rev 006-CAS: New feature: Content alignement
        /// 
        public ContentAlignment ContentTextAlignement
        {
            get
            {
                return caContentAlignement;
            }
            set
            {
                caContentAlignement = value;
                Refresh();
            }
        }
        #endregion

        #region TaskbarNotifier Public Methods
        //[DllImport("user32.dll")]
        //private static extern Boolean ShowWindow(IntPtr hWnd, Int32 nCmdShow);
        /// 
        /// Displays the popup for a certain amount of time
        /// 
        /// The string which will be shown as the title of the popup
        /// The string which will be shown as the content of the popup
        /// Duration of the showing animation (in milliseconds)
        /// Duration of the visible state before collapsing (in milliseconds)
        /// Duration of the hiding animation (in milliseconds)
        /// Nothing
        public void Show(string strTitle, string strContent, int nTimeToShow, int nTimeToStay, int nTimeToHide)
        {
            WorkAreaRectangle = Screen.GetWorkingArea(WorkAreaRectangle);
            titleText = strTitle;
            contentText = strContent;
            nVisibleEvents = nTimeToStay;
            CalculateMouseRectangles();

            // We calculate the pixel increment and the timer value for the showing animation
            int nEvents = 0;
            if (nTimeToShow > 10)
            {
                nEvents = Math.Min((nTimeToShow / 10), BackgroundBitmap.Height);
                nShowEvents = nTimeToShow / nEvents;
                nIncrementShow = BackgroundBitmap.Height / nEvents;
            }
            else
            {
                nShowEvents = 10;
                nIncrementShow = BackgroundBitmap.Height;
            }

            // We calculate the pixel increment and the timer value for the hiding animation
            if (nTimeToHide > 10)
            {
                nEvents = Math.Min((nTimeToHide / 10), BackgroundBitmap.Height);
                nHideEvents = nTimeToHide / nEvents;
                nIncrementHide = BackgroundBitmap.Height / nEvents;
            }
            else
            {
                nHideEvents = 10;
                nIncrementHide = BackgroundBitmap.Height;
            }

            // Added Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
            if (colBase != null)
                colBase.AddToast(this, this.WorkAreaRectangle.Height,
                                ref nBaseWindowBottom, ref nBaseWindowRight);


            switch (taskbarState)
            {
                case TaskbarStates.hidden:
                    taskbarState = TaskbarStates.appearing;
                    // Updated Rev 003-CAS: Sliding or fading effect
                    if (bAppearBySliding)
                    {
                        // Added Rev 003-CAS: Sliding or fading effect						
                        this.Opacity = 1.0;
                        // Updated Rev 004-CAS: New Property: Padding
                        // Updated Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
                        SetBounds(WorkAreaRectangle.Right - BackgroundBitmap.Width - nPadding - nBaseWindowRight,
                            WorkAreaRectangle.Bottom,
                            BackgroundBitmap.Width, 0);
                    }
                    else
                    {
                        // Added Rev 003-CAS: Sliding or fading effect
                        this.Opacity = 0.0;
                        // Updated Rev 004-CAS: New Property: Padding
                        // Updated Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
                        SetBounds(WorkAreaRectangle.Right - BackgroundBitmap.Width - nPadding - nBaseWindowRight,
                              WorkAreaRectangle.Bottom - BackgroundBitmap.Height - nPadding - nBaseWindowBottom,
                              BackgroundBitmap.Width, BackgroundBitmap.Height);

                    }
                    timer.Interval = nShowEvents;
                    timer.Start();

                    // We Show the popup without stealing focus
                    //ShowWindow(this.Handle, 4);
                    ShowNoActivate();
                    break;

                case TaskbarStates.appearing:
                    Refresh();
                    break;

                case TaskbarStates.visible:
                    timer.Stop();
                    timer.Interval = nVisibleEvents;
                    timer.Start();
                    Refresh();
                    break;

                case TaskbarStates.disappearing:
                    timer.Stop();
                    taskbarState = TaskbarStates.visible;
                    // Updated Rev 003-CAS: Sliding or fading effect
                    if (bAppearBySliding)
                    {
                        // Updated Rev 004-CAS: New Property: Padding
                        // Updated Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
                        SetBounds(WorkAreaRectangle.Right - BackgroundBitmap.Width - nPadding - nBaseWindowRight,
                            WorkAreaRectangle.Bottom - BackgroundBitmap.Height - nPadding - nBaseWindowBottom,
                            BackgroundBitmap.Width, BackgroundBitmap.Height);
                    }
                    else
                    {
                        // Updated Rev 004-CAS: New Property: Padding
                        // Updated Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
                        SetBounds(WorkAreaRectangle.Right - BackgroundBitmap.Width - nPadding - nBaseWindowRight,
                            WorkAreaRectangle.Bottom - nPadding - nBaseWindowBottom,
                            BackgroundBitmap.Width, 0);
                    }
                    timer.Interval = nVisibleEvents;
                    timer.Start();
                    Refresh();
                    break;
            }
        }

        /// 
        /// Hides the popup
        /// 
        /// Nothing
        public new void Hide()
        {
            if (taskbarState != TaskbarStates.hidden)
            {
                timer.Stop();
                taskbarState = TaskbarStates.hidden;
                base.Hide();
                // Added Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
                if (colBase != null)
                    colBase.KillWindow(this);
            }
        }
        /// 
        /// Sets the background bitmap and its transparency color
        /// 
        /// Path of the Background Bitmap on the disk
        /// Color of the Bitmap which won't be visible
        /// Nothing
        public void SetBackgroundBitmap(string strFilename, Color transparencyColor)
        {
            BackgroundBitmap = new Bitmap(strFilename);
            Width = BackgroundBitmap.Width;
            Height = BackgroundBitmap.Height;
            Region = BitmapToRegion(BackgroundBitmap, transparencyColor);
        }

        /// 
        /// Sets the background bitmap and its transparency color
        /// 
        /// Image/Bitmap object which represents the Background Bitmap
        /// Color of the Bitmap which won't be visible
        /// Nothing
        public void SetBackgroundBitmap(Image image, Color transparencyColor)
        {
            BackgroundBitmap = new Bitmap(image);
            Width = BackgroundBitmap.Width;
            Height = BackgroundBitmap.Height;
            Region = BitmapToRegion(BackgroundBitmap, transparencyColor);
        }

        /// 
        /// Sets the 3-State Close Button bitmap, its transparency color and its coordinates
        /// 
        /// Path of the 3-state Close button Bitmap on the disk (width must a multiple of 3)
        /// Color of the Bitmap which won't be visible
        /// Location of the close button on the popup
        /// Nothing
        public void SetCloseBitmap(string strFilename, Color transparencyColor, Point position)
        {
            CloseBitmap = new Bitmap(strFilename);
            CloseBitmap.MakeTransparent(transparencyColor);
            CloseBitmapSize = new Size(CloseBitmap.Width / 3, CloseBitmap.Height);
            CloseBitmapLocation = position;
        }

        /// 
        /// Sets the 3-State Close Button bitmap, its transparency color and its coordinates
        /// 
        /// Image/Bitmap object which represents the 3-state Close button Bitmap (width must be a multiple of 3)
        /// Color of the Bitmap which won't be visible
        /// /// Location of the close button on the popup
        /// Nothing
        public void SetCloseBitmap(Image image, Color transparencyColor, Point position)
        {
            CloseBitmap = new Bitmap(image);
            CloseBitmap.MakeTransparent(transparencyColor);
            CloseBitmapSize = new Size(CloseBitmap.Width / 3, CloseBitmap.Height);
            CloseBitmapLocation = position;
        }
        #endregion

        #region TaskbarNotifier Protected Methods
        protected void DrawCloseButton(Graphics grfx)
        {
            if (CloseBitmap != null)
            {
                Rectangle rectDest = new Rectangle(CloseBitmapLocation, CloseBitmapSize);
                Rectangle rectSrc;

                if (bIsMouseOverClose)
                {
                    if (bIsMouseDown)
                        rectSrc = new Rectangle(new Point(CloseBitmapSize.Width * 2, 0), CloseBitmapSize);
                    else
                        rectSrc = new Rectangle(new Point(CloseBitmapSize.Width, 0), CloseBitmapSize);
                }
                else
                    rectSrc = new Rectangle(new Point(0, 0), CloseBitmapSize);


                grfx.DrawImage(CloseBitmap, rectDest, rectSrc, GraphicsUnit.Pixel);
            }
        }

        protected void DrawText(Graphics grfx)
        {
            if (titleText != null && titleText.Length != 0)
            {
                StringFormat sf = new StringFormat();
                sf.Alignment = StringAlignment.Near;
                sf.LineAlignment = StringAlignment.Center;
                sf.FormatFlags = StringFormatFlags.NoWrap;
                sf.Trimming = StringTrimming.EllipsisCharacter;				// Added Rev 002
                if (bIsMouseOverTitle)
                    grfx.DrawString(titleText, hoverTitleFont, new SolidBrush(hoverTitleColor), TitleRectangle, sf);
                else
                    grfx.DrawString(titleText, normalTitleFont, new SolidBrush(normalTitleColor), TitleRectangle, sf);
            }

            if (contentText != null && contentText.Length != 0)
            {
                StringFormat sf = new StringFormat();
                // Rev 006-CAS: New feature: Content alignement
                switch (caContentAlignement)
                {
                    case ContentAlignment.BottomCenter:
                        sf.Alignment = StringAlignment.Center;
                        sf.LineAlignment = StringAlignment.Far;
                        break;

                    case ContentAlignment.BottomLeft:
                        sf.Alignment = StringAlignment.Near;
                        sf.LineAlignment = StringAlignment.Far;
                        break;

                    case ContentAlignment.BottomRight:
                        sf.Alignment = StringAlignment.Far;
                        sf.LineAlignment = StringAlignment.Far;
                        break;

                    case ContentAlignment.MiddleCenter:
                        sf.Alignment = StringAlignment.Center;
                        sf.LineAlignment = StringAlignment.Center;
                        break;

                    case ContentAlignment.MiddleLeft:
                        sf.Alignment = StringAlignment.Near;
                        sf.LineAlignment = StringAlignment.Center;
                        break;

                    case ContentAlignment.MiddleRight:
                        sf.Alignment = StringAlignment.Far;
                        sf.LineAlignment = StringAlignment.Center;
                        break;

                    case ContentAlignment.TopCenter:
                        sf.Alignment = StringAlignment.Center;
                        sf.LineAlignment = StringAlignment.Near;
                        break;

                    case ContentAlignment.TopLeft:
                        sf.Alignment = StringAlignment.Near;
                        sf.LineAlignment = StringAlignment.Near;
                        break;
                    case ContentAlignment.TopRight:
                        sf.Alignment = StringAlignment.Far;
                        sf.LineAlignment = StringAlignment.Near;
                        break;


                    default:
                        sf.Alignment = StringAlignment.Center;
                        sf.LineAlignment = StringAlignment.Center;
                        break;
                }
                //sf.FormatFlags = StringFormatFlags.MeasureTrailingSpaces;
                //sf.Trimming = StringTrimming.Word;							// Added Rev 002
                sf.FormatFlags = StringFormatFlags.MeasureTrailingSpaces | StringFormatFlags.LineLimit;
                sf.Trimming = StringTrimming.EllipsisWord;


                if (bIsMouseOverContent)
                {
                    grfx.DrawString(contentText, hoverContentFont, new SolidBrush(hoverContentColor), ContentRectangle, sf);
                    if (EnableSelectionRectangle)
                        ControlPaint.DrawBorder3D(grfx, RealContentRectangle, Border3DStyle.Etched,
                                                  Border3DSide.Top | Border3DSide.Bottom | Border3DSide.Left | Border3DSide.Right);
                }
                else
                    grfx.DrawString(contentText, normalContentFont, new SolidBrush(normalContentColor), ContentRectangle, sf);
            }
        }

        protected void CalculateMouseRectangles()
        {
            Graphics grfx = CreateGraphics();
            StringFormat sf = new StringFormat();
            // Rev 006-CAS: New feature: Content alignement
            // --- Replace
            //sf.Alignment = StringAlignment.Center;
            //sf.LineAlignment = StringAlignment.Center;            
            // --- With
            switch (caContentAlignement)
            {
                case ContentAlignment.BottomCenter:
                    sf.Alignment = StringAlignment.Center;
                    sf.LineAlignment = StringAlignment.Far;
                    break;

                case ContentAlignment.BottomLeft:
                    sf.Alignment = StringAlignment.Near;
                    sf.LineAlignment = StringAlignment.Far;
                    break;

                case ContentAlignment.BottomRight:
                    sf.Alignment = StringAlignment.Far;
                    sf.LineAlignment = StringAlignment.Far;
                    break;

                case ContentAlignment.MiddleCenter:
                    sf.Alignment = StringAlignment.Center;
                    sf.LineAlignment = StringAlignment.Center;
                    break;

                case ContentAlignment.MiddleLeft:
                    sf.Alignment = StringAlignment.Near;
                    sf.LineAlignment = StringAlignment.Center;
                    break;

                case ContentAlignment.MiddleRight:
                    sf.Alignment = StringAlignment.Far;
                    sf.LineAlignment = StringAlignment.Center;
                    break;

                case ContentAlignment.TopCenter:
                    sf.Alignment = StringAlignment.Center;
                    sf.LineAlignment = StringAlignment.Near;
                    break;

                case ContentAlignment.TopLeft:
                    sf.Alignment = StringAlignment.Near;
                    sf.LineAlignment = StringAlignment.Near;
                    break;
                case ContentAlignment.TopRight:
                    sf.Alignment = StringAlignment.Far;
                    sf.LineAlignment = StringAlignment.Near;
                    break;


                default:
                    sf.Alignment = StringAlignment.Center;
                    sf.LineAlignment = StringAlignment.Center;
                    break;
            }
            // --- End Of replace

            sf.FormatFlags = StringFormatFlags.MeasureTrailingSpaces;
            SizeF sizefTitle = grfx.MeasureString(titleText, hoverTitleFont, TitleRectangle.Width, sf);
            SizeF sizefContent = grfx.MeasureString(contentText, hoverContentFont, ContentRectangle.Width, sf);
            grfx.Dispose();

            // Added Rev 002
            //We should check if the title size really fits inside the pre-defined title rectangle
            if (sizefTitle.Height > TitleRectangle.Height)
            {
                RealTitleRectangle = new Rectangle(TitleRectangle.Left, TitleRectangle.Top,
                                                   TitleRectangle.Width, TitleRectangle.Height);
            }
            else
            {
                RealTitleRectangle = new Rectangle(TitleRectangle.Left, TitleRectangle.Top,
                                                  (int)sizefTitle.Width, (int)sizefTitle.Height);
            }
            RealTitleRectangle.Inflate(0, 2);

            // Added Rev 002
            //We should check if the Content size really fits inside the pre-defined Content rectangle

            // Added Rev 006-CAS: New feature: Content alignement            
            // use of ContentTextAlignement
            int RealHeight = (sizefContent.Height > ContentRectangle.Height) ? ContentRectangle.Height : (int)sizefContent.Height;
            switch (caContentAlignement)
            {
                case ContentAlignment.BottomCenter:
                    RealContentRectangle = new Rectangle((ContentRectangle.Width - (int)sizefContent.Width) / 2 + ContentRectangle.Left,
                                                        (ContentRectangle.Height - RealHeight) + ContentRectangle.Top,
                                                        (int)sizefContent.Width, RealHeight);
                    break;

                case ContentAlignment.BottomLeft:
                    RealContentRectangle = new Rectangle(ContentRectangle.Left,
                                                        (ContentRectangle.Height - RealHeight) + ContentRectangle.Top,
                                                        (int)sizefContent.Width, RealHeight);
                    break;

                case ContentAlignment.BottomRight:
                    RealContentRectangle = new Rectangle((ContentRectangle.Width - (int)sizefContent.Width) + ContentRectangle.Left,
                                                         (ContentRectangle.Height - RealHeight) + ContentRectangle.Top,
                                                         (int)sizefContent.Width, RealHeight);

                    break;

                case ContentAlignment.MiddleCenter:
                    RealContentRectangle = new Rectangle((ContentRectangle.Width - (int)sizefContent.Width) / 2 + ContentRectangle.Left,
                                                        (ContentRectangle.Height - RealHeight) / 2 + ContentRectangle.Top,
                                                        (int)sizefContent.Width, RealHeight);
                    break;

                case ContentAlignment.MiddleLeft:
                    RealContentRectangle = new Rectangle(ContentRectangle.Left,
                                                        (ContentRectangle.Height - RealHeight) / 2 + ContentRectangle.Top,
                                                        (int)sizefContent.Width, RealHeight);
                    break;

                case ContentAlignment.MiddleRight:
                    RealContentRectangle = new Rectangle((ContentRectangle.Width - (int)sizefContent.Width) + ContentRectangle.Left,
                                                        (ContentRectangle.Height - RealHeight) / 2 + ContentRectangle.Top,
                                                        (int)sizefContent.Width, RealHeight);
                    break;

                case ContentAlignment.TopCenter:
                    RealContentRectangle = new Rectangle((ContentRectangle.Width - (int)sizefContent.Width) / 2 + ContentRectangle.Left,
                                                         ContentRectangle.Top,
                                                        (int)sizefContent.Width, RealHeight);
                    break;

                case ContentAlignment.TopLeft:
                    RealContentRectangle = new Rectangle(ContentRectangle.Left,
                                                         ContentRectangle.Top,
                                                        (int)sizefContent.Width, RealHeight);
                    break;

                case ContentAlignment.TopRight:
                    RealContentRectangle = new Rectangle((ContentRectangle.Width - (int)sizefContent.Width) + ContentRectangle.Left,
                                                         ContentRectangle.Top,
                                                        (int)sizefContent.Width, RealHeight);
                    break;


                default:
                    RealContentRectangle = new Rectangle((ContentRectangle.Width - (int)sizefContent.Width) / 2 + ContentRectangle.Left,
                                                        (ContentRectangle.Height - RealHeight) / 2 + ContentRectangle.Top,
                                                        (int)sizefContent.Width, RealHeight);
                    break;
            }
            // Updated rev 006-CAS:             
            RealContentRectangle.Inflate(4, 2);
        }

        protected Region BitmapToRegion(Bitmap bitmap, Color transparencyColor)
        {
            if (bitmap == null)
                throw new ArgumentNullException("Bitmap", "Bitmap cannot be null!");

            int height = bitmap.Height;
            int width = bitmap.Width;

            GraphicsPath path = new GraphicsPath();

            for (int j = 0; j < height; j++)
                for (int i = 0; i < width; i++)
                {
                    if (bitmap.GetPixel(i, j) == transparencyColor)
                        continue;

                    int x0 = i;

                    while ((i < width) && (bitmap.GetPixel(i, j) != transparencyColor))
                        i++;

                    path.AddRectangle(new Rectangle(x0, j, i - x0, 1));
                }

            Region region = new Region(path);
            path.Dispose();
            return region;
        }
        #endregion

        #region TaskbarNotifier Events Overrides
        private void OnTimer(Object obj, EventArgs ea)
        {
            switch (taskbarState)
            {
                case TaskbarStates.appearing:
                    // Updated Rev 003-CAS: Sliding or fading effect
                    if (bAppearBySliding)
                    {
                        if (Height < BackgroundBitmap.Height)
                            SetBounds(Left, Top - nIncrementShow, Width, Height + nIncrementShow);
                        else
                        {
                            // Updated Rev 004-CAS: New Property: Padding
                            // Updated Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
                            if (Bottom > WorkAreaRectangle.Bottom - nPadding - nBaseWindowBottom)
                                SetBounds(Left, Top - nIncrementShow, Width, Height);
                            else
                            {
                                timer.Stop();
                                Height = BackgroundBitmap.Height;
                                timer.Interval = nVisibleEvents;
                                taskbarState = TaskbarStates.visible;
                                timer.Start();
                            }
                        }
                    }
                    else
                    {// Added Rev 003-CAS: Sliding or fading effect
                        if (Opacity < 1.0)
                            Opacity = Opacity + (1.0 / (BackgroundBitmap.Height / nIncrementShow));
                        else
                        {
                            timer.Stop();
                            Height = BackgroundBitmap.Height;
                            timer.Interval = nVisibleEvents;
                            taskbarState = TaskbarStates.visible;
                            timer.Start();
                        }
                    }
                    break;

                case TaskbarStates.visible:
                    timer.Stop();
                    timer.Interval = nHideEvents;
                    // Added Rev 002
                    if ((bKeepVisibleOnMouseOver && !bIsMouseOverPopup) || (!bKeepVisibleOnMouseOver))
                    {
                        taskbarState = TaskbarStates.disappearing;
                    }
                    //taskbarState = TaskbarStates.disappearing;		// Rev 002
                    timer.Start();
                    break;

                case TaskbarStates.disappearing:
                    // Added Rev 002
                    if (bReShowOnMouseOver && bIsMouseOverPopup)
                    {
                        taskbarState = TaskbarStates.appearing;
                    }
                    else
                    {
                        // Updated Rev 003-CAS: Sliding or fading effect
                        if (bAppearBySliding)
                        {
                            // Added Rev 006-CAS: Slide to the bottom and then reduce the popup height
                            if ((Top + Height) < WorkAreaRectangle.Bottom)
                                SetBounds(Left, Top + nIncrementHide, Width, Height);
                            else
                                if (Top < WorkAreaRectangle.Bottom)
                                    SetBounds(Left, Top + nIncrementHide, Width, Height - nIncrementHide);
                                else
                                    Hide();
                            //	Removed Rev 006-CAS: Slide to the bottom and then reduce the popup height
                            //	 if (Top < WorkAreaRectangle.Bottom)
                            //	   SetBounds(Left, Top + nIncrementHide, Width, Height - nIncrementHide);
                            //	 else
                            //	   Hide();
                        }
                        else
                        {
                            if (Opacity > 0.1)
                                Opacity = Opacity - (1.0 / (BackgroundBitmap.Height / nIncrementHide));
                            else
                                Hide();
                        }
                    }
                    break;
            }
        }

        protected override void OnMouseEnter(EventArgs ea)
        {
            base.OnMouseEnter(ea);
            bIsMouseOverPopup = true;
            Refresh();
        }

        protected override void OnMouseLeave(EventArgs ea)
        {
            base.OnMouseLeave(ea);
            bIsMouseOverPopup = false;
            bIsMouseOverClose = false;
            bIsMouseOverTitle = false;
            bIsMouseOverContent = false;
            Refresh();
        }

        protected override void OnMouseMove(MouseEventArgs mea)
        {
            base.OnMouseMove(mea);

            // removed TVDP
            //
            //// Added Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage			 
            //if (bMoving)
            //{
            //    Point temp = new Point(0, 0);
            //    temp.X = Location.X + (mea.X - nMouseDownX);
            //    temp.Y = Location.Y + (mea.Y - nMouseDownY);
            //    if ((temp.X + this.Size.Width) > Screen.GetWorkingArea(this.WorkAreaRectangle).Width)
            //        temp.X = Screen.GetWorkingArea(this.WorkAreaRectangle).Width - this.Size.Width;
            //    if ((temp.Y + this.Size.Height) > Screen.GetWorkingArea(this.WorkAreaRectangle).Height)
            //        temp.Y = Screen.GetWorkingArea(this.WorkAreaRectangle).Height - this.Size.Height;

            //    if (temp.X < 0)
            //        temp.X = 0;
            //    if (temp.Y < 0)
            //        temp.Y = 0;

            //    Location = temp;
            //    Application.UserAppDataRegistry.SetValue("ToastBottom", WorkAreaRectangle.Height - Top - Height - Padding);
            //    Application.UserAppDataRegistry.SetValue("ToastRight", WorkAreaRectangle.Width - Left - Width - Padding);
            //    nBaseWindowBottom = WorkAreaRectangle.Height - Top - Height - Padding;
            //    nBaseWindowRight = WorkAreaRectangle.Width - Left - Width - Padding;
            //}

            bool bContentModified = false;

            if ((mea.X > CloseBitmapLocation.X)
                 && (mea.X < CloseBitmapLocation.X + CloseBitmapSize.Width)
                 && (mea.Y > CloseBitmapLocation.Y)
                 && (mea.Y < CloseBitmapLocation.Y + CloseBitmapSize.Height)
                 && CloseClickable)
            {
                if (!bIsMouseOverClose)
                {
                    bIsMouseOverClose = true;
                    bIsMouseOverTitle = false;
                    bIsMouseOverContent = false;
                    Cursor = Cursors.Hand;
                    bContentModified = true;
                }
            }
            else if (RealContentRectangle.Contains(new Point(mea.X, mea.Y)) && ContentClickable)
            {
                if (!bIsMouseOverContent)
                {
                    bIsMouseOverClose = false;
                    bIsMouseOverTitle = false;
                    bIsMouseOverContent = true;
                    Cursor = Cursors.Hand;
                    bContentModified = true;
                }
            }
            else if (RealTitleRectangle.Contains(new Point(mea.X, mea.Y)) && TitleClickable)
            {
                if (!bIsMouseOverTitle)
                {
                    bIsMouseOverClose = false;
                    bIsMouseOverTitle = true;
                    bIsMouseOverContent = false;
                    Cursor = Cursors.Hand;
                    bContentModified = true;
                }
            }
            else
            {
                if (bIsMouseOverClose || bIsMouseOverTitle || bIsMouseOverContent)
                    bContentModified = true;

                bIsMouseOverClose = false;
                bIsMouseOverTitle = false;
                bIsMouseOverContent = false;
                Cursor = Cursors.Default;
            }

            if (bContentModified)
                Refresh();
        }

        protected override void OnMouseDown(MouseEventArgs mea)
        {
            base.OnMouseDown(mea);

            bIsMouseDown = true;

            if (bIsMouseOverClose)
                Refresh();

            // removed TVDP
            //
            // Added Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
            //else
            //    if (mea.Button == MouseButtons.Left)
            //    {
            //        bMoving = true;
            //        nMouseDownX = mea.X;
            //        nMouseDownY = mea.Y;
            //    }

        }

        protected override void OnMouseUp(MouseEventArgs mea)
        {
            base.OnMouseUp(mea);
            bIsMouseDown = false;

            // Added Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
            if (mea.Button == MouseButtons.Left)
                bMoving = false;

            if (bIsMouseOverClose)
            {
                Hide();

                if (CloseClick != null)
                    CloseClick(this, new EventArgs());
            }
            else if (bIsMouseOverTitle)
            {
                if (TitleClick != null)
                    TitleClick(this, new EventArgs());
            }
            else if (bIsMouseOverContent)
            {
                if (ContentClick != null)
                    ContentClick(this, new EventArgs());
            }
        }

        protected override void OnPaintBackground(PaintEventArgs pea)
        {
            Graphics grfx = pea.Graphics;
            grfx.PageUnit = GraphicsUnit.Pixel;

            Graphics offScreenGraphics;
            Bitmap offscreenBitmap;

            offscreenBitmap = new Bitmap(BackgroundBitmap.Width, BackgroundBitmap.Height);
            offScreenGraphics = Graphics.FromImage(offscreenBitmap);

            if (BackgroundBitmap != null)
            {
                offScreenGraphics.DrawImage(BackgroundBitmap, 0, 0, BackgroundBitmap.Width, BackgroundBitmap.Height);
            }

            DrawCloseButton(offScreenGraphics);
            DrawText(offScreenGraphics);

            grfx.DrawImage(offscreenBitmap, 0, 0);
        }
        #endregion

        private void InitializeComponent()
        {
            this.SuspendLayout();
            // 
            // TaskbarNotifier
            // 
            this.ShowInTaskbar = false;
            this.ClientSize = new System.Drawing.Size(284, 264);
            this.Name = "TaskbarNotifier";
            this.ResumeLayout(false);

        }

    }
    #region Rev 005-CAS: New feature: Management of Toasts' Collection and last position storage
    /// 
    /// ToastCollection allows to Manage a set of TaskbarNotifier object
    /// 
    public class ToastCollection
    {
        #region ToastCollection Private Members
        protected int nToastCount = 0;
        protected int nBaseWindowBottom = 0;
        protected int nBaseWindowRight = 0;
        #endregion

        #region ToastCollection Public Methods
        /// 
        /// The Constructor for ToastCollection
        /// 
        public ToastCollection()
        {
            nBaseWindowBottom = 0;
            nBaseWindowRight = 0;
        }
        /// 
        /// Add the toast to the collection and calculate the coordinate of the next toast.
        /// 
        /// TaskbarNotifier object to add to the collection.
        /// Max height to reach before changing column.
        /// Current distance from the bottom of the screen (updated in the Method)
        /// Current distance from the right of the screen (updated in the Method)
        /// Nothing
        public void AddToast(TaskbarNotifier newToast,
            int screenTop,
            ref int baseWindowBottom,
            ref int baseWindowRight)
        {
            // If this window would be placed above visible screen
            // move the window to a new column of windows and reset the bottom
            if (nBaseWindowBottom > (screenTop - newToast.Height))
            {
                if (nBaseWindowRight > newToast.Width)
                    nBaseWindowRight = 0;
                else
                    nBaseWindowRight = nBaseWindowRight + newToast.Width + newToast.Padding;
                nBaseWindowBottom = 0;
            }
            nToastCount += 1;
            baseWindowBottom = nBaseWindowBottom;
            baseWindowRight = nBaseWindowRight;

            // Increment bottom for next window
            nBaseWindowBottom = nBaseWindowBottom + newToast.Height + newToast.Padding;
        }
        /// 
        /// Close the Toast object and calculate, if needed the new coordinates.
        /// 
        /// TaskbarNotifier object to close and dispose.
        /// Nothing
        public void KillWindow(TaskbarNotifier toast)
        {
            nToastCount -= 1;
            if (nToastCount == 0)
            {
                nBaseWindowBottom = 0;
                nBaseWindowRight = 0;
            }
            toast.Close();
            toast.Dispose();
        }
        #endregion
    }
    #endregion

}