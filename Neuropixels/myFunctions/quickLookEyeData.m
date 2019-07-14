% quick look at eye data

eyeTimes = S.eye.timestamps(:,2);
eyeArea = S.eye.area;

plot(eyeTimes,eyeArea)

%% load deeplabcuts
mainPath = 'C:\Users\micha\Documents\Data';
fname = 'DeepCut_resnet50_513953554_233216_20160414_video-1Jun28shuffle1_300000-results.csv';

Y = readmatrix([mainPath filesep fname]);

