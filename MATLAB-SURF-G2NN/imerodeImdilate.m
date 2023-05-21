%% 对应小论文图2 ，划分平滑区域的一个例子

clc;
clear all;
tic;
 FLM=ones(200,200);
%  row=rand(20,1)*200;
%  col=rand(20,1)*200;
 loc=[60 60 60 70 80 80 90 90 100 110 105 130 130 120; 120 100 60 80 85 110 100 120 100 80 110 90 90 120];
%  loc=[30 30 30 35 40 40 45 45  50  50  53  65 65 ;  60 50  30 40 43 55 50 60 50 40 55 43 65];
loc=loc';
k=size(loc,1);
 [m,n]=size(FLM);
 FLM(sub2ind(size(FLM),loc(:,1),loc(:,2)))=0;
%  figure; clf;
%  imshow(FLM);
%  hold on;
% plot(loc(:,2)',loc(:,1)','b.');
FLM1=FLM;
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
 
 
 
 
 
 
 