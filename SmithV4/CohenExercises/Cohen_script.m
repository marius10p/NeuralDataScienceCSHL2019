
file2load = 'Wi170428.mat'; % comment out one 
file2load = 'Pe170417.mat'; % of these lines

load(file2load);

timevec = -1000:2000;
lfp = nan(numel(ex.LFPCHANNELS),numel(timevec),numel(ex.TRIAL_SEQUENCE));
rptIdx = ones(numel(ex.REPEATS),1);

for I=1:numel(ex.TRIAL_SEQUENCE)
    lfptmp  = cell2mat(ex.LFP(:,ex.TRIAL_SEQUENCE(I),rptIdx(ex.TRIAL_SEQUENCE(I))));
    timeIdx = cell2mat(ex.NSTIME(ex.TRIAL_SEQUENCE(I), rptIdx(ex.TRIAL_SEQUENCE(I))));
    tidx    = dsearchn(timeIdx',[-1 2]');
    lfp(:,:,I) = lfptmp(:,tidx(1):tidx(2));
end

trial_seq = ex.TRIAL_SEQUENCE;
lfp = single(lfp);
elec_map = ex.MAP;
save([ file2load(1:2) '_LFP.mat' ],'lfp','timevec','trial_seq','elec_map');