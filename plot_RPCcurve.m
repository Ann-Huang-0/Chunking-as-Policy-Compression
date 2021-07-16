function plot_RPCcurve(reward, complexity, entrySet, legendContent)
%{
    reward: nSubj x nCondition
    complexity: nSubj x nCondition
    entrySet: which two conditions to compare
    legendContent: what are the labels/names for the two conditions

    Usage:
        plot_RPCcurve(reward, complexity, entrySet, legendContent)

%}

figure; hold on;
entry = entrySet(1);
scatter(complexity(:,entry), reward(:,entry), 120, 'filled', 'MarkerFaceColor', '#0072BD');
polycoef = polyfit(complexity(:,entry), reward(:,entry), 2);
X = linspace(0.6, 1.4, 80);
Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
p1 = plot(X, Y, 'Color', '#0072BD', 'LineWidth', 4);

entry = entrySet(2);
scatter(complexity(:,entry), reward(:,entry), 120, 'filled', 'MarkerFaceColor', '#D95319');
polycoef = polyfit(complexity(:,entry), reward(:,entry), 2);
X = linspace(0.6, 1.6, 80);
Y = polycoef(1).*X.*X + polycoef(2).*X + polycoef(3);
p2 = plot(X, Y, 'Color', '#D95319', 'LineWidth', 4);

legend([p1 p2], legendContent, 'Location', 'southeast');
legend('boxoff');
xlim([0.6 1.42]);
xlabel('Policy complexity'); ylabel('Average reward');
