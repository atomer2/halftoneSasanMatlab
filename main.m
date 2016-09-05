% main program of parallel sasanMethod
tic
OriImage=imread('lena.jpg');
% blockSize
blockSize=32;

%filter Size 11 x 11
sigma = 1.3;
filterSize=[11,11];
gausFilter = fspecial('gaussian',filterSize,sigma);
grayImg = im2double(rgb2gray(OriImage));

imgSize = size(grayImg);
oldImgSize =imgSize;
yb=floor(imgSize(1)/blockSize);
xb=floor(imgSize(2)/blockSize);
ypad=yb*blockSize-imgSize(1);
xpad=xb*blockSize-imgSize(2);
grayImg=padarray(grayImg,[ypad,xpad],'replicate','post');
imgSize=size(grayImg);

outputImg = zeros(imgSize);
noutputImg = zeros(imgSize);
blurImageZeroIsBlack = imfilter(grayImg,gausFilter);


ngrayImg=ones(imgSize(1),imgSize(2))-grayImg;
blurImageZeroIsWrite = imfilter(ngrayImg,gausFilter);



for phase=1:4
    %phase ONE:
    if phase == 1
        feedForwardZeroIsBlack = grayImg;
        feedForwardZeroIsWhite = ngrayImg;
        
        for i = 1:64:imgSize(1)
            for j = 1:64:imgSize(2)
                feedForwardZeroIsBlack(i:i+31,j:j+31)=zeros(32);
                feedForwardZeroIsWhite(i:i+31,j:j+31)=zeros(32);
            end
        end
        init_y=1;
        init_x=1;
        % phase TWO:
    elseif phase == 2
        feedForwardZeroIsBlack = outputImg;
        feedForwardZeroIsWhite = noutputImg;
        for i = 33:64:imgSize(1)
            feedForwardZeroIsBlack(i:i+31,:)=grayImg(i:i+31,:);
            feedForwardZeroIsWhite(i:i+31,:)=ngrayImg(i:i+31,:);
        end
        init_y=1;
        init_x=33;
        % phase THREE:
    elseif phase ==3
        feedForwardZeroIsBlack = outputImg;
        feedForwardZeroIsWhite = noutputImg;
        for i = 33:64:imgSize(1)
            for j = 33:64:imgSize(2)
                feedForwardZeroIsBlack(i:i+31,j:j+31)=grayImg(i:i+31,j:j+31);
                feedForwardZeroIsWhite(i:i+31,j:j+31)=ngrayImg(i:i+31,j:j+31);
            end
        end
        init_y=33;
        init_x=1;
        % phase FOUR:
        
    else
        feedForwardZeroIsBlack = outputImg;
        feedForwardZeroIsWhite = noutputImg;
        init_y=33;
        init_x=33;
        
    end
    
    zeroIsBlack=1;
    
    feedForwardZeroIsBlack =imfilter(feedForwardZeroIsBlack,gausFilter);
    feedForwardZeroIsWhite =imfilter(feedForwardZeroIsWhite,gausFilter);
    
    for i = init_y:64:imgSize(1)
        for j = init_x:64:imgSize(2)
            ndots=sum((sum(grayImg(i:i+31,j:j+31)))');
            if ndots>blockSize*blockSize/2
                zeroIsBlack=0;
                dots=blockSize*blockSize-ndots;
            else
                zeroIsBlack=1;
                dots=ndots;
            end
            if zeroIsBlack==1
                pre=feedForwardZeroIsBlack(i:i+31,j:j+31);
                tmp=SasanMethod(blurImageZeroIsBlack(i:i+31,j:j+31),gausFilter,pre,dots);
                outputImg(i:i+31,j:j+31)=tmp;
                noutputImg(i:i+31,j:j+31)=ones(blockSize)-tmp;
            else
                pre=feedForwardZeroIsWhite(i:i+31,j:j+31);
                tmp=SasanMethod(blurImageZeroIsWrite(i:i+31,j:j+31),gausFilter,pre,dots);
                outputImg(i:i+31,j:j+31)=ones(blockSize)-tmp;
                noutputImg(i:i+31,j:j+31)=tmp;
            end
        end
    end
    
end

oim = outputImg(1:oldImgSize(1),1:oldImgSize(2));
imshow(oim);
imwrite(oim,'bordenWithoutProcess.bmp');

toc
