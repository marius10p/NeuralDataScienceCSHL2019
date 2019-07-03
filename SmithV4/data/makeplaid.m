%

%We'll have array data from V4 on short (100 ms) static gratings (2 of them
%at the same time), spaced 22.5 deg apart, but with a full cross, so
%sometimes there will be only one visible and sometimes, there will be an
%actual blank. And sometimes there will be long ISIs.

%images should be scaled 0-255

% pepe values:
%             <inx>120</inx>
%             <iny>-120</iny>
%             <spatial>0.05</spatial> % cycles/pixel
%             <temporal>8</temporal>
%             <radius>120</radius>

addpath /Users/masmith/Dropbox/matlab/functions/

nmov = 2000;
nfram = 10;
plotflag = 0;
saveflag = 0;

orilist = [0:22.5:167.5 NaN];

maxrgb=255;
midgray=128;
diam = 180; % pixels for WileE
            %diam = 240; % pixels for Pepe
sscale = 0.0597; % deg/pixel
fr = 1; % cycles/deg
seed = 1975;

% grating2d(xn,yn,sscale,fr,theta,phase)
% pix2deg(pix,scrd,pixpercm)
% pix2deg(1,36,26.67)

% mask for the circular aperture
[rr cc] = meshgrid(1:diam);
C = sqrt((rr-diam/2).^2+(cc-diam/2).^2)<=diam/2;

r = RandStream.create('mrg32k3a','seed',seed);

movdata = cell(nmov,nfram);

for I=1:nmov
    mov = cell(nfram,1);
    fn = ['plaid_diam',num2str(diam),'_',num2str(I),'.mat'];
    for J=1:nfram
        
        twovals = randi(r,length(orilist),2,1);
        %movdata{I,J} = orilist(twovals);
        movori{I}(J,:) = orilist(twovals);
        movidx{I}(J,:) = twovals;
        if (plotflag + saveflag) >= 1
            g1=grating2d(diam,diam,sscale,fr,orilist(twovals(1)),0);
            g2=grating2d(diam,diam,sscale,fr,orilist(twovals(2)),0);
            gs = floor((((g1+g2)+2)./4).*maxrgb);
            gs(C==0)=midgray;
        end
        if plotflag
            imagesc(gs); colormap('gray'); axis off;
            set(gca,'clim',[0 255]);
            title([num2str(orilist(twovals)),' - range: ',num2str([min(min(gs)) max(max(gs))])]);
            pause;
        end
        if saveflag
            mov{J} = gs;
        end
    end
    if saveflag
        save(fn,'mov');
    end
end

clear mov g1 g2 gs rr cc C;
save('stiminfo.mat','movori','movidx','seed','orilist');
