function analyze_psycho(reward, complexity, data, survey)
% dimensional trait and psychopathology analysis
% called by "analysis_manip"

% INPUT: data - behavioral data
%        survey - survey data
if nargin<4; load('survey_data.mat'); end
if nargin<3; load('data_manip_3.mat'); end

exc = 11;
data(exc) = []; reward(exc,:) = []; complexity(exc,:) = [];
%% complexity (each blcok condition) vs survey score
survey_name = {'SCZ','OCI-R','PHQ-9','SHAPS','TEPS','AMI'};
figure; hold on;
fn = fieldnames(survey);
for i = 1:length(fieldnames(survey))
    if(isnumeric(survey.(fn{i})))
        subplot(1,length(fn),i); hold on;
        plot(complexity,survey.(fn{i}),'.','MarkerSize',30); lsline;
        for c = 1:size(complexity,2)
            [r(i,c),p(i,c)] = corr(complexity(:,c),survey.(fn{i}), 'Type', 'Pearson');
        end
        xlabel('Policy Complexity')
        ylabel('Score')
        title(survey_name{i})
    end
end

%% complexity (all block conditions) vs survey score

figure; hold on;
fn = fieldnames(survey);
for i = 1:length(fieldnames(survey))
    if(isnumeric(survey.(fn{i})))
        subplot(1,length(fn),i); hold on;
        plot(complexity(:),repmat(survey.(fn{i}),size(complexity,2),1),'k.','MarkerSize',30); lsline;
        [R(i),P(i)] = corr(complexity(:),repmat(survey.(fn{i}),size(complexity,2),1), 'Type', 'Pearson');
        xlabel('Policy Complexity')
        ylabel('Score')
        title(survey_name{i})
    end
end



%% can scores predict manipulations? 

% scores vs change in policy complexity on load task / reward task 
manip = [complexity(:,3)-complexity(:,2) complexity(:,4)-complexity(:,2) reward(:,4)-reward(:,2)];

figure; hold on;
fn = fieldnames(survey);
for i = 1:length(fieldnames(survey))
    if(isnumeric(survey.(fn{i})))
        subplot(1,length(fn),i); hold on;
        for m = 1:size(manip,2)
        plot(manip(:,m),survey.(fn{i}),'.','MarkerSize',30); lsline;
        [r(i,m),p(i,m)] = corr(manip(:,m),survey.(fn{i}), 'Type', 'Pearson');
        end
        xlabel('\Delta Complexity or \Delta Reward')
        ylabel('Score')
        title(survey_name{i})
    end
end
% scores vs reduction in ICRT 

end