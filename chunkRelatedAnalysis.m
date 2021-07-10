function chunkRelatedAnalysis()
%% Determine if higher cognitive load induces more chunk use
%%

load('actionChunk_data.mat');
nSubj = length(data);
condition = {'Ns4,baseline', 'Ns4,train','Ns6,baseline', 'Ns6,train'};
chunkRT = zeros(nSubj, length(condition));
chunkInit = [2,5];
for s = 1:nSubj
    for c = 1:length(condition)
        idx = strcmp(data(s).cond, condition(c));
        state = data(s).s(idx);
        action = data(s).a(idx);
        rt = data(s).rt(idx);
        if contains(condition(c),'4')
            condIdx = 1;
        elseif contains(condition(c), '6')
            condIdx = 2;
        end
        pos = find(state==chunkInit(condIdx))+1; pos(pos>length(state))=[];
        chunkRT(s,c) = nanmean(rt(intersect(find(state == action), pos)));
    end
end

diffRT(:,1) = chunkRT(:,2)-chunkRT(:,1); diffRT(:,2) = chunkRT(:,4)-chunkRT(:,3);
[h, p] = ttest(diffRT(:,1), diffRT(:,2), 'Tail', 'left') % student's t-test

%% Determine if prechunk RT is longer than its preceeding and succeeding RTs
%%
% identify prechunk RTs
precessor = nan(2, nSubj, 2);
successor = nan(2, nSubj, 2);
chunkInitS = [2,5];
condName = {'Ns4,perform', 'Ns6,perform'};
for subj = 1:nSubj
    for c = 1:length(condName)
        chunkIdx = find(strcmp(data(subj).cond, condName{c}) & ...
                   data(subj).s==chunkInitS(c));
        pre_preRTidx = chunkIdx - 1; intraRTidx = chunkIdx + 1;
        if pre_preRTidx(1) < 1
            pre_preRTidx(1)=[]; intraRTidx(1)=[]; chunkIdx(1)=[];
        end
        preRT = data(subj).rt(chunkIdx);
        pre_preRT = data(subj).rt(pre_preRTidx);
        intraRT = data(subj).rt(intraRTidx);
        [precessor(c,subj,1), precessor(c,subj,2)] = ttest2(preRT, pre_preRT, 'Tail', 'right');
        [successor(c,subj,1), successor(c,subj,2)] = ttest2(preRT, intraRT, 'Tail', 'right');
    end
end
        
            
        
    