using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;

namespace CutImage.ashx
{
    /// <summary>
    /// upload 的摘要说明
    /// </summary>
    public class upload : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            string action = context.Request["action"];
            if (action == "upload")
            {
                ProcessFileUpload(context);
            }
            else if (action == "cut")
            {
                ImageCut(context);
            }
            else
            {
                context.Response.Write("参数错误!");
            }
        }
        //图片截取
        private void ImageCut(HttpContext context)
        {
            int x = Convert.ToInt32(context.Request["x"]);
            int y = Convert.ToInt32(context.Request["y"]);
            int width = Convert.ToInt32(context.Request["w"]);
            int height = Convert.ToInt32(context.Request["h"]);
            string imgPath = context.Request["path"];
            System.Web.Script.Serialization.JavaScriptSerializer js = new System.Web.Script.Serialization.JavaScriptSerializer();
            if (imgPath != null && imgPath.Length > 0)
            {
                using (Bitmap bmp = new Bitmap(width, height))
                {
                    using (Graphics g = Graphics.FromImage(bmp))
                    {
                        using (Image img = Image.FromFile(context.Request.MapPath(imgPath)))
                        {
                            /*
                             * 参数1：原图片
                             * 参数2：画多大
                             * 参数3：画原图的具体区域
                             * 参数4：单位（像素）
                             */
                            g.DrawImage(img, new Rectangle(0, 0, width, height), new Rectangle(x, y, width, height), GraphicsUnit.Pixel);
                            string fileName = Guid.NewGuid().ToString();
                            string dir = "/ImageUpload/" + DateTime.Now.Year + DateTime.Now.Month + DateTime.Now.Day + "/cut/";
                            if (!Directory.Exists(context.Request.MapPath(dir)))
                            {
                                Directory.CreateDirectory(context.Request.MapPath(dir));
                            }
                            string fullDir = dir + fileName + ".jpg";
                            bmp.Save(context.Request.MapPath(fullDir), System.Drawing.Imaging.ImageFormat.Jpeg);
                            context.Response.Write(js.Serialize(new { msg = "ok", path = fullDir }));
                        }
                    }
                }
            }
            else
            {
                context.Response.Write(js.Serialize(new { msg = "图片加载失败，请重新上传！" }));
            }
        }
        //文件上传
        private void ProcessFileUpload(HttpContext context)
        {
            HttpPostedFile file = context.Request.Files["FileData"];
            if (file != null)
            {
                string fileName = Path.GetFileName(file.FileName);
                string fileExt = Path.GetExtension(fileName);
                if (fileExt.ToLower() == ".jpg")
                {
                    string dir = "/ImageUpload/" + DateTime.Now.Year + DateTime.Now.Month + DateTime.Now.Day;
                    if (!Directory.Exists(context.Request.MapPath(dir)))
                    {
                        Directory.CreateDirectory(context.Request.MapPath(dir));
                    }
                    string newFileName = Guid.NewGuid().ToString();
                    string filePath = dir + "/" + newFileName + fileExt.ToLower();
                    file.SaveAs(context.Request.MapPath(filePath));

                    //返回图片的大小，以动态调整div大小
                    //using (Image img=Image.FromFile(context.Request.MapPath(filePath)))
                    //{
                    //    System.Web.Script.Serialization.JavaScriptSerializer js = new System.Web.Script.Serialization.JavaScriptSerializer();
                    //    context.Response.Write(js.Serialize(new { url = filePath, h = img.Height, w = img.Width }));
                    //}

                    //生成缩略图，返回给页面
                    string thumbDir = dir + "/" + "thumbImage/";
                    if (!Directory.Exists(context.Request.MapPath(thumbDir)))
                    {
                        Directory.CreateDirectory(context.Request.MapPath(thumbDir));
                    }
                    string thumbPath = thumbDir + newFileName + fileExt.ToLower();
                    ImageClass.MakeThumbnail(context.Request.MapPath(filePath), context.Request.MapPath(thumbPath), 300, 300, "W");
                    context.Response.Write(thumbPath);
                }
            }
        }
        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}