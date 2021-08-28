function data = analyze_rawdata(experiment)
%{
    Analyze raw jsPsych experiment data saved in .csv files
    Usage:
        data = analyze_rawdata('setsize_manip')         for 1st experiment
        data = analyze_rawdata('modified_freq_discr')   for 2nd experiment
%}
prettyplot;

switch experiment
    case 'setsize_manip'
        folder = 'experiment_setsize/data/';
        
        subj1 = {'AFM65NU0UXIGP', 'AT6OT5K5Z4V0J', 'A248QG4DPULP46', 'A26NGLGGFTATVN', ...
            'A2GJYB46FWIB5Q', 'A16G6PPH1INQL8', 'A1M1E62KXCDNL0', 'A38IPIPA3T3G4',...
            'A1160COTUR26JZ', 'A1FNNL4YJGBU8U', 'A1W7I6FN183I8F', 'AGTKSA15G1LBN',...
            'AJQ71YIGY01HZ', 'A30VAYXB85107X', 'A4SC8G0149GEG', 'AQMLJYUQCSG22',...
            'A1HKYY6XI2OHO1', 'A1DZMZTXWOM9MR', 'A23BWWRR7J5XLS', 'A2A07J1P6YEW6Z',...
            'A2S64AUN7JI7ZS', 'A2V1T6RKD06I2X', 'A2ZDEERVRN5AMC', 'A3BUWQ5C39GRQC',...
            'A3EG4C9T4F5DUR', 'A3KMNX2P2QP9JU', 'A3RR85PK3AV9TU', 'A8UJNIY9R8S7W',...
            'AJQ71YIGY01HZ', 'AW0K78T4I2T72'};
        
        subj2 = {'A2YC6PEMIRSOAA', 'A16G6PPH1INQL8', 'A2BK45LZGGWPLX', 'A13WTEQ06V3B6D',...
            'A28AXX4NCWPH1F', 'A2NT3OQZUUZPEO', 'A3TBG0S2IEBVHU', 'A3UUH3632AI3ZX',...
            'A3VEF4M5FIN7KH', 'A6MWJK1YEY5L2', 'A8KX1HFH8NE2Q', 'AJQ71YIGY01HZ',...
            'AOOLS8280CL0Z', 'AR8O1107OAW4V', 'A12HWPFXQPITHD', 'A28U7B76HLCS1U',...
            'AJQ71YIGY01HZ'};
        
        subj = [subj1 subj2];
        nTrials = 700;
        savepath = 'actionChunk_data.mat';
        
        cutoff = 0.0;
        startOfExp = 4;  %change
        data.cutoff = cutoff;
        pcorr = zeros(length(subj),1);
        
        for s = 1:length(subj)
            % 1.rt  2.url  3.trial_type  4.trial_index  5.time_elapsed  % 6.internal_node_id
            % 7.view_history  8.stimulus  9.key_pressed  10.state  11.test_part
            % 12.correct_response  13.correct  14.bonus  15.responses
            
            A = readtable(strcat(folder, subj{s}));
            A = table2cell(A);
            %A(strcmp(A(:,11), 'practice'),:) = [];
            
            corr = sum(strcmp(A(startOfExp:end, 13), 'true'));
            incorr = sum(strcmp(A(startOfExp:end,13), 'false'));
            pcorr(s) = corr/(corr+incorr);
        end
        
        figure; hold on;
        histogram(pcorr, 20, 'FaceColor', '#0072BD');
        xlabel('% Accuracy'); ylabel('# of Subjects');
        %xlim([0.7 1]);
        box off; set(gcf,'Position',[200 200 800 300]);
        subj = subj(pcorr>cutoff); % filter by correct probability > cutoff
        
        % Construct data structure
        for s = 1:length(subj)
            A = readtable(strcat(folder, subj{s}));
            A = table2cell(A);
            corr = sum(strcmp(A(startOfExp:end, 13), 'true'));
            incorr = sum(strcmp(A(startOfExp:end,13), 'false'));
            data(s).performance = corr/(corr+incorr);
            data(s).bonus = round(data(s).performance * 8 + 2, 2);
            
            A(:,13) = strrep(A(:,13), 'true', '1');
            A(:,13) = strrep(A(:,13), 'false', '0');
            
            condition = unique(A(:,11));
            condition(strcmp(condition, '')) = [];
            expTrialIdx = ismember(A(:,11), condition);
            A(strcmp(A, 'null'),9) = {'-1'};
            data(s).ID = subj{s};
            
            data(s).cond = A(expTrialIdx, 11);
            data(s).idx = A(expTrialIdx, 4);
            data(s).s = cell2mat(A(expTrialIdx, 10));
            data(s).a = str2num(cell2mat(A(expTrialIdx, 9))) - 48;
            data(s).a(data(s).a==-49) = NaN;
            data(s).corrchoice = cell2mat(A(expTrialIdx,12)) - 48;
            data(s).acc = str2num(cell2mat(A(expTrialIdx, 13)));
            data(s).r = str2num(cell2mat(A(expTrialIdx, 13)));
            data(s).rt = zeros(nTrials, 1);
            idx = find(expTrialIdx);
            for i=1:sum(expTrialIdx)
                data(s).rt(i) = str2double(A{idx(i),1});
            end
            data(s).N = nTrials;
            
        end
  
        %save(savepath, 'data');
      
%% 
    case 'load_incentive_manip'
        addpath('/Users/ann/Desktop/CCN_Lab/BehavioralExperiment/Ns6_FinalVersion');
        folder = 'experiment_manip/data/';
        
        % study 313233. released on August 14
        subj1 = {'A1FMVUYV72MUO3', 'A1HRH92NH49RX2', 'A1OZPLHNIU1519', 'A2615YW1YERQBO', 'A2Y87M8V0N1M6P',...
            'A2Z6NL0CTXY0ZB', 'A36SM7QM8OK3H6', 'A3OTBMKOEQ410P', 'A3V2XCDF45VN9X', 'AQRKP48O0WKBW', ...
            'AVFMTS8A5R4XK', 'A1YSYI926BBOHW', 'A2JM9K709T1M0G'};
        
        % study 313267, released on August 15
        subj2 = {'A16Z9FSSF1X74O', 'A1I72NHC21347A', 'A2196WCNDZULFS', 'A2FYFCD16Z3PCC', 'A2R75YFKVALBXE',...
            'A2VRDE2FHCBMF8', 'A37OUZOGQKGMW0', 'A3GEYEPOHA33SP', 'A3I40B0FATY8VH', 'A3JC9VPPTHNKVL',...
            'A3NXT3OVGL7QNR', 'AKP66RIZ3LQVX', 'ANK8K5WTHJ61C', 'APGX2WZ59OWDN', 'ATU582WJWMEL2',...
            'AZ69TBTDH7AZS'};
        
        subj = [subj1 subj2];
        nTrials = 480;
        %savepath = 'data_manip_2.mat';
        
        cutoff = 0;
        startOfExp = 5;
        data.cutoff = cutoff;
        pcorr = zeros(length(subj),1);
        
        for s = 1:length(subj)
            % 1.rt  2.url  3.trial_type  4.trial_index  5.time_elapsed  % 6.internal_node_id
            % 7.view_history  8.stimulus  9.key_pressed  10.state  11.test_part
            % 12.correct_response  13.order_block  14.order_chunk  15.correct
            
            A = readtable(strcat(folder, subj{s}));
            A = table2cell(A);
            
            corr = sum(strcmp(A(startOfExp:end, 15), 'true'));
            incorr = sum(strcmp(A(startOfExp:end,15), 'false'));
            pcorr(s) = corr/(corr+incorr);
        end
        
        figure; hold on;
        histogram(pcorr, 20, 'FaceColor', '#0072BD');
        xlabel('% Accuracy'); ylabel('# of Subjects');
        %xlim([0.7 1]);
        box off; set(gcf,'Position',[200 200 800 300]);
        subj = subj(pcorr>cutoff); 
        
        % Convert csv file to data structure
        
        for s = 1:length(subj)
            A = readtable(strcat(folder, subj{s}));
            A = table2cell(A);
            corr = sum(strcmp(A(startOfExp:end, 15), 'true'));
            incorr = sum(strcmp(A(startOfExp:end,15), 'false'));
            data(s).performance = corr/(corr+incorr);
            data(s).bonus = round(data(s).performance * 8 + 2, 2);
            
            A(:,15) = strrep(A(:,15), 'true', '1');
            A(:,15) = strrep(A(:,15), 'false', '0');
            
            condition = unique(A(:,11));
            condition(strcmp(condition, '')) = [];
            expTrialIdx = ismember(A(:,11), condition);
            A(strcmp(A, 'null'),9) = {'-1'};
            data(s).ID = subj{s};
            
            data(s).cond = A(expTrialIdx, 11);
            data(s).idx = A(expTrialIdx, 4);
            data(s).s = cell2mat(A(expTrialIdx, 10));
            data(s).a = str2num(cell2mat(A(expTrialIdx, 9)));
            data(s).a(data(s).a==-49) = NaN;
            data(s).corrchoice = cell2mat(A(expTrialIdx,12));
            data(s).acc = str2num(cell2mat(A(expTrialIdx, 15)));
            data(s).r = str2num(cell2mat(A(expTrialIdx, 15)));
            data(s).rt = zeros(nTrials, 1);
            idx = find(expTrialIdx);
            for i=1:sum(expTrialIdx)
                data(s).rt(i) = str2double(A{idx(i),1});
            end
            data(s).order = A(startOfExp, 13);
            data(s).chunk_order = A(startOfExp, 14);
            data(s).N = nTrials;
        end
        
        
        % Data Preprocessing
        
        for subj = 1:length(data)
            % recode actions to [1,2,3,4]
            action = [83, 68, 72, 74];
            for i = 1:length(action)
                idx = data(subj).a==action(i);
                data(subj).a(idx) = i;
            end
            
            % find the chunk structure associated with each structured block
            blocks = split(data(subj).order, ',');
            blocks(strcmp(blocks, 'random')) = [];
            c = data(subj).chunk_order; c = c{1};
            for i = 1:3
                chunk = zeros(1,2);
                chunk(1) = str2num(c(2*i-1)); chunk(2) = str2num(c(2*i+1));
                data(subj).chunk.(blocks{i}) = chunk;
            end
            
            % assign 5x reward for the intrachunk state in structured_incentive block
            idx = strcmp(data(subj).cond, 'structured_incentive'); % trials in structured_incentive block
            idx = idx & data(subj).s == data(subj).chunk.structured_incentive(2); % trials that present the intrachunk state
            data(subj).r(idx) = data(subj).r(idx) * 5;
        end
        
        data = rmfield(data, {'order'; 'chunk_order'});
        %save(savepath, 'data');
        
        
%% 
    case 'modified_freq_discr'
%%
        addpath('/Users/ann/Desktop/CCN_Lab/BehavioralExperiment/Ns6_FinalVersion');
        folder = 'experiment_manip/data/';
        
        % study 315509, released on August 26, with modified frequency discrimination
        subj1 = {'A3RLCGRXA34GC0', 'A1KS9LITOVPAT8', 'AWAHIWLMQ0HUQ', 'A1IFIK8J49WBER', 'A38OPVI04AH4JG',...
                'A1SMVF4MXT0RIH', 'A2M183CETUMR96', 'A1S9I3WF8GG4RG', 'A2OVX9UW5WANQE', 'AIHUIAQ4922K3'};
        
        subj = [subj1];
        nTrials = 480;
        
        cutoff = 0;
        startOfExp = 5;
        data.cutoff = cutoff;
        pcorr = zeros(length(subj),1);
        
        for s = 1:length(subj)
            % 1.rt  2.url  3.trial_type  4.trial_index  5.time_elapsed  % 6.internal_node_id
            % 7.view_history  8.stimulus  9.key_pressed  10.state  11.test_part
            % 12.correct_response  13.order_block  14.order_chunk  15.order_freq
            % 16. correct
             
            A = readtable(strcat(folder, subj{s}));
            A = table2cell(A);
            
            corr = sum(strcmp(A(startOfExp:end, 16), 'true'));
            incorr = sum(strcmp(A(startOfExp:end,16), 'false'));
            pcorr(s) = corr/(corr+incorr);
        end
        
        figure; hold on;
        histogram(pcorr, 20, 'FaceColor', '#0072BD');
        xlabel('% Accuracy'); ylabel('# of Subjects');
        %xlim([0.7 1]);
        box off; set(gcf,'Position',[200 200 800 300]);
        subj = subj(pcorr>cutoff); 
        
        % Convert csv file to data structure
        
        for s = 1:length(subj)
            A = readtable(strcat(folder, subj{s}));
            A = table2cell(A);
            corr = sum(strcmp(A(startOfExp:end, 16), 'true'));
            incorr = sum(strcmp(A(startOfExp:end,16), 'false'));
            data(s).performance = corr/(corr+incorr);
            data(s).bonus = A{1456, 19};
            
            A(:,16) = strrep(A(:,16), 'true', '1');
            A(:,16) = strrep(A(:,16), 'false', '0');
            
            condition = unique(A(:,11));
            condition(strcmp(condition, '')) = [];
            expTrialIdx = ismember(A(:,11), condition);
            A(strcmp(A, 'null'),9) = {'-1'};
            data(s).ID = subj{s};
            
            data(s).cond = A(expTrialIdx, 11);
            data(s).idx = A(expTrialIdx, 4);
            data(s).s = cell2mat(A(expTrialIdx, 10));
            data(s).a = str2num(cell2mat(A(expTrialIdx, 9)));
            data(s).a(data(s).a==-49) = NaN;
            data(s).corrchoice = cell2mat(A(expTrialIdx,12));
            data(s).acc = str2num(cell2mat(A(expTrialIdx, 16)));
            data(s).r = str2num(cell2mat(A(expTrialIdx, 16)));
            data(s).rt = zeros(nTrials, 1);
            idx = find(expTrialIdx);
            for i=1:sum(expTrialIdx)
                data(s).rt(i) = str2double(A{idx(i),1});
            end
            data(s).order = A(startOfExp, 13);
            data(s).chunk_order = A(startOfExp, 14);
            data(s).N = nTrials;
        end
        
        
        % Data Preprocessing
        
        for subj = 1:length(data)
            % recode actions to [1,2,3,4]
            action = [83, 68, 72, 74];
            for i = 1:length(action)
                idx = data(subj).a==action(i);
                data(subj).a(idx) = i;
            end
            
            % find the chunk structure associated with each structured block
            blocks = split(data(subj).order, ',');
            blocks(strcmp(blocks, 'random')) = [];
            c = data(subj).chunk_order; c = c{1};
            for i = 1:3
                chunk = zeros(1,2);
                chunk(1) = str2num(c(2*i-1)); chunk(2) = str2num(c(2*i+1));
                data(subj).chunk.(blocks{i}) = chunk;
            end
            
            % assign 5x reward for the intrachunk state in structured_incentive block
            idx = strcmp(data(subj).cond, 'structured_incentive'); % trials in structured_incentive block
            idx = idx & data(subj).s == data(subj).chunk.structured_incentive(2); % trials that present the intrachunk state
            data(subj).r(idx) = data(subj).r(idx) * 5;
        end
        
        data = rmfield(data, {'order'; 'chunk_order'});
        %save(savepath, 'data');
        
end
end