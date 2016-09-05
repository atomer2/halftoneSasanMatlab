% main program of parallel sasanMethod
tic

testCode = 'with_ht_diffusion_block';
mkdir(testCode);
root = cd('.');
% add path so we can invoke SasanMethod
addpath(root);
t = cd('image');
allnames= struct2cell(dir);
[m,n] = size(allnames);
% process every file
for f = 3:n
    filename = allnames{1,f};
    OriImage=imread(filename);
    
    % blockSize
    blockSize=32;
    %filter Size 11 x 11
    sigma = 1.3;
    filterSize=[11,11];
    gausFilter = fspecial('gaussian',filterSize,sigma);
    grayImg = im2double(rgb2gray(OriImage));
    
    imgSize = size(grayImg);
    oldImgSize =imgSize;
    yb=ceil(imgSize(1)/blockSize);
    xb=ceil(imgSize(2)/blockSize);
    ypad=yb*blockSize-imgSize(1);
    xpad=xb*blockSize-imgSize(2);
    grayImg=padarray(grayImg,[ypad,xpad],'replicate','post');
    imgSize=size(grayImg);
    
    outputImg = zeros(imgSize);
    noutputImg = zeros(imgSize);
    blurImageZeroIsBlack = imfilter(grayImg,gausFilter);
    
    
    ngrayImg=ones(imgSize(1),imgSize(2))-grayImg;
    blurImageZeroIsWrite = imfilter(ngrayImg,gausFilter);
    
    phaseInterval= 2 * blockSize;
    for phase=1:4
        %phase ONE:
        if phase == 1
            feedForwardZeroIsBlack = grayImg;
            feedForwardZeroIsWhite = ngrayImg;
            for i = 1:phaseInterval:imgSize(1)
                for j = 1:phaseInterval:imgSize(2)
                    feedForwardZeroIsBlack(i:i+blockSize-1,j:j+blockSize-1)=zeros(blockSize);
                    feedForwardZeroIsWhite(i:i+blockSize-1,j:j+blockSize-1)=zeros(blockSize);
                end
            end
            init_y=1;
            init_x=1;
            % phase TWO:
        elseif phase == 2
            feedForwardZeroIsBlack = outputImg;
            feedForwardZeroIsWhite = noutputImg;
            for i = blockSize+1:phaseInterval:imgSize(1)
                feedForwardZeroIsBlack(i:i+blockSize-1,:)=grayImg(i:i+blockSize-1,:);
                feedForwardZeroIsWhite(i:i+blockSize-1,:)=ngrayImg(i:i+blockSize-1,:);
            end
            init_y=1;
            init_x=blockSize+1;
            % phase THREE:
        elseif phase ==3
            feedForwardZeroIsBlack = outputImg;
            feedForwardZeroIsWhite = noutputImg;
            for i = blockSize+1:phaseInterval:imgSize(1)
                for j = blockSize+1:phaseInterval:imgSize(2)
                    feedForwardZeroIsBlack(i:i+blockSize-1,j:j+blockSize-1)=grayImg(i:i+blockSize-1,j:j+blockSize-1);
                    feedForwardZeroIsWhite(i:i+blockSize-1,j:j+blockSize-1)=ngrayImg(i:i+blockSize-1,j:j+blockSize-1);
                end
            end
            init_y=blockSize+1;
            init_x=1;
            % phase FOUR:
            
        else
            feedForwardZeroIsBlack = outputImg;
            feedForwardZeroIsWhite = noutputImg;
            init_y=blockSize+1;
            init_x=blockSize+1;
            
        end
        
        zeroIsBlack=1;
        
        feedForwardZeroIsBlack =imfilter(feedForwardZeroIsBlack,gausFilter);
        feedForwardZeroIsWhite =imfilter(feedForwardZeroIsWhite,gausFilter);
        
        for i = init_y:phaseInterval:imgSize(1)
            for j = init_x:phaseInterval:imgSize(2)
                ndots=sum((sum(grayImg(i:i+blockSize-1,j:j+blockSize-1)))');
                if ndots>blockSize*blockSize/2
                    zeroIsBlack=0;
                    dots=blockSize*blockSize-ndots;
                else
                    zeroIsBlack=1;
                    dots=ndots;
                end
                if zeroIsBlack==1
                    pre=feedForwardZeroIsBlack(i:i+blockSize-1,j:j+blockSize-1);
                    tmp=SasanMethod(blurImageZeroIsBlack(i:i+blockSize-1,j:j+blockSize-1),gausFilter,pre,dots);
                    outputImg(i:i+blockSize-1,j:j+blockSize-1)=tmp;
                    noutputImg(i:i+blockSize-1,j:j+blockSize-1)=ones(blockSize)-tmp;
                else
                    pre=feedForwardZeroIsWhite(i:i+blockSize-1,j:j+blockSize-1);
                    tmp=SasanMethod(blurImageZeroIsWrite(i:i+blockSize-1,j:j+blockSize-1),gausFilter,pre,dots);
                    outputImg(i:i+blockSize-1,j:j+blockSize-1)=ones(blockSize)-tmp;
                    noutputImg(i:i+blockSize-1,j:j+blockSize-1)=tmp;
                end
            end
        end
        
    end
    
    oim = outputImg(1:oldImgSize(1),1:oldImgSize(2));
    imshow(oim);
    outputName = [root,'/',testCode,'/',filename,'.bmp'];
    imwrite(oim,outputName);
    
end

cd(root);

toc
