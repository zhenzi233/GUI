%%%%%%%%%%%%本算法：用SURF算法进行特征提取，采用聚类和G2NN算法进行匹配，可检测多重复制粘贴篡改问题，加入腐蚀等形态学处理
%clc;算法有问题，
clear all;
tic
[filename,pathname]=...
    uigetfile({'*.png';'*.bmp';'*.jpg';'*.gif';},'');
str=[pathname,filename];
x=imread(str);
I1=x;
% % % % % % % % % % % % % % 
 I1=rgb2gray(I1);
 figure
 imhist(I1)
 I1 = adapthisteq(I1,'NumTiles',[16 16 ],'ClipLimit',0.5,'Distribution','rayleigh'); %rayleigh,'exponential'
% % % % % % % % % % % % % % % 
% figure 
% imshow(I1)
% imhist(I1)
%   I1=imread('TestImages/Image_01.jpg');
%   I2=imread('TestImages/eight30.jpg');
% Get the Key Points
  Options.upright=true;
  Options.tresh=0.0001;
  Ipts1=OpenSurf(I1,Options);
%   Ipts2=OpenSurf(I2,Options);
% Put the landmark descriptors in a matrix
  D1 = reshape([Ipts1.descriptor],64,[]); 
  descs=D1';
 temp1= reshape([Ipts1.x],1,[]);
 temp2= reshape([Ipts1.y],1,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%
%         figure
%         imshow(x);
%         hold on
%         for i=1:size(temp1,2)
%              plot(temp1(i),temp2(i),'.','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',5)
%              hold on
%         end
%         
% % % % % % % % % % % % % % 
 locs=[temp2',temp1'];
metric='single'; 
% thc=0.02;   thc=thc*max(size(I1));
thc=30;
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
%     c = cluster(Z,'cutoff',46,'Criterion','distance');
%      c = cluster(Z,'cutoff',thc,'depth',4);
     
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
                t=0.05;   
                [H, inliers, dx, dy, xc, yc] = ransacfithomography2(z1', z2', t);
                  
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
 
%   figure;  %经过一次聚类和ransac消除误配后的再次聚类图（写在此处是为了考虑X1为空的情况能显示原图）
   imshow(x); hold on;
if size(X1,1)>0 %       
    % Hierarchical Agglomerative Clustering
    Y=pdist(X1);
    Z1 = linkage(Y,metric);
     T1 = cluster(Z1,'cutoff',thc,'Criterion','distance');   

    for i=1:size(pos1,1)
        plot([pos1(i,1)  pos2(i,1)],[pos1(i,2)  pos2(i,2)],'-','color','c');
    end  
     gscatter(X1(:,1),X1(:,2),T1,'','','','off')   
end
end 
% %根据以上的二次聚类来再次消除误匹配
%    X2=[];
%   T_max=max(T1);
%   if(T_max>1)
%       n_combination_cluster1 = combntns(1:T_max,2);
%       pos3=[];pos4=[];
%        for i=1:1:size(n_combination_cluster1,1)
%             k1=n_combination_cluster1(i,1);
%             j1=n_combination_cluster1(i,2);
%             z3=[];
%             z4=[];
%             inliers3=[];inliers4=[];
%             for r=1:1:size(pos1,1)
%                 if T1(r)==k1 && T1(r+size(pos1,1))==j1  %  pos1:nx2
%                     z3 = [z3; [X1(r,:) 1]];
%                     z4 = [z4; [X1(r+size(pos1,1),:) 1]];
%                 end
%                 if T1(r)==j1 && T1(r+size(pos1,1))==k1
%                     z3 = [z3; [X1(r+size(pos1,1),:) 1]];
%                     z4 = [z4; [X1(r,:) 1]];
%                 end
%             end
%            if (size(z3,1) > min_cluster_pts && size(z4,1) > min_cluster_pts)                             
%              pos3=[pos3;z3];  pos4=[pos4;z4] ; %jia
%            end  %jia
%        end
%        X2=[pos3;pos4];%[x1 y1;...x1' y1';....]  %
%   end
%   
%      figure; %先显示原图，若X2有值，则此图为最终匹配对；若无值，则此图为原始图像，表误匹配全消除 
%      imshow(I1);  xlabel('本文算法'); hold on;
%     if X2>0
%        % Hierarchical Agglomerative Clustering
%        Y2=pdist(X2);
%        Z2 = linkage(Y2,metric);
%        T2 = cluster(Z2,'cutoff',30,'Criterion','distance');
%      N2=size(pos3,1);
%      fprintf('最终找到%d个匹配点\n',N2);
%         for i=1:N2
%            plot([pos3(i,1)  pos4(i,1)],[pos3(i,2)  pos4(i,2)],'-','color','c');
%         end 
%          gscatter(X2(:,1),X2(:,2),T2,'','','','off') ;
%     else  num_gt=0; 
%     end
% 
% else  num_gt=0; %暂加
% end  %暂加
% end
% 
% if(plotimg==1)
% % tampering detection
% if(num_gt)
%     fprintf('Tampering detected!\n\n');
% else
%     fprintf('Image not tampered.\n\n');
% end
% end
% fprintf(2,'检测用时%f秒\n',toc);
% 
% % % % % % % % % % % % % % % % 篡改区域定位
%  FLM=ones(200,200);
%  row=rand(20,1)*200;
%  col=rand(20,1)*200;
%  loc=[60 60 60 70 80 80 90 90 100 110 105 130 130 120; 120 100 60 80 85 110 100 120 100 80 110 90 90 120];
%  loc=[30 30 30 35 40 40 45 45  50  50  53  65 65 ;  60 50  30 40 43 55 50 60 50 40 55 43 65];
% loc=loc';
hold on
loc=pos1;
k=size(loc,1);
 [m,n]=size(I1);
 I1(sub2ind(size(I1),loc(:,1),loc(:,2)))=0;
%  figure; clf;
%  imshow(FLM);
%  hold on;
% plot(loc(:,2)',loc(:,1)','b.');
FLM1=I1;
 a=16;% 所取方块
 for i=1:k
      %有些靠近边缘的点没取块
     if (loc(i,1)>a/2&&loc(i,1)<m-a/2+1&&loc(i,2)>a/2&&loc(i,2)<n-a/2+1)
          FLM1(loc(i,1)-a/2:loc(i,1)+a/2 ,loc(i,2)-a/2:loc(i,2)+a/2)=0;
     end
 end
%  figure; clf; imshow(FLM1);
 
 %形态学处理 
  SE=strel('square',5);%图像形态学模板  %(取值16)
  FLM2=imerode(FLM1,SE); %先腐蚀
  FLM2=imdilate(FLM2,SE); %后膨胀  
%   figure; clf; imshow(FLM2);
  %去掉小面积区域
  s=floor(m*n*0.012);
  FLM3 = bwareaopen(FLM2,s,8);% 默认8领域
%   figure; clf; imshow(FLM3);
figure(1); clf;
subplot(2,2,1) ; imshow(FLM) ;  xlabel('(a) 关键点');
hold on;  plot(loc(:,2)',loc(:,1)','b.');
subplot(2,2,2) ; imshow(FLM1);   xlabel('(b) 画正方形');
subplot(2,2,3) ; imshow(FLM2);   xlabel('(c) 腐蚀膨胀');
subplot(2,2,4) ; imshow(FLM3);   xlabel('(d) 删除小面积区域');