CALHESURFG2NN.m-----首先利用CALHE算法对图像进行特征增强，然后利用SURF算法进行特征提取，最后采用聚类和G2NN进行匹配。
singleSURFG2NN.m----利用SURF算法进行特征提取，最后采用聚类和G2NN进行匹配。
CLAHE.m ------限制对比度自适应直方图增强算法
histadptsurf.m-------采用直方图均衡化预处理后利用SURF进行特征提取。
hsvSURF.m-------------把RGB图像转换到HSV颜色空间后，再利用SURF算法提取特征并进行匹配。
combineHSVclahe2.m-----结合算法hsvSURF.m与CALHESURFG2NN.m