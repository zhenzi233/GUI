# 导入所需的库
from PIL import Image, ImageDraw, ImageTk
import tkinter as tk

# 定义一个绘制并标记出篡改区域的函数，接收一个图像对象和一个篡改区域列表作为参数，返回一个新的图像对象
def draw_regions(img, regions):
    # 使用PIL库中的Image类的copy方法，复制图像对象，并返回一个新的图像对象
    new_img = img.copy()
    # 使用PIL库中的ImageDraw类，创建一个绘图对象，用于在新的图像对象上绘制
    draw = ImageDraw.Draw(new_img)
    # 使用for循环，遍历篡改区域列表中的每个区域
    for region in regions:
        # 使用绘图对象的rectangle方法，绘制一个红色的矩形框，表示篡改区域
        draw.rectangle(region, outline="red")
    # 返回新的图像对象
    return new_img

# 定义一个在画布上显示图像对象的函数，接收一个画布对象和一个图像对象作为参数，无返回值
def show_image(canvas, img):
    # 使用PIL库中的Image类的resize方法，将图像对象按比例缩放来兼容画布，并返回一个新的图像对象
    scale_factor = float(img.height / canvas.winfo_height())
    img = img.resize((int(img.width / scale_factor), canvas.winfo_height()))
    # 使用PIL库中的ImageTk类的PhotoImage类来创建tkinter兼容的图片对象，并返回
    photo = ImageTk.PhotoImage(img)
    # 使用画布对象的create_image方法和itemconfig方法，在画布上创建并显示图片对象
    main = canvas.create_image(0, 0, image=photo, anchor=tk.NW)
    canvas.itemconfig(main, photo)