function result = histadptsurf(file_name, file_path)
%������Ϊ��ͼ�����ֱ��ͼ���⻯Ԥ��������ʹ��SURF��ȡ�����㣬Ȼ�����G2NN����ƥ��ĸ���ճ���۸ļ���㷨
% clear all  
% I=imread('�۸ġ��߶���ݵ�-��ȡ.jpg');
pathname = file_path;
str=pathname;
x=imread(str);
I=x;
% I=imread('Image_01.jpg');
% I=imread('japan_tower_copy.png');
figure  
subplot(2,2,1)  
imshow(I)%��ʾԭʼͼ��
title('����Ĳ�ɫJPGͼ��')                         
I_gray = rgb2gray(I); %�ҶȻ�������ݴ�������  
% imwrite(I_gray,'1_gray.bmp'); %����Ҷ�ͼ��  
subplot(2,2,2),imhist(I_gray);  
title('�Ҷ�ֱ��ͼ')  %ֱ��ͼ���⻯ 
I=I_gray;
%%%%%%%%%%%%%���ԭͼ��Ϊ�Ҷ�ͼ��ֱ��ʹ�ñ����ֳ���
%  I = imread('rice.png'); 
% figure  
% subplot(2,2,1)  
% imshow(I)%��ʾԭʼͼ��
% title('����Ĳ�ɫJPGͼ��')   
% subplot(2,2,2)  
% imhist(I)%��ʾԭʼͼ��ֱ��ͼ     
%%%%%%%%%%%%
  [height,width] = size(I);
%�������ػҶ�ͳ��;  
NumPixel = zeros(1,256);%ͳ�Ƹ��Ҷ���Ŀ����256���Ҷȼ�  
for i = 1:height  
    for j = 1: width  
        NumPixel(I(i,j)+1) = NumPixel(I(i,j)+1) + 1;%��Ӧ�Ҷ�ֵ���ص���������һ  
    end  
end  
%����Ҷȷֲ��ܶ�  
ProbPixel = zeros(1,256);  
for i = 1:256  
    ProbPixel(i) = NumPixel(i) / (height * width * 1.0);  
end  
%�����ۼ�ֱ��ͼ�ֲ�  
CumuPixel = zeros(1,256);  
for i = 1:256  
    if i == 1  
        CumuPixel(i) = ProbPixel(i);  
    else  
        CumuPixel(i) = CumuPixel(i - 1) + ProbPixel(i);  
    end  
end  
%�ۼƷֲ�ȡ��,������ֵ��һ��Ϊ1~256   
CumuPixel = uint8(256 .* CumuPixel + 0.5);  
%�ԻҶ�ֵ����ӳ�䣨���⻯��  
for i = 1:height  
    for j = 1: width  
        I(i,j) = CumuPixel(I(i,j)+1);  
    end  
end  
  
subplot(2,2,3)  
imshow(I)%��ʾԭʼͼ��  
subplot(2,2,4)  
imhist(I)%��ʾԭʼͼ��ֱ��ͼ  
x=im2double(I);
I1=x;
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
 locs=[temp2',temp1'];
metric='single';   thc=0.03;  % ԭ���� thc=0.05;  
thc=thc*max(size(I1));
min_cluster_pts=3;  
plotimg=1;   display=0;   num_gt=0;
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
        fprintf('��ʼƥ�����%d \n',N1);
        hold on
        for i = 1:N1 
            line([p1(1,i)' p2(1,i)'], [p1(2,i)' p2(2,i)'], 'Color', 'c');
        end
         gscatter(p(:,1),p(:,2),c,'','','','off');%�������������ɢ��
  end

 % given clusters of matched points compute the number of transformations 
   X1=[];
    c_max = max(c);
    if(c_max > 1)
        n_combination_cluster = combntns(1:c_max,2);%��c_max=3ʱ�����Ϊ[1 2;1 3;2 3]����������

         pos1=[];pos2=[];%����ų��˵�������ĳ��ֵ��ƥ��Ե�����         
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
                t=0.05;   %0.001 ~ 0.01  
                [H, inliers, dx, dy, xc, yc] = ransacfithomography2(z1', z2', t);  
                  H=H/H(3,3);
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
end

% % % % % % % % % % % %  
  figure;  %����һ�ξ����ransac�����������ٴξ���ͼ��д�ڴ˴���Ϊ�˿���X1Ϊ�յ��������ʾԭͼ��
  imshow(I1); hold on;
if size(X1,1)>0 %       
    % Hierarchical Agglomerative Clustering
    Y=pdist(X1);
    Z1 = linkage(Y,metric);
    T1 = cluster(Z1,'cutoff',thc,'Criterion','distance'); 
    N=size(pos1,1);
    fprintf('����ƥ�����%d \n',N);
    for i=1:N
        plot([pos1(i,1)  pos2(i,1)],[pos1(i,2)  pos2(i,2)],'-','color','c');
    end  
     gscatter(X1(:,1),X1(:,2),T1,'','','','off')  
end
result.pixel1 = p1;
result.pixel2 = p2;
if(p1)
    result.new_pixel1 = z1;
    result.new_pixel2 = z2;
end
if(p1)
    result.point_get = N1;
else
    result.point_get = 0;
end
result.is_tampered = num_gt;
result.cost_time = toc;
 