function exploratoryAnalysis()

load('actionChunk_data.mat');
nSubj = length(data);
%condition = unique(data(1).cond);
%condition(strcmp(condition, '')) = [];
condition = {'Ns4,baseline', 'Ns4,train', 'Ns4,perform', 'Ns4,test',...
    'Ns6,baseline', 'Ns6,train', 'Ns6,perform', 'Ns6,test'};

%% Population-level accuracy
%%
acc = nan(nSubj, length(condition));
sem = nan(nSubj, length(condition));
for s = 1:nSubj
    for c = 1:length(condition)
        accData = data(s).acc;
        acc(s,c) = nanmean(accData(strcmp(data(s).cond, condition(c))));
    end
end

bmap = plmColors(length(condition)/2, 'pastel1');
hold on;
X = 1:2;
tmp = mean(acc,1); plotAcc(1,:) = tmp(1:length(condition)/2); plotAcc(2,:) = tmp(length(condition)/2+1:length(condition));
b = bar(X, plotAcc);
sem = nanstd(acc, 1)/sqrt(nSubj) ; sem = reshape(sem, [2 length(condition)/2]);
errorbar_pos = errorbarPosition(b, sem);
errorbar(errorbar_pos', plotAcc, min(sem,1-plotAcc), sem, 'k','linestyle','none', 'lineWidth', 1.2);
ylim([0 1]);
legend('Baseline', 'Train', 'Perform', 'Test', 'Location', 'northeast');
set(gca, 'XTick',1:2, 'XTickLabel', {'Ns=4', 'Ns=6'});
xlabel('Set size'); ylabel('Average accuracy');

%% Population-level reaction time
%%
rt = nan(nSubj, length(condition));
for s = 1:nSubj
    for c = 1:length(condition)
        rtData = data(s).rt;
        rt(s,c) = nanmean(rtData(strcmp(data(s).cond, condition(c))));
        sem(s,c) = nanstd(rtData(strcmp(data(s).cond, condition(c))));
    end
end

bmap = plmColors(4, 'pastel1');
hold on;
tmp = mean(rt,1); plotRT(1,:) = tmp(1:length(condition)/2); plotRT(2,:) = tmp(length(condition)/2+1:length(condition));
b = bar([1 2], plotRT);
sem = nanstd(rt, 1)/sqrt(nSubj); sem = reshape(sem, [2 length(condition)/2]);
errorbar_pos = errorbarPosition(b, sem);
errorbar(errorbar_pos', plotRT, sem, sem, 'k','linestyle','none', 'lineWidth', 1.2);
legend('Baseline', 'Train', 'Perform', 'Test', 'Location', 'northwest');
set(gca, 'XTick',1:2, 'XTickLabel', {'Ns=4', 'Ns=6'});
xlabel('Set size'); ylabel('Average Response Time');

%% Action slips
%%
actionSlip = zeros(nSubj, 2);
slipCond = {'Ns4,test', 'Ns6,test'};
slipPos = [2,5];
chunkResp = [1,4];
for s = 1:nSubj
    for c = 1:2
        state = data(s).s(strcmp(data(s).cond, slipCond(c)));
        action = data(s).a(strcmp(data(s).cond, slipCond(c)));
        pos = find(state==slipPos(c))+1;
        pos(pos>length(state))=[];
        actionSlip(s,c) = sum(state(pos)~=chunkResp(c) & action(pos)==chunkResp(c));
    end
end

X = [4,6];
b = bar(X, sum(actionSlip,1));
xtips = b.XEndPoints;
ytips = b.YEndPoints;
labels = string(b.YData);
text(xtips, ytips, labels, 'HorizontalAlignment','center',...
    'VerticalAlignment','bottom');

%% Intrachunk reaction time
%%

rtChunkCorr = zeros(nSubj, length(condition));
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
        rtChunkCorr(s,c) = nanmean(rt(intersect(find(state == action), pos)));
    end
end

bmap = plmColors(4, 'pastel1');
figure; hold on;
tmp = nanmean(rtChunkCorr,1); plotRTChunk(1,:) = tmp(1:length(condition)/2); plotRTChunk(2,:) = tmp(length(condition)/2+1:length(condition));
sem = nanstd(rtChunkCorr, 1) / sqrt(nSubj); sem = reshape(sem, [2 4]);
b = bar([1 2], plotRTChunk);
errorbar_pos = errorbarPosition(b, sem);
errorbar(errorbar_pos', plotRTChunk, sem, sem, 'k','linestyle','none', 'lineWidth', 1.2);
legend('Baseline', 'Train', 'Test', 'Location', 'northwest');
set(gca, 'XTick',1:2, 'XTickLabel', {'Ns=4', 'Ns=6'});
xlabel('Set size'); ylabel('Intrachunk Response Time');

%% Reward-complexity curve
%%

reward = nan(nSubj, length(condition));
complexity = nan(nSubj, length(condition));
for s = 1:nSubj
    for c = 1:length(condition)
        idx = strcmp(data(s).cond, condition(c));
        state = data(s).s(idx);
        action = data(s).a(idx);
        reward(s,c) = mean(state==action);
        complexity(s,c) = mutual_information(state', action');
    end
end

figure; hold on;
entry = 1;
scatter(complexity(:,entry), reward(:,entry), 120, 'filled', 'MarkerFaceColor', '#0072BD');
polycoef = polyfit(complexity(:,entry), reward(:,entry), 2);
X = linspace(min(complexity(:,entry))-0.1, max(complexity(:,entry))+0.1, 50);
Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
p1 = plot(X, Y, 'MarkerFaceColor', '#0072BD', 'LineWidth', 4);

entry = 5;
scatter(complexity(:,entry), reward(:,entry), 120, 'filled', 'MarkerFaceColor', '#D95319');
polycoef = polyfit(complexity(:,entry), reward(:,entry), 2);
X = linspace(min(complexity(:,entry))-0.1, max(complexity(:,entry))+0.1, 80);
Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
p2 = plot(X, Y, 'MarkerFaceColor', '#D95319', 'LineWidth', 4);

legend([p1 p2], {'Ns=4 Baseline','Ns=6 Baseline'}, 'Location', 'northwest');
%xlim([1 1.62]); ylim([0.6, 1.0]);
xlabel('Policy complexity'); ylabel('Average reward');

%{
        figure; hold on;
        scatter(complexity(:,4), reward(:,4), 120, 'filled', 'MarkerFaceColor', '#0072BD');
        polycoef = polyfit(complexity(:,4), reward(:,4), 2);
        X = linspace(min(complexity(:,4)), max(complexity(:,4)), 50);
        Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
        p1 = plot(X, Y, 'MarkerFaceColor', '#0072BD', 'LineWidth', 4);
      
        scatter(complexity(:,5), reward(:,5), 120, 'filled', 'MarkerFaceColor', '#A2142F');
        polycoef = polyfit(complexity(:,5), reward(:,5), 2);
        X = linspace(min(complexity(:,5)), max(complexity(:,5)), 50);
        Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
        p2 = plot(X, Y, 'MarkerFaceColor', '#A2142F', 'LineWidth', 4);
        
        legend([p1 p2], {'Ns=6 Baseline','Ns=6 Train'}, 'Location', 'southeast');
        xlim([1.2 1.61]);
        xlabel('Policy complexity'); ylabel('Average reward');
%}
%% RT-Complexity curve
%%
time = nan(nSubj, length(condition));
complexity = nan(nSubj, length(condition));
for s = 1:nSubj
    for c = 1:length(condition)
        idx = strcmp(data(s).cond, condition(c));
        state = data(s).s(idx);
        action = data(s).a(idx);
        time(s,c) = nanmean(data(s).rt(idx));
        complexity(s,c) = information(state', action');
    end
end


hold on;
entry = 1;
scatter(complexity(:,entry), time(:,entry), 120, 'filled', 'MarkerFaceColor', '#0072BD');
polycoef = polyfit(complexity(:,entry), time(:,entry), 2);
X = linspace(0, 1.55, 100);
Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
p1 = plot(X, Y, 'MarkerFaceColor', '#0072BD', 'LineWidth', 4);

entry = 5;
scatter(complexity(:,entry), time(:,entry), 120, 'filled', 'MarkerFaceColor', '#D95319');
polycoef = polyfit(complexity(:,entry), time(:,entry), 2);
X = linspace(0, 1.55, 100);
Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
p2 = plot(X, Y, 'MarkerFaceColor', '#D95319', 'LineWidth', 4);

legend([p1 p2], {'Ns=4 Baseline','Ns=6 Baseline'}, 'Location', 'northeast');
%xlim([0 1.62]); ylim([0.6, 1.0]);
xlabel('Policy complexity'); ylabel('Average reward');
end