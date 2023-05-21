
function localization(image,loc)
 FLM=image;
k=size(loc,1);
loc=[loc(:,2) loc(:,1)];
 [m,n]=size(FLM);
%  FLM(sub2ind(size(FLM),loc(:,2),loc(:,1)))=0;
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
  SE=strel('square',16);%图像形态学模板  %(取值16)
  FLM2=imerode(FLM1,SE); %先腐蚀
  FLM2=imdilate(FLM2,SE); %后膨胀  
%   figure; clf; imshow(FLM2);
  %去掉小面积区域
  s=floor(m*n*0.012);
  FLM3 = bwareaopen(FLM2,s,8);% 默认8领域
 figure(1); clf;
 imshow(FLM3);
% subplot(2,2,1) ; imshow(FLM) ;  xlabel('(a) 关键点');
% hold on;  plot(loc(:,2)',loc(:,1)','b.');
% subplot(2,2,2) ; imshow(FLM1);   xlabel('(b) 画正方形');
% subplot(2,2,3) ; imshow(FLM2);   xlabel('(c) 腐蚀膨胀');
% subplot(2,2,4) ; imshow(FLM3);   xlabel('(d) 删除小面积区域');