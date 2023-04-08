# 导入所需的库
from PIL import Image

# 定义一个读取图像文件的函数，接收一个文件路径作为参数，返回一个图像对象
def read_image(file_path):
    # 使用PIL库中的Image类的open方法，打开文件路径对应的图像文件，并返回一个图像对象
    img = Image.open(file_path)
    # 返回图像对象
    return img

# 定义一个提取图像特征的函数，接收一个图像对象作为参数，返回一个特征向量
def extract_features(img):
    # 使用PIL库中的Image类的convert方法，将图像对象转换为灰度模式，并返回一个新的图像对象
    img = img.convert("L")
    # 使用PIL库中的Image类的resize方法，将图像对象缩放为64x64像素，并返回一个新的图像对象
    img = img.resize((64, 64))
    # 使用PIL库中的Image类的getdata方法，获取图像对象中的像素数据，并返回一个列表
    data = list(img.getdata())
    # 将列表转换为一个特征向量，并返回
    vector = [float(x) / 255 for x in data]
    return vector

# 定义一个比较两个特征向量相似度的函数，接收两个特征向量作为参数，返回一个相似度值
def compare_similarity(vector1, vector2):
    # 使用欧几里得距离公式，计算两个特征向量之间的距离，并返回
    distance = sum([(x - y) ** 2 for x, y in zip(vector1, vector2)]) ** 0.5
    # 使用相似度公式，将距离转换为相似度，并返回
    similarity = 1 / (1 + distance)
    return similarity