clear all  
% I=imread('篡改—高尔夫草地-截取.jpg');
[filename,pathname]=...
    uigetfile({'*.png';'*.bmp';'*.jpg';'*.gif';},'');
str=[pathname,filename];
x=imread(str);
I=x;
% I=imread('Image_01.jpg');
% I=imread('japan_tower_copy.png');
figure  
subplot(2,2,1)  
imshow(I)%显示原始图像
title('输入的彩色图像')                         
I_gray = rgb2gray(I); %灰度化后的数据存入数组  
imwrite(I_gray,'1_gray.bmp'); %保存灰度图像  
subplot(2,2,2),imhist(I_gray);  
title('灰度直方图')  %直方图均衡化 
I=I_gray;
%%%%%%%%%%%%%如果原图像为灰度图像直接使用本部分程序
%  I = imread('rice.png'); 
% figure  
% subplot(2,2,1)  
% imshow(I)%显示原始图像
% title('输入的彩色JPG图像')   
% subplot(2,2,2)  
% imhist(I)%显示原始图像直方图     
%%%%%%%%%%%%
  [height,width] = size(I);
%进行像素灰度统计;  
NumPixel = zeros(1,256);%统计各灰度数目，共256个灰度级  
for i = 1:height  
    for j = 1: width  
        NumPixel(I(i,j)+1) = NumPixel(I(i,j)+1) + 1;%对应灰度值像素点数量增加一  
    end  
end  
%计算灰度分布密度  
ProbPixel = zeros(1,256);  
for i = 1:256  
    ProbPixel(i) = NumPixel(i) / (height * width * 1.0);  
end  
%计算累计直方图分布  
CumuPixel = zeros(1,256);  
for i = 1:256  
    if i == 1  
        CumuPixel(i) = ProbPixel(i);  
    else  
        CumuPixel(i) = CumuPixel(i - 1) + ProbPixel(i);  
    end  
end  
%累计分布取整,将其数值归一化为1~256   
CumuPixel = uint8(256 .* CumuPixel + 0.5);  
%对灰度值进行映射（均衡化）  
for i = 1:height  
    for j = 1: width  
        I(i,j) = CumuPixel(I(i,j)+1);  
    end  
end  
  
subplot(2,2,3)  
imshow(I)%显示原始图像  
subplot(2,2,4)  
imhist(I)%显示原始图像直方图  
x=im2double(I);
I1=x;
%   I1=imread('TestImages/Image_01.jpg');
%   I2=imread('TestImages/eight30.jpg');
% Get the Key Points
  Options.upright=true;
  Options.tresh=0.00001;
  Ipts1=OpenSurf(I1,Options);
%   Ipts2=OpenSurf(I2,Options);
% Put the landmark descriptors in a matrix
  D1 = reshape([Ipts1.descriptor],64,[]); 
  descs=D1';
 temp1= reshape([Ipts1.x],1,[]);
 temp2= reshape([Ipts1.y],1,[]);


% % % % % % % % % % % % % % 
 locs=[temp2',temp1'];
metric='single';   thc=0.02;  % 原程序 thc=0.05;  
thc=thc*max(size(I1));
min_cluster_pts=3;  
plotimg=1;   display=0;   num_gt=0;
% [num1, locs, descs] = import_sift(siftfile);  %n*4  n*128  是用来看提取到多少sift点
% 原来我用C提取的sift点 也是lowe法了
[num p1 p2 tp] = match_features(locs,descs);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

if size(p1,1)==0
    num_gt=0;
else
    p=[p1(1:2,:) p2(1:2,:)]';  
    % Hierarchical Agglomerative Clustering
    distance_p=pdist(p);
    Z = linkage(distance_p,metric);
    I = inconsistent(Z);
     c = cluster(Z,'cutoff',thc,'Criterion','distance'); 
 
     
 if (plotimg==1)
        figure
        imshow(I1);
        N1=size(p1,2);
        fprintf('初始匹配点数%d \n',N1);
        hold on
        for i = 1:N1 
            line([p1(1,i)' p2(1,i)'], [p1(2,i)' p2(2,i)'], 'Color', 'c');
        end
         gscatter(p(:,1),p(:,2),c,'','','','off');%根据类别来画离散点
  end

 % given clusters of matched points compute the number of transformations 
   X1=[];
    c_max = max(c);
    if(c_max > 1)
        n_combination_cluster = combntns(1:c_max,2);%当c_max=3时，结果为[1 2;1 3;2 3]各种类的组合

         pos1=[];pos2=[];%存放排除了点数少于某阈值的匹配对的坐标         
        for i=1:1:size(n_combination_cluster,1)
            k=n_combination_cluster(i,1);
            j=n_combination_cluster(i,2);
            z1=[];    z2=[];
            inliers1=[];inliers2=[];%
            for r=1:1:size(p1,2)
                if c(r)==k && c(r+size(p1,2))==j
                    z1 = [z1; [p(r,:) 1]];
                    z2 = [z2; [p(r+size(p1,2),:) 1]];
                end
                if c(r)==j && c(r+size(p1,2))==k
                    z1 = [z1; [p(r+size(p1,2),:) 1]];
                    z2 = [z2; [p(r,:) 1]];
                end
            end
        
            %z1 are coordinates of points in the first cluster 
            %z2 are coordinates of points in the second cluster            
            if (size(z1,1) > min_cluster_pts && size(z2,1) > min_cluster_pts)                
                % run ransacfithomography for affine homography
                t=0.0055;   %0.001 ~ 0.01  
                [H, inliers, dx, dy, xc, yc] = ransacfithomography2(z1', z2', t);  
                  H=H/H(3,3);
                 if(display==1)          
                   A2=H(1:2,1:2);
                  [U,S,V]=svd(A2);
                    R1=U*V';
                   theta=atan2(R1(2,1),R1(1,1));
                   fprintf(2,'奇异值分解所得几何变换参数:\n');
                   fprintf('反正切得到的旋转角度： %.3f 度\n',theta);
                   fprintf('x方向的尺度因子： %.3f \n',S(1,1));
                    fprintf('y方向的尺度因子： %.3f \n',S(2,2));
                    fprintf('x方向的位移： %.2f 像素\n',abs(dx));
                    fprintf('y方向的位移： %.2f 像素\n',abs(dy));
                 end
                  
                 if size(H,1)==0
                    num_gt = num_gt;
                 else
                    H = H / H(3,3);
                    num_gt = num_gt+1;
                    inliers1 = [inliers1; [z1(inliers,1) z1(inliers,2)]];
                    inliers2 = [inliers2; [z2(inliers,1) z2(inliers,2)]];
                 end                
            end   
             pos1=[pos1;inliers1];  pos2=[pos2;inliers2];
        end 
        X1=[pos1;pos2];%[x1 y1;...x1' y1';....]
    end
% % % % % % % % % % % 
%   figure;  %经过一次聚类和ransac消除误配后的再次聚类图（写在此处是为了考虑X1为空的情况能显示原图）
%   imshow(I1); hold on;
%  N2=size(pos1,1);
%  if N2>0
%      for i=1:N2
%            plot([pos1(i,1)  pos2(i,1)],[pos1(i,2)  pos2(i,2)],'-','color','c');
%         end 
% %           gscatter(X1(:,1),X1(:,2), c,'','','','off') ;
%  end
end

% % % % % % % % % % % %  
  figure;  %经过一次聚类和ransac消除误配后的再次聚类图（写在此处是为了考虑X1为空的情况能显示原图）
  imshow(I1); hold on;
if size(X1,1)>0 %       
    % Hierarchical Agglomerative Clustering
    Y=pdist(X1);
    Z1 = linkage(Y,metric);
    T1 = cluster(Z1,'cutoff',thc,'Criterion','distance'); 
    N=size(pos1,1);
    fprintf('最终匹配点数%d \n',N);
    for i=1:N
        plot([pos1(i,1)  pos2(i,1)],[pos1(i,2)  pos2(i,2)],'-','color','c');
    end  
     gscatter(X1(:,1),X1(:,2),T1,'','','','off')  
end
 