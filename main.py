import tkinter as tk
from tkinter import filedialog
from tkinter import ttk
import tkinter.messagebox
import visualize
import matlab.engine
import os
from history import History
import image 
import numpy as np
from PIL import ImageFilter
import threading
import detect
import tooltip

# 创建一个GUI类
class GUI(tk.Tk):
    def __init__(self):
        # 调用父类的初始化方法
        super().__init__()
        # 创建一个matlab引擎
        self.eng = matlab.engine.start_matlab()
        # 检测matlab文件路径是否合法
        path = "./MATLAB-SURF-G2NN"
        result = os.path.exists(path)
        if not result:
            tkinter.messagebox.showerror('错误！','MATLAB-SURF-G2NN路径不存在！')
            return

        # 给引擎定位matlab路径
        self.eng.cd(path,nargout=0)
        # 设置窗口标题和大小
        self.title("图像复制粘贴篡改检测系统")
        self.geometry("1280x720")
        # 创建两个画布，用于显示原始图像和结果图像
        self.canvas = tk.Canvas(self, width=610, height=400)
        self.canvas.place(x=650, y = 30)
        self.rec_1 = self.canvas.create_rectangle(2, 2, 608, 398, outline='black', width= 1, fill='white')
        self.canvas.photo = None
        self.origin_canvas = tk.Canvas(self, width= 610, height= 400)
        self.origin_canvas.place(x = 20, y = 30)
        self.rec_2 = self.origin_canvas.create_rectangle(2, 2, 608, 398, outline='black', width= 1, fill='white')
        # 创建两个标签，用于显示提示信息和显示文件路径
        self.label = tk.Label(self, text="请选择要检测的图像文件", font=("Arial", 16))
        self.label_file_path = tk.Label(self, text='文件路径尚未获取', font=("Arial", 16))
        self.label_mode = tk.Label(self, text='模式：', font=("Arial", 16))
        self.label.place(x = 10, y = 450)
        self.label_file_path.place(x = 10, y = 530)
        self.label_mode.place(relx=0.7144375, rely=0.93)
        # 创建一个按钮，用于选择文件
        self.button_file = ttk.Button(self, text="选择文件", command=self.start_loop)
        tooltip.create_tooltip(self.button_file, "将会弹出文件资料窗口来选择你需要的图片")
        self.button_file.place(relx=0.9025625, rely=0.917, width=104.72, height= 40)
        # 创建一个变量，用于存储选择的文件路径
        self.file_path = None
        # 创建一个变量，用于识别所选择的检测模式
        self.mode = 0
        # 创建一个组合框，用于选择检测模式
        var = tk.StringVar()
        self.comb = ttk.Combobox(self, textvariable=var, values=['CALHESURFG2NN', 'singleSURFG2NN', 'histadptsurf','hsvSURF'])
        self.comb.place(relx=0.7619375, rely=0.917, width= 160, height= 40)
        # 绑定一个事件，当组合框被选择时，触发该方法
        self.comb.bind('<<ComboboxSelected>>',lambda event :self.choose_mode())

        #启动时创建一个历史记录类
        self.history = History(self)

        #创建进度条需要的参数
        self.process_total = 0
        self.process_index = 0

        #创建一个空值，方便赋值进程
        self.t = None

        

        #为历史记录窗口添加弹出按钮
        self.button_history = ttk.Button(self, text="查看历史记录", command=lambda: self.history.open_windows())
        tooltip.create_tooltip(self.button_file, "将会弹出已识别的图片记录")
        self.button_history.place(relx=0.9025625, rely=0.85, width=104.72, height= 40)

        #用于处理窗口被关闭时终止进程
        self.stop_event = threading.Event()
        self.process_running = False
        self.protocol("WM_DELETE_WINDOW", self.on_close)


        #添加复选框
        self.checkbox_var = tk.IntVar()
        self.checkbox = ttk.Checkbutton(self, text='将黑白滤镜替换为纯白像素', variable=self.checkbox_var)
        self.checkbox.place(x =10, y = 610)

        self.checkbox_point_var = tk.IntVar()
        self.checkbox_point = ttk.Checkbutton(self, text='是否绘制点', variable=self.checkbox_point_var)
        self.checkbox_point.place(x =10, y = 635)

        self.checkbox_line_var = tk.IntVar()
        self.checkbox_line = ttk.Checkbutton(self, text='是否绘制直线', variable=self.checkbox_line_var)
        self.checkbox_line.place(x =10, y = 660)

        self.checkbox_simple_var = tk.IntVar()
        self.checkbox_simple = ttk.Checkbutton(self, text='启用简单检测方式', variable=self.checkbox_simple_var)
        self.checkbox_simple.place(x =10, y = 685)

        #绘制进度条
        self.process_bar_canvas = tk.Canvas(self, width = 1260, height = 30)
        self.process_bar_canvas.place(x = 10, y = 480)
        self.pogress_bar = self.process_bar_canvas.create_rectangle(0, 0, 0, 30, fill='green')

        
        #绘制分隔线
        separator_text = ttk.Label(self, text='原始图像输入')
        separator_text.place(x = 25, y = 10)

        separator_text_1 = ttk.Label(self, text='检测图像输出')
        separator_text_1.place(x = 655, y = 10)

        separator = ttk.Separator(self, orient='horizontal')
        separator.place(x = 10, y = 20, width= 15, height=2)

        separator_1 = ttk.Separator(self, orient='horizontal')
        separator_1.place(x = 100, y = 20, width= 555, height=2)
        
        separator_2 = ttk.Separator(self, orient='horizontal')
        separator_2.place(x = 730, y = 20, width= 540, height=2)

        separator_3 = ttk.Separator(self, orient='vertical')
        separator_3.place(x = 10, y = 20, width= 2, height=420)

        separator_4 = ttk.Separator(self, orient='vertical')
        separator_4.place(x = 640, y = 20, width= 2, height=420)

        separator_5 = ttk.Separator(self, orient='vertical')
        separator_5.place(x = 1270, y = 20, width= 2, height=420)

        separator_6 = ttk.Separator(self, orient='horizontal')
        separator_6.place(x = 10, y = 440, width= 1260, height=2)

        self.label_report_text = ttk.Label(self, text='', font=("Arial", 16))
        self.label_report_text.place(x=10, y =560)

        separator_text_2 = ttk.Label(self, text='配置')
        separator_text_2.place(x = 25, y = 590)

        separator_8 = ttk.Separator(self, orient='horizontal')
        separator_8.place(x = 10, y =600, width= 15, height=2)

        separator_9 = ttk.Separator(self, orient='horizontal')
        separator_9.place(x = 52.5, y = 600, width= 1212.5, height=2)

        separator_text_2 = ttk.Label(self, text='状态报告')
        separator_text_2.place(x = 25, y = 510)

        separator_10 = ttk.Separator(self, orient='horizontal')
        separator_10.place(x = 10, y =520, width= 15, height=2)

        separator_11 = ttk.Separator(self, orient='horizontal')
        separator_11.place(x = 77.5, y = 520, width= 1183.5, height=2)
    
    # 选择文件时启动新进程
    def start_loop(self):
        self.process_running = True
        self.t = threading.Thread(target=self.select_file)
        self.t.start()

    # 处理程序关闭
    def on_close(self):
        if self.process_running:
            self.process_running = False
            self.t.join()
        self.destroy()

    # 更新进度条
    def update_progress_bar(self, percent):
        self.process_bar_canvas.coords(self.pogress_bar, 0, 0, percent * 1260 / 100, 30)

    # 定义一个选择文件的方法
    def select_file(self):
        # 配置进度条上方的文字信息
        self.label.config(text='过程：' + "正在选择文件")

        self.update_progress_bar(50)

        # 关闭复选框状态，防止误碰
        self.checkbox.config(state='disabled')
        self.checkbox_line.config(state='disabled')
        self.checkbox_point.config(state='disabled')
        self.checkbox_simple.config(state='disabled')
        # 弹出一个文件对话框，让用户选择要检测的图像文件，并返回文件路径和文件名称
        self.file_path = filedialog.askopenfilename(title="请选择要检测的图像文件", filetypes=[("图像文件", ".jpg .png .bmp")])
        file_name_list = self.file_path.split('/')
        self.file_name = file_name_list[len(file_name_list) - 1]
        # 如果用户选择了文件
        if self.file_path and self.check_image_legal():
            self.update_progress_bar(100)
            # 在标签上显示选择的文件路径
            self.label_file_path.config(text='文件路径：' + self.file_path)
            # 判断组合框中的模式
            if self.mode == 0:
                # 调用检测方法，传入文件路径
                self.update_progress_bar(0)

                self.label.config(text='过程：' + "正在以CLAHESURFG2NN模式处理")

                result = self.eng.CLAHESURFG2NN(self.file_name, self.file_path)
                # 将通过matlab处理后的结果交给处理图片方法处理

                self.deal_image(result)
            elif self.mode == 1:
                self.update_progress_bar(0)
                self.label.config(text='过程：' + "正在以singleSURFG2NN模式处理")

                result = self.eng.singleSURFG2NN(self.file_name, self.file_path)

                self.deal_image(result)
            elif self.mode == 2:
                self.update_progress_bar(0)
                self.label.config(text='过程：' + "正在以histadptsurf模式处理")

                result = self.eng.histadptsurf(self.file_name, self.file_path)

                self.deal_image(result)
            elif self.mode == 3:
                self.update_progress_bar(0)
                self.label.config(text='过程：' + "正在以hsvSURF模式处理")

                result = self.eng.hsvSURF(self.file_name, self.file_path)

                self.deal_image(result)
            else:
                #由于时间紧，其他模式未完成
                tkinter.messagebox.showerror(title='警告', message='该功能未完成')
        else:
            # 善后取消选择文件之后的事
            self.update_progress_bar(0)
            self.label.config(text='请选择要检测的图像文件')
            self.checkbox.config(state='active')
            self.checkbox_line.config(state='active')
            self.checkbox_point.config(state='active')
            self.checkbox_simple.config(state='active')

            
    # 定义一个检测图片的合法性的方法
    def check_image_legal(self):
        # 读取文件路径下的图片
        img = image.read_image(self.file_path)
        # 判断图片长宽是否超过阈值
        if (img.width <= 1920 and img.height <= 1080):
            return True
        else:
            tkinter.messagebox.showerror(title='警告', message='该图像像素为' + str(img.width) + 'x' + str(img.height) + ',超过限定的1920x1080范围，将会可能导致程序无响应，已经停止该行为，请使用其他图片！')
            return False

    # 定义一个与组合框相绑定的触发方法
    def choose_mode(self):
        #当组合框变化时，跟随所选的内容变更该变量的数值
        self.mode = self.comb.current()

    # 定义一个用于处理通过matlab返回的结果中的x，y坐标组([x1,x2,x3,...][y1,y2,y3,...])的方法
    def deal_point_pos(self, pos, mode):
        # 创建一个临时变量
        temp = pos
        # 创建一个空数组
        new_list = []
        # 创建一个变量
        i = 0
        if mode == 0:
            # 将x，y坐标组分别取得x坐标组和y坐标组
            list_x = temp[0]
            list_y = temp[1]
            # 整理x,y坐标组，使结果为[[x1,y1],[x2,y2],[...]]
            for x in list_x:
                new_list.append([x, list_y[i]])
                i += 1
            # 将整理好的坐标组返回
            return new_list
        elif mode == 1:
            for data in temp:
                new_list.append([data[0], data[1]])
            return new_list
        return temp

    # 定义一个用于处理图片的方法，参数为从matlab函数返回的结果
    def deal_image(self, result):
        self.update_progress_bar(30)
        #从文件路径获取图片
        img = image.read_image(self.file_path)
        # 从结果获取第一个坐标组
        pos1 = result['pixel1']
        # 从结果获取第二个坐标组
        pos2 = result['pixel2']
        # 从结果获取参考点
        point = result['point_get']
        # 从结果获取所用的时间
        cost_time = result['cost_time']
        # 如果所获取的数据表示该图片没有篡改，则只显示原始图像
        if not pos1:
            self.update_progress_bar(100)
            self.deal_image_origin(img)
        else:
            self.update_progress_bar(100)
            self.label_report_text.config(text='已获取' + str(int(point)) + '个匹配点')
            # self.process_gui.process_label_text.config(text='处理完毕，用时：' + str(cost_time) + "s,接下来将要筛选复制区域" )
            self.label.config(text='处理完毕，用时：' + str(cost_time) + "s,接下来将要筛选复制区域" )
            threading.Event().wait(3)     
            # 专门给除了C算法以外的其他算法
            if self.mode == 1 or self.mode == 2 or self.mode == 3:
                now_pos1 = result['new_pixel1']
                now_pos2 = result['new_pixel2']
                new_pos1 = self.deal_point_pos(now_pos1, 1)
                new_pos2 = self.deal_point_pos(now_pos2, 1)
                # self.deal_image_and_draw(point, new_pos1, new_pos2, img)
                self.deal_image_and_draw(point, new_pos1, new_pos2, img)
                self.update_progress_bar(100)
                if(new_pos1 == []):
                    self.label.config(text='该软件不支持绘制被复制超过三个以上的图像的位置' )
            # C算法
            else:
                new_pos1 = self.deal_point_pos(pos1, 0)
                new_pos2 = self.deal_point_pos(pos2, 0)
                self.deal_image_and_draw(point, new_pos1, new_pos2, img)
                self.update_progress_bar(100)
                if(new_pos1 == []):
                    self.label.config(text='该软件不支持绘制被复制超过三个以上的图像的位置' )

    # 处理图片并绘制图片
    def deal_image_and_draw(self, point, pos1, pos2, img):
        # 将图片转化成numpy的像素数组
        img_array = self.convert_image_to_nparray(img)
        # 将像素数组和匹配点拿去处理，获取黑白滤镜区域
        regions = self.compare_nparray(img_array, pos1, pos2)

        # 处理复选框配置
        checkbox_bool = False
        checkbox_line_bool = False
        checkbox_point_bool = False
        if self.checkbox_var.get() == 1:
            checkbox_bool = True
        if self.checkbox_line_var.get() == 1:
            checkbox_line_bool = True
        if self.checkbox_point_var.get() == 1:
            checkbox_point_bool = True

        # 获取由visualize.py绘制好的图像
        new_image = visualize.draw_regions(img, pos1, pos2, regions, checkbox_bool, checkbox_point_bool , checkbox_line_bool)
        # 通过detect.py获取分数
        score = detect.detect_score(img, regions)
        # 标签报告
        self.label.config(text="检测结果：该图像有复制粘贴篡改的痕迹,   置信度评分：" + str(score))
        # 删除画布背景
        self.canvas.delete(self.rec_1)
        self.origin_canvas.delete(self.rec_2)
        # 显示图片
        visualize.show_image(self.canvas, new_image)
        visualize.show_image(self.origin_canvas, img)
        # 将图片记入历史记录类的数据
        self.history.add_data(img, new_image, self.mode, score)
        # 善后
        self.checkbox.config(state='active')
        self.checkbox_line.config(state='active')
        self.checkbox_point.config(state='active')
        self.checkbox_simple.config(state='active')

    # 若没有结果，则处理原始图像
    def deal_image_origin(self, img):
        # 标签报告
        self.label.config(text="检测结果：该图像没有复制粘贴篡改的痕迹")
            # 显示图片
        visualize.show_image(self.origin_canvas, img)
            # self.origin_image = img
     
    # 将图片转化成numpy的像素数组，便于对比像素
    def convert_image_to_nparray(self, img):
        # 减噪处理
        blurred_image = img.filter(ImageFilter.GaussianBlur(radius=0.5))
        return np.array(blurred_image) 

    # 初步对比图片中的获取的匹配点两个像素的颜色，然后把获得的正确的匹配点交给check_region_edge处理
    def compare_nparray(self, array_1, pos1, pos2):
        reference_points_1 = []
        reference_points_2 = []
        for index in range(len(pos1)):
            pos_1 = pos1[index]
            pos_2 = pos2[index]
            x1 = round(pos_1[0])
            y1 = round(pos_1[1])
            x2 = round(pos_2[0])
            y2 = round(pos_2[1])
            pos1_color = array_1[y1, x1]
            pos2_color = array_1[y2, x2]

            if np.array_equal(pos1_color, pos2_color):
                reference_points_1.append([x1, y1])
                reference_points_2.append([x2, y2])

        return self.check_region_edge(array_1, reference_points_1, reference_points_2)
    
    # 该算法思路的是通过检查并筛选每个匹配点附近的一百个像素（以正方形分布）颜色参数是否相同，若相同则该位置会加入绘制黑白滤镜的小组
    def check_region_edge(self, array_1, reference_points_1, reference_points_2):
        pos1 = []
        pos2 = []

        #获取进度的最大值
        self.process_total = len(reference_points_1)     
        
        for index in range(len(reference_points_1)):
            reference_point_1 = reference_points_1[index]
            reference_point_2 = reference_points_2[index]
            x1 = reference_point_1[0]
            y1 = reference_point_1[1]
            x2 = reference_point_2[0]
            y2 = reference_point_2[1]

            # 同步进度条
            self.process_index = index
            
            # 用于终止进程
            if not self.process_running:
                return
            # 范围
            range_num = 100

            # 简单处理判断
            checkbox_simple_bool = False
            if self.checkbox_simple_var.get() == 1:
                checkbox_simple_bool = True
            # 匹配点过多，则把范围减小
            if len(reference_points_1) > 20 or checkbox_simple_bool:
                range_num = 25
                self.label.config(text='过程：' + f"{index + 1} " " \ "+ f' {len(reference_points_1) + 1}' + ' (由于匹配点过多，开始简单处理)')
            else:
                self.label.config(text='过程：' + f"{index + 1} " " \ "+ f' {len(reference_points_1) + 1}')
            # 处理进度条绘制
            ratio = round((index / len(reference_points_1)) * 100, 1) 
            self.update_progress_bar(ratio)
            # 处理一个匹配点后的等候
            threading.Event().wait(0.5)     

            # 筛选
            for range_num_x in range(-range_num, range_num):
                for range_num_y in range(-range_num, range_num):
                    if y1 + range_num_y >= len(array_1) or x1 + range_num_x >= len(array_1[0]) or y2 + range_num_y >= len(array_1) or x2 + range_num_x >= len(array_1[0]):
                        break
                    if y1 + range_num_y <= 0 or x1 + range_num_x <= 0 or y2 + range_num_y <= 0 or x2 + range_num_x <= 0:
                        break
                    pos1_color = array_1[y1 + range_num_y, x1 + range_num_x]
                    pos2_color = array_1[y2 + range_num_y, x2 + range_num_x]

                    if np.array_equal(pos1_color, pos2_color):
                        pos1.append([x1 + range_num_x, y1 + range_num_y])
                        pos2.append([x2 + range_num_x, y2 + range_num_y])
                    else :
                    if not self.process_running:
                        return
        # 终止进程
        if not self.process_running:
            return
        return [pos1, pos2]

# 创建一个GUI对象
gui = GUI()
# 运行GUI界面
gui.mainloop()


