%% 7 Basic curve fitting

%The point of curve fitting is to go beyond the data. So far, we we took
%the data at face value. With curve fitting, we are engaging in a platonic
%enterprise. We simply use the data to get estimates of parameters of some
%ideal forms. Equations. We image the forms by the shadows they cast
%in the form of data. Neural Data Science like what Plato would have done
%if he had data, a computer and Matlab. 
%To be serious, what this allows us to do - for instance is to extract
%parameters and then maybe compare them between conditions or areas or
%whatever.

%Fitting is mostly the same:
%First call a fit function to estimate parameters
%Then call a val function to evaluate the curve with (new) data

figure
h1 = plot(xBase,spMean(1:numOri),'color','k');
hold on

%% Polynomial fit
p = polyfit(xBase,spMean(1:numOri),3)
yHat = polyval(p,xBase); 
%f = fit(x,y,fittype)
h2 = plot(xBase,yHat,'color','b');
legend([h1 h2],{'Empirical','Model'})
shg

%% Cosine fit
xBasePrime = deg2rad(xBase'); %Expects column vectors, and convert to radians
yOutcomes = spMean(1:numOri)'; %Expects column vectors'p(1) + p(2) * cos (theta - p(3))'
fT = fittype('a * cos (x-b) + c')
%fT = fittype('a + b * cos (x - c))')


f = fit(xBasePrime,yOutcomes,fT,'StartPoint', rand(1,3)) %Fit object
yHat = f.a.*cos(xBasePrime-f.b) + f.c; %Evaluate function
figure
h3 = plot(xBase,yOutcomes); %Data
hold on
h4 = plot(xBase,yHat); %Fit
legend([h3 h4],{'Data','Fit'})
shg

