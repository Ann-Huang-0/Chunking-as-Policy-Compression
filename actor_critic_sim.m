function simdata = actor_critic_sim(agent, data, incentives)

if ~isfield(agent, 'beta')
    agent.beta = agent.beta0;
end

%simdata = data;
cond = {{'Ns4,baseline'}, {'Ns4,train', 'Ns4,perform', 'Ns4,test'},...
        {'Ns6,baseline'}, {'Ns6,train', 'Ns6,perform', 'Ns6,test'}};

for setId = 1:length(cond)
    idx = [];
    expCond = cond{setId};
    for c = 1:length(expCond)
        idx = [idx find(strcmp(data.cond, expCond{c}))'];
    end
    condition = data.cond(idx);
    state = data.s(idx);
    corrchoice = state;
    setsize = length(unique(state));
    nA = setsize + 1;                 
    theta = zeros(setsize, nA);               
    V = zeros(setsize,1)+0.01;             
    Q = zeros(setsize,nA)+0.01;                    
    beta = agent.beta;
    p = ones(1,nA)/nA;
 
    if setsize==4
        %p=[0.25 0.125 0.25 0.25 0.125]; 
        chunk = [2 1];
        if ~exist('incentives', 'var')
            reward = [eye(4), transpose([0 1 0 0])];
        else
            reward = incentives.Ns4;
        end
    end
    if setsize==6
        %p=[1/6 1/6 1/6 1/6 1/12 1/6 1/12]; 
        chunk = [5 4];
        if ~exist('incentives', 'var')
            reward = [eye(6), transpose([0 0 0 0 1 0])];
        else
            reward = incentives.Ns6;
        end
    end

    ecost = 0;
    inChunk = 0;
    chunkStep = 0;
    a_actual = 0;
    policy_prev = 0;
    
   for t = 1:length(state)
        s = state(t);
        
        if inChunk == 0
            d = beta * theta(s,:) + log(p);
            logpolicy = d-logsumexp(d);
            policy = exp(logpolicy);
            a = fastrandsample(policy); 
            
            r = reward(s,a);
            if a==nA; inChunk=1; chunkStep=1; end
        else
            a = nA;
            chunkStep = chunkStep+1;
            r = reward(s, chunk(chunkStep));
        end
        
        cost = logpolicy(a) - log(p(a));
        if inChunk==1 && chunkStep>1; cost=0; end
        if inChunk==1; acc = s==chunk(chunkStep); a_ground = chunk(chunkStep); end
        if inChunk==0; acc = s==a; a_ground = a; end
        
        if agent.m > 1                       
            rpe = beta*r - cost - V(s);       
        else
            rpe = r - V(s);                   
        end
        ecost = ecost + agent.lrate_e*(cost-ecost);    % policy cost update
        
        if agent.lrate_beta > 0
            beta = beta + agent.lrate_beta*2*(agent.C-ecost); 
            beta = max(min(beta,50),0);
        end
                    
        g = agent.beta*(1 - policy(a));                        % policy gradient
        theta(s,a) = theta(s,a) + (agent.lrate_theta)*rpe*g;   % policy parameter update
        V(s) = V(s) + agent.lrate_V*rpe;
        
        simdata.s(idx(t)) = s;
        simdata.r(idx(t)) = r;
        simdata.a(idx(t)) = a_ground;
        simdata.beta(idx(t)) = beta;
        simdata.ecost(idx(t)) = ecost;
        simdata.cost(idx(t)) = cost;
        simdata.acc(idx(t)) = acc;
        simdata.cond(idx(t)) = condition(t);
        simdata.theta{idx(t)} = theta;
        simdata.inChunk(idx(t)) = inChunk;
        simdata.chunkStep(idx(t)) = chunkStep;
        simdata.policy{idx(t)} = policy;
    
        if chunkStep==length(chunk); inChunk=0; chunkStep=0; end
    end
end
end
        
        
        