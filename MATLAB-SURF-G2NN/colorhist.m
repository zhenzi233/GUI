% HSV空间是比较常用的统计颜色特征的空间，其中H代表了色调，S代表颜色，V可以看做饱和度，统计中采用了固定h和s，统计v特征
% 比如，划分h为16份，s为4份，v为4份，那么我们最终会得到一个256维的特征向量。具体的维数可以相应的调整，我们也可以分块对图像进行统计。显示更多的细节。
function colorhist = colorhist(rgb)  
if size(rgb,3)~=3   
    error('3 components is needed for histogram');   
end   
% globals   
H_BITS = 4; S_BITS = 2; V_BITS = 2;   
%rgb2hsv可用rgb2hsi代替。  
hsv = uint8(255*rgb2hsv(rgb));   
  
imgsize = size(hsv);   
% get rid of irrelevant boundaries   
i0=round(0.05*imgsize(1));  i1=round(0.95*imgsize(1));   
j0=round(0.05*imgsize(2));  j1=round(0.95*imgsize(2));   
hsv = hsv(i0:i1, j0:j1, :);   
   
% histogram   
for i = 1 : 2^H_BITS   
    for j = 1 : 2^S_BITS   
        for k = 1 : 2^V_BITS   
            colorhist(i,j,k) = sum(sum(bitshift(hsv(:,:,1),-(8-H_BITS))==i-1 & bitshift(hsv(:,:,2),-(8-S_BITS))==j-1 & bitshift(hsv(:,:,3),-(8-V_BITS))==k-1 )); 
%             bitshift是对数据的位操作，其实就是乘除法，例如：bitshift（12，-2），就是12除以2的2次方，结果为3，第二个参数是负数就是除，是整数就是乘。
        end           
    end   
end   
colorhist = reshape(colorhist, 1, 2^(H_BITS+S_BITS+V_BITS));   
% normalize   
colorhist = colorhist/sum(colorhist); 