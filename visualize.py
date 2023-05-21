# 导入所需的库
from PIL import Image, ImageDraw, ImageTk, ImageOps
import tkinter as tk
import numpy as np

# 定义一个绘制并标记出篡改区域的函数，接收一个图像对象和一个篡改区域列表作为参数，返回一个新的图像对象
def draw_regions(img, pos1, pos2, regions = 0, flag = False, flag_point = False, flag_line = False):
    # 使用PIL库中的Image类的copy方法，复制图像对象，并返回一个新的图像对象
    new_img = img.copy()
    # 使用PIL库中的ImageDraw类，创建一个绘图对象，用于在新的图像对象上绘制
    draw = ImageDraw.Draw(new_img)
    # 使用for循环，遍历篡改区域列表中的每个区域

    # 检测获取到的扫描区域是否存在
    if regions != 0:
        for region in regions:
                #将扫描的区域填上颜色
                pixel_positions = np.array(region)
                for pixel_position in pixel_positions:
                    x = pixel_position[0]
                    y = pixel_position[1]
                    rgb = new_img.getpixel((x,y))
                    #是否填充白色像素
                    if flag:
                        new_img.putpixel((x,y), (255, 255, 255))
                    #填充黑白滤镜
                    else:
                        gray = int(0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2])
                        new_img.putpixel((x,y), (gray, gray, gray))

    if flag_point:
        for pos in pos1:
            x, y = pos[0], pos[1]
            # 使用绘图对象的矩形方法，绘制一个红色的点，表示点
            pos_rec = tuple([float(x-5), float(y-5), float(x+5), float(y+5)])
            draw.rectangle(pos_rec, fill='red')
        for pos in pos2:
            x, y = pos[0], pos[1]
            # 使用绘图对象的矩形方法，绘制一个红色的点，表示点
            pos_rec = tuple([float(x-5), float(y-5), float(x+5), float(y+5)])
            draw.rectangle(pos_rec, fill='blue')
    # 使用for循环，遍历篡改区域列表中的每个区域
    if flag_line:
        for i in range(len(pos1)):
            # 使用绘图对象的线方法，绘制一条线
            x1, y1, x2, y2 = pos1[i][0], pos1[i][1], pos2[i][0], pos2[i][1]
            draw.line(xy=(x1, y1, x2, y2), fill='red', width=4)
        # 返回新的图像对象
    return new_img

# 定义一个在画布上显示图像对象的函数，接收一个画布对象和一个图像对象作为参数，无返回值
def show_image(canvas, img):
    # 使用PIL库中的Image类的resize方法，将图像对象按比例缩放来兼容画布，并返回一个新的图像对象
    scale_factor = float(img.height / canvas.winfo_height())
    new_img = img.resize((int(img.width / scale_factor), canvas.winfo_height()))
    # 使用PIL库中的ImageTk类的PhotoImage类来创建tkinter兼容的图片对象，并返回
    photo = ImageTk.PhotoImage(new_img)
    canvas.photo = photo
    # 使用画布对象的create_image方法和itemconfig方法，在画布上创建并显示图片对象
    main = canvas.create_image(0, 0, image=canvas.photo, anchor=tk.NW)
    canvas.itemconfigure(main, image=photo)
