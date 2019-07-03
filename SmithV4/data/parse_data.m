%% parse data - relies on lots of local functions

addpath /Users/masmith/Dropbox/smithlab/matlab/utils/
addpath /Users/masmith/Dropbox/smithlab/matlab/spikesort/

fn = 'Pe170417_s317a_plaidmovie_00010002.nev';
epochRange = [0 1];
%fn = 'Wi170428_s285a_plaidmovie_0003.nev';
%epochRange = [1 1]; % because Wi only had 0.5 s before stim, but Pe had 1.0 s
[pathstr,fnt]=fileparts(fn);
fn2 = [pathstr,fnt,'.ns2'];
fn5 = [pathstr,fnt,'.ns5'];
cmp = [pathstr,fnt,'.cmp'];
fnout = [fn(1:8),'.mat'];

load('stiminfo.mat');

ex = nev2ex3(fn,'alignCode',10,'keepTrialCode',5,'readLFP',true,'readEyes',true,'convertEyes',true,'nsEpoch',epochRange);

ex.FILENAME = fn;
ex.MOVIDX = movidx;
ex.MOVORI = movori;
ex.ORILIST = orilist;
ex.SEED = seed;
ex.MAP = readcmp(cmp);

snt = justSNR(fn);
minspikes = 10;
t = find(snt(:,2) > 0 & snt(:,2) < 255);
ex.SNR = snt(t,3);
ex.SC = snt(t,4);
t = find(ex.SNR == 0);
t2 = find(ex.SC < minspikes);
t = union(t,t2);
ex.SNR(t) = [];
ex.SC(t) = [];
ex.CHANNELS(t,:) = [];
ex.EVENTS(t,:,:) = [];

save(fnout,'ex','-v7.3');


