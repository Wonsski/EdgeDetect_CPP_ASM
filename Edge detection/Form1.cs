using System;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

namespace Edge_detection
{
    public partial class Form1 : Form
    {
        [DllImport(@"..\..\..\JAproj\x64\Release\CLib.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ProcessImageCpp")]
        public static extern void ProcessImageCpp(IntPtr bmpPtr, int width, int height, int numThreads);

        [DllImport(@"..\..\..\JAproj\x64\Release\AsmLib.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ProcessImageAsm")]
        public static extern void ProcessImageAsm(IntPtr bmpPtr, int width, int height_min, int height_max);

        [DllImport(@"..\..\..\JAproj\x64\Release\AsmLib.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "DilateImageAsm")]
        public static extern void DilateImageAsm(IntPtr bmpPtr, int width, int height_min, int height_max, IntPtr bmpPtr2);

        [DllImport(@"..\..\..\JAproj\x64\Release\AsmLib.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "CombineImages")]
        public static extern void CombineImages(IntPtr bmpPtr, int width, int height_min, int height_max, IntPtr bmpPtr2);

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

            // Start mierzenia czasu
            Stopwatch stopwatch = new Stopwatch();
            stopwatch.Start();

            Bitmap originalBitmap = new Bitmap(pictureBoxOriginal.Image);
            Bitmap originalBitmapCopy = new Bitmap(originalBitmap);
            Bitmap originalBitmapCopy2 = new Bitmap(originalBitmap);
            int numThreads = (int)numericUpDown1.Value;

            try
            {
                Rectangle rect = new Rectangle(0, 0, originalBitmap.Width, originalBitmap.Height);
                BitmapData bmpData = originalBitmap.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
                BitmapData bmpDataCopy = originalBitmapCopy.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
                BitmapData bmpDataCopy2 = originalBitmapCopy2.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);

                if (useAssembly)
                {
                    int height = originalBitmap.Height;
                    int width = originalBitmap.Width;
                    int segmentHeight = height / numThreads;

                    // Proces wielowątkowy dla ProcessImageAsm
                    Thread[] processThreads = new Thread[numThreads];
                    for (int i = 0; i < numThreads; i++)
                    {
                        int yMin = i * segmentHeight;
                        int yMax = (i == numThreads - 1) ? height : yMin + segmentHeight;

                        processThreads[i] = new Thread(() =>
                        {
                            ProcessImageAsm(bmpData.Scan0, width, yMin, yMax);
                        });
                        processThreads[i].Start();
                    }

                    foreach (var thread in processThreads) thread.Join();

                    byte[] imageBytes = new byte[width * height * 4];
                    Marshal.Copy(bmpData.Scan0, imageBytes, 0, imageBytes.Length);
                    Marshal.Copy(imageBytes, 0, bmpDataCopy.Scan0, imageBytes.Length);

                    // Proces wielowątkowy dla DilateImageAsm
                    Thread[] dilateThreads = new Thread[numThreads];
                    for (int i = 0; i < numThreads; i++)
                    {
                        int yMin = i * segmentHeight;
                        int yMax = (i == numThreads - 1) ? height : yMin + segmentHeight;

                        dilateThreads[i] = new Thread(() =>
                        {
                            DilateImageAsm(bmpData.Scan0, width, yMin, yMax, bmpDataCopy2.Scan0);
                        });
                        dilateThreads[i].Start();
                    }

                    foreach (var thread in dilateThreads) thread.Join();

                    // Proces wielowątkowy dla CombineImages
                    Thread[] combineThreads = new Thread[numThreads];
                    for (int i = 0; i < numThreads; i++)
                    {
                        int yMin = i * segmentHeight;
                        int yMax = (i == numThreads - 1) ? height : yMin + segmentHeight;

                        combineThreads[i] = new Thread(() =>
                        {
                            CombineImages(bmpDataCopy2.Scan0, width, yMin, yMax, bmpData.Scan0);
                        });
                        combineThreads[i].Start();
                    }

                    foreach (var thread in combineThreads) thread.Join();
                }
                else
                {
                    ProcessImageCpp(bmpData.Scan0, originalBitmap.Width, originalBitmap.Height, numThreads);
                }

                originalBitmap.UnlockBits(bmpData);
                originalBitmapCopy.UnlockBits(bmpDataCopy);
                originalBitmapCopy2.UnlockBits(bmpDataCopy2);

                pictureBoxOutput.Image = originalBitmap;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Błąd: {ex.Message}", "Błąd", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                // Stop mierzenia czasu
                stopwatch.Stop();
                MessageBox.Show($"Czas wykonania operacji: {stopwatch.ElapsedMilliseconds} ms", "Czas wykonania", MessageBoxButtons.OK, MessageBoxIcon.Information);
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
    }
}
