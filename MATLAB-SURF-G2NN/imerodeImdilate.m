%% ��ӦС����ͼ2 ������ƽ�������һ������

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
 a=16;% ��ȡ����
 for i=1:k
      %��Щ������Ե�ĵ�ûȡ��
     if (loc(i,1)>a/2&&loc(i,1)<m-a/2+1&&loc(i,2)>a/2&&loc(i,2)<n-a/2+1)
          FLM1(loc(i,1)-a/2:loc(i,1)+a/2 ,loc(i,2)-a/2:loc(i,2)+a/2)=0;
     end
 end
%  figure; clf; imshow(FLM1);
 
 %��̬ѧ���� 
  SE=strel('square',5);%ͼ����̬ѧģ��  %(ȡֵ16)
  FLM2=imerode(FLM1,SE); %�ȸ�ʴ
  FLM2=imdilate(FLM2,SE); %������  
%   figure; clf; imshow(FLM2);
  %ȥ��С�������
  s=floor(m*n*0.012);
  FLM3 = bwareaopen(FLM2,s,8);% Ĭ��8����
%   figure; clf; imshow(FLM3);
figure(1); clf;
subplot(2,2,1) ; imshow(FLM) ;  xlabel('(a) �ؼ���');
hold on;  plot(loc(:,2)',loc(:,1)','b.');
subplot(2,2,2) ; imshow(FLM1);   xlabel('(b) ��������');
subplot(2,2,3) ; imshow(FLM2);   xlabel('(c) ��ʴ����');
subplot(2,2,4) ; imshow(FLM3);   xlabel('(d) ɾ��С�������');
 
 
 
 
 
 
 