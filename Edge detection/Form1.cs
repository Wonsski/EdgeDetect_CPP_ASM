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

                    // Przetwarzanie na kopii obrazu
                    DilateImageAsm(bmpDataCopy.Scan0, originalBitmap.Width, originalBitmap.Height, stride);
                }
                else
                {
                    // Przetwarzanie na oryginalnym obrazie
                    ProcessImageCpp(bmpData.Scan0, originalBitmap.Width, originalBitmap.Height, numThreads);
                }

                // Przekształcenie danych na tablice bajtów
                byte[] originalBytes = new byte[bmpData.Height * bmpData.Stride];
                byte[] copyBytes = new byte[bmpDataCopy.Height * bmpDataCopy.Stride];

                // Kopiowanie danych pikseli z obu obrazów do tablicy
                Marshal.Copy(bmpData.Scan0, originalBytes, 0, originalBytes.Length);
                Marshal.Copy(bmpDataCopy.Scan0, copyBytes, 0, copyBytes.Length);

                // Odejmowanie wartości pikseli
                for (int i = 0; i < originalBytes.Length; i += 4) // 4 bajty na piksel (A, R, G, B)
                {
                    // Pobranie wartości RGB z oryginalnego obrazu
                    byte rOrig = originalBytes[i + 2]; // Red
                    byte gOrig = originalBytes[i + 1]; // Green
                    byte bOrig = originalBytes[i];     // Blue

                    // Pobranie wartości RGB z kopii obrazu
                    byte rCopy = copyBytes[i + 2]; // Red
                    byte gCopy = copyBytes[i + 1]; // Green
                    byte bCopy = copyBytes[i];     // Blue

                    // Odejmowanie wartości pikseli (max z 0)
                    byte rResult = (byte)Math.Max(0, rOrig - rCopy);
                    byte gResult = (byte)Math.Max(0, gOrig - gCopy);
                    byte bResult = (byte)Math.Max(0, bOrig - bCopy);

                    // Zapisz wynik z powrotem do oryginalnej tablicy
                    originalBytes[i + 2] = rResult;
                    originalBytes[i + 1] = gResult;
                    originalBytes[i] = bResult;
                }

                // Skopiowanie zaktualizowanych danych z powrotem do oryginalnego obrazu
                Marshal.Copy(originalBytes, 0, bmpData.Scan0, originalBytes.Length);

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
