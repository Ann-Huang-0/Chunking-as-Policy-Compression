function policyComplexityAnalysis()
prettyplot;
load('actionChunk_data.mat');
nSubj = length(data);
complexity = recoded_policy_complexity(data);
condition = {'Ns4,baseline', 'Ns4,train', 'Ns4,perform', 'Ns4,test', ...
             'Ns6,baseline', 'Ns6,train', 'Ns6,perform', 'Ns6,test'};
         
reward = nan(nSubj, length(condition));
for s = 1:nSubj
    for c = 1:length(condition)
        idx = strcmp(data(s).cond, condition(c));
        state = data(s).s(idx);
        action = data(s).a(idx);
        reward(s,c) = mean(state==action);
    end
end

%% Average policy complexity for different blocks
avgComplx = reshape(mean(complexity,1), [4 2])';
sem = nanstd(complexity,1)/sqrt(nSubj);
sem = reshape(sem, [4 2])';

bmap = plmColors(4, 'pastel1'); hold on;
b = bar(avgComplx(:,1:2)); 
errorbar_pos = errorbarPosition(b, sem(:,1:2));
errorbar(errorbar_pos', avgComplx(:,1:2), sem(:,1:2), sem(:,1:2), 'k','linestyle','none', 'lineWidth', 1.2);
set(gca, 'XTick',1:2, 'XTickLabel', {'Ns=4', 'Ns=6'});
legend('Random Train', 'Structured Train','Location', 'northwest'); legend('boxoff');

bmap = plmColors(4, 'pastel2'); 
figure; hold on;
b = bar(avgComplx(:,3:4)); 
errorbar_pos = errorbarPosition(b, sem(:,3:4));
errorbar(errorbar_pos', avgComplx(:,3:4), sem(:,3:4), sem(:,3:4), 'k','linestyle','none', 'lineWidth', 1.2);
set(gca, 'XTick',1:2, 'XTickLabel', {'Ns=4', 'Ns=6'});
legend('Strcutured Test', 'Random Test','Location', 'northwest'); legend('boxoff');


%% Reward-complexity curve
plot_RPCcurve(reward, complexity, [1 2], {'Ns=4, Random Train', 'Ns=4, Structured Train'});
plot_RPCcurve(reward, complexity, [5 6], {'Ns=6, Random Train', 'Ns=6, Structured Train'});
plot_RPCcurve(reward, complexity, [3 4], {'Ns=4, Structured Test', 'Ns=4, Random Test'});
plot_RPCcurve(reward, complexity, [7 8], {'Ms=6, Structured Test', 'Ns=6, Random Test'});
plot_RPCcurve(reward, complexity, [1 5], {'Ns4, Random Train', 'Ns6, Random Train'});
plot_RPCcurve(reward, complexity, [2 6], {'Ns4, Structured Train', 'Ns6, Structured Train'});


%% Reward-complexity curve without scatter plots
entrySet = [1 2 5 6];
colors = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E'};
figure; hold on;
for i = 1:length(entrySet)
    polycoef = polyfit(complexity(:,entrySet(i)), reward(:,entrySet(i)), 2);
    X = linspace(0.6, 1.4, 80);
    Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
    p(i) = plot(X, Y, 'Color', colors{i}, 'LineWidth', 4);
end
legend('Ns=4, Random Train', 'Ns=4, Structured Train', 'Ns=6, Random Train', 'Ns=6, Structured Train',...
       'location', 'southeast'); legend('boxoff');
ylim([0 1]);xlabel('Policy Complexity'); ylabel('Average Reward');


entrySet = [3 7 8];
colors = {'#D95319', '#7E2F8E', '#EDB120'};
figure; hold on;
for i = 1:length(entrySet)
    polycoef = polyfit(complexity(:,entrySet(i)), reward(:,entrySet(i)), 2);
    X = linspace(0.6, 1.4, 80);
    Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
    p(i) = plot(X, Y, 'Color', colors{i}, 'LineWidth', 4);
end
polycoef = polyfit(complexity(:,4), reward(:,4), 2);
X = linspace(1.1, 1.4, 80);
Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
plot(X, Y, 'Color', '#0072BD', 'LineWidth', 4);

legend('Ns=4, Structured Test', 'Ns=6, Structured Test', 'Ns=6, Random Test', 'Ns=4, Random Test',...
       'location', 'southeast');
legend('boxoff');
ylim([0 1]); xlabel('Policy Complexity'); ylabel('Average Reward');


%% RT-Complexity curve
avgRT = nan(nSubj, length(condition));
rtChunkCorr = zeros(nSubj, length(condition));
chunkInit = [2,5];
for s = 1:nSubj
    for c = 1:length(condition)
        idx = strcmp(data(s).cond, condition(c));
        state = data(s).s(idx);
        action = data(s).a(idx);
        rt = data(s).rt(idx);
        avgRT(s,c) = nanmean(rt);
        if contains(condition(c),'4'); condIdx = 1; end
        if contains(condition(c),'6'); condIdx = 2; end
        pos = find(state==chunkInit(condIdx))+1; pos(pos>length(state))=[];
        rtChunkCorr(s,c) = nanmean(rt(intersect(find(state == action), pos)));
    end
end

hold on;
entry = 7;
scatter(complexity(:,entry), avgRT(:,entry), 120, 'filled', 'MarkerFaceColor', '#0072BD');
polycoef = polyfit(complexity(:,entry), avgRT(:,entry), 2);
X = linspace(0, 1.55, 100);
Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
p1 = plot(X, Y, 'Color', '#0072BD', 'LineWidth', 4);

entry = 8;
scatter(complexity(:,entry), avgRT(:,entry), 120, 'filled', 'MarkerFaceColor', '#D95319');
polycoef = polyfit(complexity(:,entry), avgRT(:,entry), 2);
X = linspace(0, 1.55, 100);
Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
p2 = plot(X, Y, 'Color', '#D95319', 'LineWidth', 4);

legend([p1 p2], {'Ns=4 Baseline','Ns=6 Baseline'}, 'Location', 'northeast');
legend('boxoff');
%xlim([0 1.62]); ylim([0.6, 1.0]);
xlabel('Policy complexity'); ylabel('Average RT');

%% Correlation between RT and policy complexity

% average & intrachunk for Perform & Test
avgRT_test = horzcat([avgRT(:,3); avgRT(:,4)], [avgRT(:,7); avgRT(:,8)]);
intraRT_test = horzcat([rtChunkCorr(:,3); rtChunkCorr(:,4)], [rtChunkCorr(:,7); rtChunkCorr(:,8)]);
% policy complexity for Perform & Test
complx_test = horzcat([complexity(:,3); complexity(:,4)], [complexity(:,7); complexity(:,8)]);

% test for correlation between RT & Complexity in Perform & Test
[r,p] = corr(avgRT_test(:,1), complx_test(:,1), 'Type', 'Pearson');
[r,p] = corr(avgRT_test(:,2), complx_test(:,2), 'Type', 'Pearson');
[r,p] = corr(intraRT_test(:,1), complx_test(:,1), 'Type', 'Pearson');
[r,p] = corr(intraRT_test(:,2), complx_test(:,2), 'Type', 'Pearson');

model = fitlm(intraRT_test(:,2), complx_test(:,2));
model.Coefficients
