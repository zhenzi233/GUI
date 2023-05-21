% MATCH_FEATURES: Match SIFT features in a single image using our multiple
%                 match strategy.
% 
% INPUTS:
%   filename        - image filename (if features have to be computed) or
%                     descriptors filename in the other case
%   filesift        - [opt] file containing sift descriptors
%
% OUTPUTS:
%   num             - number of matches
%   p1,p2           - coordinates of pair of matches
%   tp              - computational time    
%
% EXAMPLES:
%   e.g. extract features and matches from a '.jpg' image:
%   [num p1 p2 tp] = match_features('examples/tampered1.jpg')
%
%   e.g. import features and matches from a '.sift' descriptors file:
%   [num p1 p2 tp] = match_features('examples/tampered2.sift',0)                      
%  换成：match_features('examples/tampered2.jpg','examples/tampered2.sift')
%       
% ---

function [num p1 p2 tp] = match_features1(locs, descs)
num=size(descs,1);
% thresholds used for g2NN test
dr2 = 0.5; %默认0.5

tic; % to calculate proc time

    % import sift descriptors
%     [num, locs, descs] = import_sift(filesift);   % n*4（y,x,,,）  n*128  lowe 法提取 
    %但为什么用的是filesift,用C编的里面含有lowe的！
% %     loc=locs(:,1:2);
% %     FLM = devide_flat(filename ,loc); %%大致划分出平滑区域。。。。

if (num==0)
    p1=[];
    p2=[];
    tp=[];
else
    p1=[];
    p2=[];
    num=0;
    
    % load data
    loc1 = locs(:,1:2);
    %scale1 = locs(:,3);
    %ori1 = locs(:,4);
    des1 = descs;
    
%     % descriptor are normalized with norm-2
    if (size(des1,1)<10000)  
%         des1 = des1./repmat(sqrt(diag(des1*des1')),1,size(des1,2)); %对每行进行归一化
        des1 = des1./repmat(sqrt(sum(des1.^2,2)),1,size(des1,2)); %另一选择
    else
        des1_norm = des1; 
         for i=1:size(des1,1)  
             des1_i = des1_norm(i,:);
             des1_norm(i,:) = des1_i/norm(des1_i);
         end 
        des1 = des1_norm;
    end
    
    % sift matching
    des2t = des1';   % precompute matrix transpose
    if size(des1,1) > 1 % start the matching procedure iff there are at least 2 points
        for i = 1 : size(des1,1)
            dotprods = des1(i,:) * des2t;        % Computes vector of dot products
            [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results
 
            j=2;
            while vals(j)<dr2* vals(j+1) 
                j=j+1;
            end
            for k = 2 : j-1
                match(i) = indx(k); 
                if pdist([loc1(i,1) loc1(i,2); loc1(match(i),1) loc1(match(i),2)]) >100  
                    p1 = [p1 [loc1(i,2); loc1(i,1); 1]];
                    p2 = [p2 [loc1(match(i),2); loc1(match(i),1); 1]];
                    num=num+1;
                end
            end
        end
    end
    
    tp = toc; % processing time (features + matching)
    
    if size(p1,1)==0
        fprintf('Found %d matches.\n', num);
    else
          p1=p1(1:2,:)'; p2=p2(1:2,:)';
          loca=p1+p2;
          [l,m,n]=unique(loca,'rows');%去除相同元素的行，，，，[x1 y1 x1' y1';...]
          p1=p1(m,:); p2=p2(m,:);
          p1=[p1';ones(1,size(p1,1))]; p2=[p2';ones(1,size(p2,1))];
          
        num=size(p1,2);
        fprintf('Found %d matches.\n', num);  
    end
   
end
