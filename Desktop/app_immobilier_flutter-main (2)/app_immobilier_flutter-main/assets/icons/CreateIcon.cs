using System;
using System.Drawing;
using System.Drawing.Imaging;

class Program {
    static void Main() {
        using (Bitmap bmp = new Bitmap(512, 512)) {
            using (Graphics g = Graphics.FromImage(bmp)) {
                g.FillRectangle(Brushes.Blue, 0, 0, 512, 512);
            }
            bmp.Save("app_icon.png", ImageFormat.Png);
        }
    }
}
