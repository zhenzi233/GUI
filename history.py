import tkinter as tk
from tkinter import ttk
import visualize
from PIL import Image, ImageDraw, ImageTk
# 历史记录类
class History():
    def __init__(self, master):
        # 获取主窗口
        self.master = master
        # 创建历史记录数据组
        self.data = []
        # 创建标签组
        self.labels = []

    def add_data(self, img, img1, method, score):
        # 获取缩放比例
        scale_factor = float(img.height / 400)
        # 依据缩放比例来缩放图片
        new_img = img.resize((int(img.width / scale_factor), 400))
        new_img1 = img1.resize((int(img1.width / scale_factor), 400))
        # 通过ImageTk的PhotoImage来创建与tk相兼容的图片
        photo = ImageTk.PhotoImage(new_img)
        photo1 = ImageTk.PhotoImage(new_img1)
        # 文字显示所用的算法处理
        str_method = self.get_str_mode(method)
        # 往self.data添加数据
        self.data.append([photo, photo1, str_method, score])

    # 返回所用的算法的文字表达，如CALHESURFG2NN
    def get_str_mode(self, method):
            str_method = 'CALHESURFG2NN'
            if method == 1:
                str_method = 'singleSURFG2NN'
            elif method == 2:
                str_method = 'histadptsurf'
            elif method == 3:
                str_method == 'hsvSURF'
            return str_method
        
    # 检测数据并设置图片所需要的标签最后把处理好的标签组返回
    def check_data_and_create_canvas(self):
        # 如果无数据，则直接返回空并终止
        if not self.data:
            return
        # 创建临时标签组
        labels = []
        
        # 根据数据容量返回所对应的num
        for num in range(len(self.data)):
            # 给每个图片设置在窗口中的x，y轴上的位置
            y_num =  450 * num
            # 原始图像
            temp_label_origin = ttk.Label(self.windows, background='red')
            temp_label_origin.place(x= 10, y = 40 + y_num)
            # 处理后的图像
            temp_label = ttk.Label(self.windows,background='blue')
            temp_label.place(x= 630, y = 40 + y_num)
            # 算法显示
            temp_label_method = ttk.Label(self.windows,text='', font=("Arial", 16))
            temp_label_method.place(x = 10, y = 10 + y_num)
            # 所需要的对象处理后便添加给临时变量标签组，然后继续跟着for去处理接下来的标签组
            labels.append([num, temp_label_origin, temp_label, temp_label_method])
        # 返回临时变量标签组
        return labels

    # 处理按钮点击后的所发生的事情
    def open_windows(self):
        # 创建子窗口
        self.windows = tk.Toplevel(self.master)
        self.windows.geometry('1280x720')
        self.windows.title('历史记录')
        # 子窗口绑定滚轮事件
        self.windows.bind("<MouseWheel>",self.mouse_wheel)
        # 获取经过处理后的标签组
        self.labels = self.check_data_and_create_canvas()
        # 设置滚轮的长度（未完成，这里只是一个参数）
        self.max_scale = 0
        # 如果标签组是空的，则终止
        if not self.labels:
            return
        # 如果数据组是空的，则终止
        if not self.data:
            return
        # 获取标签组中的每个标签，并把图片配置到对应的标签
        for label in self.labels:
            # 序号标签
            index = label[0]
            # 原始图像标签
            origin_label = label[1]
            # 处理好的图像标签
            new_label = label[2]
            # 算法标签
            str_label = label[3]

            # 依据序号获取对应的数据
            data = self.data[index]

            # 原始图像数据
            origin_img = data[0]
            # 处理好的图像数据
            new_img = data[1]
            # 算法数据
            str_method = data[2]

            score = data[3]

            # 将数据配置到对应的标签
            origin_label.config(image=origin_img)
            new_label.config(image=new_img)
            str_label.config(text=str(index + 1)+ '. ' + '算法:' + str_method + '   置信度评分： ' + str(score))
            # 依据结果来增长长度
            self.max_scale += 440

    # 处理滚轮事件
    def mouse_wheel(self, event):
        # 如果标签组里面只有一个标签，则不处理滚轮事件
        if len(self.labels) == 1:
            return
        # 向下滚轮
        if event.delta < 0:
            # 获取位于最后的位置的标签
            str_end_label = self.get_end_label(self.labels)
            # 如果最后位置的标签所在的y位置小于300，则不再向下移动
            if str_end_label.winfo_y() < 300:
                return
            # 处理移动
            for label in self.labels:
                origin_label = label[1]
                new_label = label[2]   
                str_label = label[3]
                o_y = origin_label.winfo_rooty() - self.windows.winfo_rooty()
                origin_label.place(y = o_y - 10)
                n_y = new_label.winfo_rooty() - self.windows.winfo_rooty()
                new_label.place(y = n_y - 10)
                s_y = str_label.winfo_rooty() - self.windows.winfo_rooty()
                str_label.place(y = s_y -10)
        # 向上滚轮     
        if event.delta > 0:
            # 获取位于最前的位置的标签
            str_first_label = self.get_first_label(self.labels)
            # 如果最前位置的标签所在的y位置大于0，则不再向上移动
            if str_first_label.winfo_y() > 0:
                return
            # 处理移动
            for label in self.labels:
                origin_label = label[1]
                new_label = label[2]  
                str_label = label[3] 
                o_y = origin_label.winfo_rooty() - self.windows.winfo_rooty()
                origin_label.place(y = o_y + 10)
                n_y = new_label.winfo_rooty() - self.windows.winfo_rooty()
                new_label.place(y = n_y + 10)
                s_y = str_label.winfo_rooty() - self.windows.winfo_rooty()
                str_label.place(y = s_y + 10)

    # 简单粗暴的获取位置方法（直接看谁是最后的，就获取它的标签）
    def get_first_label(self, labels):
        first_label_data = labels[0]
        return first_label_data[3]
    # 简单粗暴的获取位置方法
    def get_end_label(self, labels):
        max = len(labels) - 1
        first_label_data = labels[max]
        return first_label_data[1]


