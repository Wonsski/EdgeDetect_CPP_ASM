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

        [DllImport(@"..\..\..\JAproj\x64\Debug\AsmLib.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "CombineImages")]
        public static extern void CombineImages(IntPtr bmpPtr, int width, int height, IntPtr bmpPtr2);

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
            Bitmap originalBitmapCopy = new Bitmap(originalBitmap);  // Tworzenie kopii obrazu
            int numThreads = (int)numericUpDown1.Value;

            try
            {
                // Blokowanie oryginalnego obrazu
                Rectangle rect = new Rectangle(0, 0, originalBitmap.Width, originalBitmap.Height);
                BitmapData bmpData = originalBitmap.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
                BitmapData bmpDataCopy = originalBitmapCopy.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);

                int stride = bmpData.Stride;

                // Wybór funkcji w zależności od wartości useAssembly
                if (useAssembly)
                {
                    // Przetwarzanie na oryginalnym obrazie
                    ProcessImageAsm(bmpData.Scan0, originalBitmap.Width, originalBitmap.Height, stride);

                    byte[] imageBytes = new byte[originalBitmap.Width * originalBitmap.Height * 4];
                    Marshal.Copy(bmpData.Scan0, imageBytes, 0, imageBytes.Length);
                    Marshal.Copy(imageBytes, 0, bmpDataCopy.Scan0, imageBytes.Length);


                    // Przetwarzanie na kopii obrazu
                    DilateImageAsm(bmpData.Scan0, originalBitmap.Width, originalBitmap.Height, stride);

                    CombineImages(bmpDataCopy.Scan0, originalBitmap.Width, originalBitmap.Height, bmpData.Scan0);
                }
                else
                {
                    // Przetwarzanie na oryginalnym obrazie
                    ProcessImageCpp(bmpData.Scan0, originalBitmap.Width, originalBitmap.Height, numThreads);
                }

                // Odblokowanie obu obrazów po przetwarzaniu
                originalBitmap.UnlockBits(bmpData);
                originalBitmapCopy.UnlockBits(bmpDataCopy);

                // Przypisanie przetworzonego obrazu do wyjściowego PictureBox
                pictureBoxOutput.Image = originalBitmap;  // Możesz wybrać, który obraz chcesz wyświetlić, oryginalny czy kopię
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
