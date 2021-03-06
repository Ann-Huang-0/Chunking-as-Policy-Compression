function chunk_related_analysis()
% For experiment 1: statistics for determining if chunking is related to
% policy complexity

load('actionChunk_data.mat');
nSubj = length(data);

%% Determine if reduction in intrachunk RT is higher for Ns=6

condition = {'Ns4,baseline', 'Ns4,train','Ns6,baseline', 'Ns6,train'};
chunkRT = zeros(nSubj, length(condition));
chunkRT_all = cell(nSubj, length(condition));
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
        chunkRT_all{s,c} = rt(intersect(find(state == action), pos));
    end
end
% Intrachunk RT: paired student's t-test at population level
diffRT(:,1) = chunkRT(:,2)-chunkRT(:,1); diffRT(:,2) = chunkRT(:,4)-chunkRT(:,3);
[h, p] = ttest2(diffRT(:,1), diffRT(:,2), 'Tail', 'right'); 

% Intrachunk RT: Wilcoxon rank sum test at individual level
pval = nan(nSubj,2);
for s = 1:nSubj
    pval(s,1) = ranksum(chunkRT_all{s,2}, chunkRT_all{s,1}, 'tail', 'left');
    pval(s,2) = ranksum(chunkRT_all{s,4}, chunkRT_all{s,3}, 'tail', 'left');
end

% select for people who actually showed reduction in RT from Baseline to Train
idx = diffRT(:,1)<0 & diffRT(:,2)<0;
[h, p] = ttest2(diffRT(idx,1), diffRT(idx,2), 'Tail', 'right')


%% Determine if reduction in average RT is higher for Ns=6

avgRT = nan(nSubj, length(condition));
condition = {'Ns4,baseline', 'Ns4,train', 'Ns6,baseline', 'Ns6,train'};
for s = 1:nSubj
    for c = 1:length(condition)
        rtData = data(s).rt;
        avgRT(s,c) = nanmean(rtData(strcmp(data(s).cond, condition(c))));
    end
end

idx = avgRT(:,2)<avgRT(:,1) & avgRT(:,4)<avgRT(:,3);
[h, p] = ttest2(avgRT(idx,3)-avgRT(idx,4), avgRT(idx,1)-avgRT(idx,2), 'Tail', 'right')

%% Determine if prechunk RT is longer than its preceeding and succeeding RTs

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
        [precessor(c,subj,1), precessor(c,subj,2)] = ttest2(preRT, pre_preRT, 'Alpha', 0.1, 'Tail', 'right');
        [successor(c,subj,1), successor(c,subj,2)] = ttest2(preRT, intraRT, 'Alpha', 0.1, 'Tail', 'right');
    end
end

%% Determine if chunking reduces policy complexity

conds = {'Ns4,perfrom', 'Ns4,test', 'Ns6,perform', 'Ns6,test'};
%conds = {'Ns4,baseline', 'Ns4,train', 'Ns6,baseline', 'Ns6,train'};
complexity = nan(nSubj, length(conds));
for s = 1:nSubj
    for c = 1:length(conds)
        idx = strcmp(data(s).cond, conds(c));
        state = data(s).s(idx);
        action = data(s).a(idx); 
        complexity(s,c) = information(state', action');
    end
end

%[h4, p4] = ttest2(complexity(:,1), complexity(:,2), 'Tail', 'left')
%[h6, p6] = ttest2(complexity(:,3), complexity(:,4), 'Tail', 'left')

[p4,h4] = signrank(complexity(:,1), complexity(:,2), 'Tail', 'left');
[p6,h6] = signrank(complexity(:,3), complexity(:,4), 'Tail', 'left');



%% Determine if resource-constrained agents chunk more

load('fixed_adaptive_chunk');
C = results(2).x(1);
model = fitlm(C, reduction);
model.Coefficients


%% How response time changes though time for both intrachunk state & exochunk states

nPresent = sum(data(1).s(strcmp(data(1).cond, 'Ns4,train'))==1);
stateConds = {'Ns4,baseline', 'Ns4,train'};
intraChunkState = [4 4];                % chunk: [2 1] for Ns=4, [5 4] for Ns=6
exoChunkState = {[1 2 3 5 6], [1 2 3 5 6]};
intraRT = nan(2, nSubj, nPresent);      % Dim1:block condition;  Dim2:subjects  Dim3:time
exoRT = nan(2, nSubj, nPresent);
for s = 1:nSubj
    for condIdx = 1:length(stateConds)
        state = data(s).s(strcmp(data(s).cond, stateConds{condIdx}));
        rt = data(s).rt(strcmp(data(s).cond, stateConds{condIdx}));
        intraRT(condIdx,s,:) = rt(state==intraChunkState(condIdx));
        exoChunk = exoChunkState{condIdx};
        exoRT_perState = nan(length(exoChunk), nPresent);
        for i = 1:length(exoChunk)
            %exoRT_perState(i,:) = rt(state==exoChunk(i));
        end
        exoRT(condIdx,s,:) = squeeze(mean(exoRT_perState,1));
    end
end
        
% intrachunk RT VS exochunk RT within train block
intraRT_timeDynamics = squeeze(nanmean(intraRT, 2));
exoRT_timeDynamics = squeeze(nanmean(exoRT, 2));
                    
figure; hold on;
plot(intraRT_timeDynamics(1,:), 'LineWidth', 3);
plot(intraRT_timeDynamics(2,:), 'LineWidth', 3); 
legend('Ns6,baseline', 'Ns6,train');


