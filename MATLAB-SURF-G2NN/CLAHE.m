
       [X MAP] = imread('shadow.tif');
       RGB = ind2rgb(X,MAP); % convert indexed image to truecolor format
       cform2lab = makecform('srgb2lab');
       LAB = applycform(RGB, cform2lab); %convert image to L*a*b color space
       L = LAB(:,:,1)/100; % scale the values to range from 0 to 1
       LAB(:,:,1) = adapthisteq(L,'NumTiles',[16 16],'ClipLimit',0.5)*100;
       cform2srgb = makecform('lab2srgb');
       J = applycform(LAB, cform2srgb); %convert back to RGB
       figure, imshow(RGB); %display the results
       figure, imshow(J);