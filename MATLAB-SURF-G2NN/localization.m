
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
 a=16;% ��ȡ����
 for i=1:k
      %��Щ������Ե�ĵ�ûȡ��
     if (loc(i,1)>a/2&&loc(i,1)<m-a/2+1&&loc(i,2)>a/2&&loc(i,2)<n-a/2+1)
          FLM1(loc(i,1)-a/2:loc(i,1)+a/2 ,loc(i,2)-a/2:loc(i,2)+a/2)=0;
     end
 end
%  figure; clf; imshow(FLM1);
 
 %��̬ѧ���� 
  SE=strel('square',16);%ͼ����̬ѧģ��  %(ȡֵ16)
  FLM2=imerode(FLM1,SE); %�ȸ�ʴ
  FLM2=imdilate(FLM2,SE); %������  
%   figure; clf; imshow(FLM2);
  %ȥ��С�������
  s=floor(m*n*0.012);
  FLM3 = bwareaopen(FLM2,s,8);% Ĭ��8����
 figure(1); clf;
 imshow(FLM3);
% subplot(2,2,1) ; imshow(FLM) ;  xlabel('(a) �ؼ���');
% hold on;  plot(loc(:,2)',loc(:,1)','b.');
% subplot(2,2,2) ; imshow(FLM1);   xlabel('(b) ��������');
% subplot(2,2,3) ; imshow(FLM2);   xlabel('(c) ��ʴ����');
% subplot(2,2,4) ; imshow(FLM3);   xlabel('(d) ɾ��С�������');