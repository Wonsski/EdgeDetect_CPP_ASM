using System;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace Edge_detection
{
    public partial class Form1 : Form
    {
        [DllImport(@"..\..\..\JAproj\Debug\CLib.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ProcessImage")]
        public static extern void ProcessImageCpp(byte[] image, byte[] result, int width, int height, int numThreads);

        [DllImport(@"..\..\..\JAproj\Debug\AsmLib.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "ProcessImage")]
        public static extern void ProcessImageAsm(byte[] image, byte[] result, int width, int height, int numThreads);

        bool useAssembly = false;

        public Form1()
        {
            InitializeComponent();
            numericUpDown1.Minimum = 1;
            numericUpDown1.Maximum = Environment.ProcessorCount;
            numericUpDown1.Value = 4;
        }

        private void Form1_Load(object sender, EventArgs e)
        {
        }

        private void run_Click(object sender, EventArgs e)
        {
            if (pictureBoxOriginal.Image != null)
            {
                Bitmap originalBitmap = new Bitmap(pictureBoxOriginal.Image);
                Bitmap grayBitmap = ConvertToGrayscale(originalBitmap);
                pictureBoxOutput.Image = new Bitmap(grayBitmap);

                int width = grayBitmap.Width;
                int height = grayBitmap.Height;

                byte[] imageData = new byte[width * height];
                byte[] resultData = new byte[width * height];

                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        Color pixel = grayBitmap.GetPixel(x, y);
                        imageData[y * width + x] = pixel.R;
                    }
                }

                Stopwatch stopwatch = new Stopwatch();
                stopwatch.Start();

                int numThreads = (int)numericUpDown1.Value;

                try
                {
                    if (useAssembly)
                    {
                        ProcessImageAsm(imageData, resultData, width, height, numThreads);
                    }
                    else
                    {
                        ProcessImageCpp(imageData, resultData, width, height, numThreads);
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Błąd: {ex.Message}", "Błąd", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                stopwatch.Stop();

                Bitmap resultBitmap = new Bitmap(width, height);
                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        int pixelValue = resultData[y * width + x];
                        resultBitmap.SetPixel(x, y, Color.FromArgb(pixelValue, pixelValue, pixelValue));
                    }
                }

                pictureBoxOutput.Image = resultBitmap;

                MessageBox.Show($"Czas przetwarzania: {stopwatch.ElapsedMilliseconds} ms", "Czas wykonania", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            else
            {
                MessageBox.Show("Nie załadowano żadnego obrazka.", "Błąd", MessageBoxButtons.OK, MessageBoxIcon.Warning);
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

        private Bitmap ConvertToGrayscale(Bitmap original)
        {
            Bitmap grayBitmap = new Bitmap(original.Width, original.Height);
            for (int y = 0; y < original.Height; y++)
            {
                for (int x = 0; x < original.Width; x++)
                {
                    Color pixel = original.GetPixel(x, y);
                    int grayValue = (int)(0.3 * pixel.R + 0.59 * pixel.G + 0.11 * pixel.B);
                    grayBitmap.SetPixel(x, y, Color.FromArgb(grayValue, grayValue, grayValue));
                }
            }
            return grayBitmap;
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            useAssembly = checkBox1.Checked;
        }

        private void numericUpDown1_ValueChanged(object sender, EventArgs e)
        {
        }
    }
}
