% HSV�ռ��ǱȽϳ��õ�ͳ����ɫ�����Ŀռ䣬����H������ɫ����S������ɫ��V���Կ������Ͷȣ�ͳ���в����˹̶�h��s��ͳ��v����
% ���磬����hΪ16�ݣ�sΪ4�ݣ�vΪ4�ݣ���ô�������ջ�õ�һ��256ά�����������������ά��������Ӧ�ĵ���������Ҳ���Էֿ��ͼ�����ͳ�ơ���ʾ�����ϸ�ڡ�
function colorhist = colorhist(rgb)  
if size(rgb,3)~=3   
    error('3 components is needed for histogram');   
end   
% globals   
H_BITS = 4; S_BITS = 2; V_BITS = 2;   
%rgb2hsv����rgb2hsi���档  
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
%             bitshift�Ƕ����ݵ�λ��������ʵ���ǳ˳��������磺bitshift��12��-2��������12����2��2�η������Ϊ3���ڶ��������Ǹ������ǳ������������ǳˡ�
        end           
    end   
end   
colorhist = reshape(colorhist, 1, 2^(H_BITS+S_BITS+V_BITS));   
% normalize   
colorhist = colorhist/sum(colorhist); 