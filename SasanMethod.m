% sasanMethod
function biImg = SasanMethod(img,filter,biBlurPre,ndots)
imgSize = size(img);
fltSize = size(filter);
fy = fltSize(1);
fx = fltSize(2);
biBlur = padarray(biBlurPre,fltSize);

blur = img;

midBlur = biBlurPre;
biImg = zeros(imgSize);

for i=1:ndots    
    errorImg = blur - midBlur;
    [~,maxIdx]=max(max(errorImg));
    [~,maxIdy]=max(errorImg(:,maxIdx));
    
    ypos = maxIdy + fy;
    xpos = maxIdx + fx;
    biBlur=applyfilterInside(ypos,xpos,biBlur,filter);
 
    biImg(maxIdy,maxIdx) = 1;
    
    midBlur = biBlur(fy+1:imgSize(1)+fy,fx+1:imgSize(2)+fx) + biImg;
end


end

function om = applyfilterInside(py,px,img,filter)
[fy,fx] = size(filter);
fy = (fy-1)/2;
fx = (fx-1)/2;
om = img;
om(py-fy:py+fy,px-fx:px+fx) = om(py-fy:py+fy,px-fx:px+fx) + filter;
end