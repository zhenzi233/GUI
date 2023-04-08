import tkinter as tk
from tkinter import filedialog
import image
import detect
import visualize

# 创建一个GUI类
class GUI(tk.Tk):
    def __init__(self):
        # 调用父类的初始化方法
        super().__init__()
        # 设置窗口标题和大小
        self.title("图像复制粘贴篡改检测系统")
        self.geometry("800x600")
        # 创建一个画布，用于显示图像和结果
        self.canvas = tk.Canvas(self, width=600, height=400)
        self.canvas.pack()
        # 创建一个标签，用于显示提示信息
        self.label = tk.Label(self, text="请选择要检测的图像文件", font=("Arial", 16))
        self.label.pack()
        # 创建一个按钮，用于选择文件
        self.button = tk.Button(self, text="选择文件", command=self.select_file)
        self.button.pack()
        # 创建一个变量，用于存储选择的文件路径
        self.file_path = None

    # 定义一个选择文件的方法
    def select_file(self):
        # 弹出一个文件对话框，让用户选择要检测的图像文件，并返回文件路径
        self.file_path = filedialog.askopenfilename(title="请选择要检测的图像文件", filetypes=[("图像文件", ".jpg .png .bmp")])
        # 如果用户选择了文件
        if self.file_path:
            # 在标签上显示选择的文件路径
            self.label.config(text=self.file_path)
            # 调用检测方法，传入文件路径
            self.detect(self.file_path)

    # 定义一个检测方法，接收一个文件路径作为参数
    def detect(self, file_path):
        # 调用image.py中的read_image函数，读取图像文件，并返回一个图像对象
        img = image.read_image(file_path)
        # 调用detect.py中的detect_copy_paste函数，检测图像是否有复制粘贴篡改，并返回一个布尔值和一个篡改区域列表
        is_tampered, regions = detect.detect_copy_paste(img)
        # 如果检测到有复制粘贴篡改
        if is_tampered:
            # 在标签上显示检测结果和置信度评分
            score = detect.get_score(regions)
            self.label.config(text=f"检测结果：该图像有复制粘贴篡改的痕迹\n置信度评分：{score}")
            # 调用visualize.py中的draw_regions函数，绘制并标记出篡改区域，并返回一个新的图像对象
            new_img = visualize.draw_regions(img, regions)
            # 调用visualize.py中的show_image函数，在画布上显示新的图像对象
            visualize.show_image(self.canvas, new_img)
        # 如果没有检测到有复制粘贴篡改
        else:
            # 在标签上显示检测结果
            self.label.config(text="检测结果：该图像没有复制粘贴篡改的痕迹")
            # 调用visualize.py中的show_image函数，在画布上显示原始图像对象
            visualize.show_image(self.canvas, img)

# 创建一个GUI对象
gui = GUI()
# 运行GUI界面
gui.mainloop()