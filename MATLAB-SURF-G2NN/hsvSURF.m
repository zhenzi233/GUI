function result = hsvSURF(file_name, file_path)
%%%%%%%%%%%%���㷨��RGB��ɫ�ռ�ת����HSI��ɫ�ռ䣬Ȼ����SURF�㷨����������ȡ�����þ����G2NN�㷨����ƥ�䣬�ɼ����ظ���ճ���۸�����
%clc;
% clear all;
tic
pathname = file_path;
str=pathname;
x=imread(str);
 I1=rgb2hsv(x); 
%  figure
%  imshow(I1)
%  I1=histeq(I1);
%  I1=rgb2gray(I1);
% figure 
% imshow(I1)
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


% % % % % % % % % % % % % % 
 locs=[temp2',temp1'];
metric='single';  
%  thc=0.02;   thc=thc*max(size(I1));
  thc=30; 
min_cluster_pts=3;  
plotimg=1;   display=0;   num_gt=0;
% [num1, locs, descs] = import_sift(siftfile);  %n*4  n*128  ����������ȡ������sift��
% ԭ������C��ȡ��sift�� Ҳ��lowe����
[num p1 p2 tp] = match_features1(locs,descs);
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
        imshow(x);
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
 
  figure;  %����һ�ξ����ransac�����������ٴξ���ͼ��д�ڴ˴���Ϊ�˿���X1Ϊ�յ��������ʾԭͼ��
  imshow(x); hold on;
if size(X1,1)>0 %       
    % Hierarchical Agglomerative Clustering
    Y=pdist(X1);
    Z1 = linkage(Y,metric);
     T1 = cluster(Z1,'cutoff',thc,'Criterion','distance');   
   N1=size(pos1,1);
    for i=1:size(pos1,1)
        plot([pos1(i,1)  pos2(i,1)],[pos1(i,2)  pos2(i,2)],'-','color','c');
    end  
     gscatter(X1(:,1),X1(:,2),T1,'','','','off')   
     fprintf('�����ҵ�%d��ƥ���\n',N1);
 
%�������ϵĶ��ξ������ٴ�������ƥ��
   X2=[];
  T_max=max(T1);
  if(T_max>1)
      n_combination_cluster1 = combntns(1:T_max,2);
      pos3=[];pos4=[];
       for i=1:1:size(n_combination_cluster1,1)
            k1=n_combination_cluster1(i,1);
            j1=n_combination_cluster1(i,2);
            z3=[];
            z4=[];
            inliers3=[];inliers4=[];
            for r=1:1:size(pos1,1)
                if T1(r)==k1 && T1(r+size(pos1,1))==j1  %  pos1:nx2
                    z3 = [z3; [X1(r,:) 1]];
                    z4 = [z4; [X1(r+size(pos1,1),:) 1]];
                end
                if T1(r)==j1 && T1(r+size(pos1,1))==k1
                    z3 = [z3; [X1(r+size(pos1,1),:) 1]];
                    z4 = [z4; [X1(r,:) 1]];
                end
            end
           if (size(z3,1) > min_cluster_pts && size(z4,1) > min_cluster_pts)                             
             pos3=[pos3;z3];  pos4=[pos4;z4] ; %jia
           end  %jia
       end
       X2=[pos3;pos4];%[x1 y1;...x1' y1';....]  %
  end
  
     figure; %����ʾԭͼ����X2��ֵ�����ͼΪ����ƥ��ԣ�����ֵ�����ͼΪԭʼͼ�񣬱���ƥ��ȫ���� 
     imshow(I1);  xlabel('�����㷨'); hold on;
    if X2>0
       % Hierarchical Agglomerative Clustering
       Y2=pdist(X2);
       Z2 = linkage(Y2,metric);
       T2 = cluster(Z2,'cutoff',thc,'Criterion','distance');
     N2=size(pos3,1);
     fprintf('�����ҵ�%d��ƥ���\n',N2);
        for i=1:N2
           plot([pos3(i,1)  pos4(i,1)],[pos3(i,2)  pos4(i,2)],'-','color','c');
        end 
         gscatter(X2(:,1),X2(:,2),T2,'','','','off') ;
    else  num_gt=0;
    end

else  num_gt=0; %�ݼ�
end  %�ݼ�
end

if(plotimg==1)
% tampering detection
if(num_gt)
    fprintf('Tampering detected!\n\n');
else
    fprintf('Image not tampered.\n\n');
end
end
fprintf(2,'�����ʱ%f��\n',toc);
result.pixel1 = p1;
result.pixel2 = p2;
if(p1)
    result.new_pixel1 = z3;
    result.new_pixel2 = z4;
end
if(p1)
    result.point_get = N1;
else
    result.point_get = 0;
end
result.is_tampered = num_gt;
result.cost_time = toc;