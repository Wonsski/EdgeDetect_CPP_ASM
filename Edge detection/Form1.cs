using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace Edge_detection
{
    public partial class Form1 : Form
    {
        [DllImport(@"..\..\..\JAproj\x64\Debug\CLib.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "ProcessImageCpp")]
        public static extern void ProcessImageCpp(IntPtr bmpPtr, int width, int height, int numThreads);

        [DllImport(@"..\..\..\JAproj\x64\Debug\AsmLib.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "ProcessImageAsm")]
        public static extern void ProcessImageAsm(IntPtr bmpPtr, int width, int height, int stride);

        [DllImport(@"..\..\..\JAproj\x64\Debug\AsmLib.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "DilateImageAsm")]
        public static extern void DilateImageAsm(IntPtr bmpPtr, int width, int height, int stride);

        private bool useAssembly = false;

        public Form1()
        {
            InitializeComponent();
            numericUpDown1.Minimum = 1;
            numericUpDown1.Maximum = Environment.ProcessorCount;
            numericUpDown1.Value = 4;
        }

        private void run_Click(object sender, EventArgs e)
        {
            if (pictureBoxOriginal.Image == null)
            {
                MessageBox.Show("Nie załadowano żadnego obrazka.", "Błąd", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            Bitmap originalBitmap = new Bitmap(pictureBoxOriginal.Image);
            int numThreads = (int)numericUpDown1.Value;

            try
            {
                Rectangle rect = new Rectangle(0, 0, originalBitmap.Width, originalBitmap.Height);
                BitmapData bmpData = originalBitmap.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);

                int stride = bmpData.Stride;

                // Wybór funkcji w zależności od wartości useAssembly
                if (useAssembly)
                {
                    //ProcessImageAsm(bmpData.Scan0, originalBitmap.Width, originalBitmap.Height, stride);
                    DilateImageAsm(bmpData.Scan0, originalBitmap.Width, originalBitmap.Height, stride);

                }
                else
                {
                    ProcessImageCpp(bmpData.Scan0, originalBitmap.Width, originalBitmap.Height, numThreads);
                }

                

                IntPtr firstPixelPtr = bmpData.Scan0;
                byte firstPixelValue = Marshal.ReadByte(firstPixelPtr);

                originalBitmap.UnlockBits(bmpData);

                pictureBoxOutput.Image = originalBitmap;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Błąd: {ex.Message}", "Błąd", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void load_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "Bitmap Files (*.bmp)|*.bmp";

            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                pictureBoxOriginal.Image = new Bitmap(openFileDialog.FileName);
            }
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            useAssembly = checkBox1.Checked;
        }

        private void numericUpDown1_ValueChanged(object sender, EventArgs e)
        {
            // Możesz dodać dodatkowe działanie, jeśli jest to potrzebne
        }
    }
}
