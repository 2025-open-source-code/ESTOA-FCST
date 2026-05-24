
function [solutions,fitnesses,num_useful_sources] = sesto_optimizer_main(problem,popsize,FEsMax,optimizer,paras,train_set,alpha,para_FKNN,para_train_set_fix,para_train_set_add,statistics)

% initialization
fun = problem.fnc;
lb = problem.lb;
ub = problem.ub;
gen_trans = paras.gen_trans; % the generation gap of periodically triggering the knowledghe transfer
% algorithm_id = paras.algorithm_id; % the S-ESTO algorithm, idxS+idxA
% metrics = paras.metrics; % the list of similarity metrics in solution selection

solutions = cell(FEsMax/popsize,1);
fitnesses = cell(FEsMax/popsize,1);
population = lhsdesign_modified(popsize,lb,ub); % build an initial population using the LHS sampling
fitness = zeros(popsize,1);
for i=1:popsize % function evaluation
    fitness(i) = fun(population(i,:));
end
FEsCount = popsize;
gen = 1; % the generation count
solutions{gen} = (population-repmat(lb,popsize,1))./(repmat(ub,popsize,1)-...
    repmat(lb,popsize,1)); % convert the solutions into the unified search space
fitnesses{gen} = fitness;
num_useful_sources{gen} = [];

knowledge_base = paras.knowledge_base; % the knowledge base containing the evaluated solutions of k source tasks
num_sources = length(knowledge_base); % the number of solved source tasks

Target_s=zeros(length(statistics),length(lb));
for i=1:num_sources
   Source_s(i).v=zeros(length(statistics),length(lb));
end

dim = length(lb);
[popsize_s,dim_s] = size(knowledge_base(1).solutions{1});
gen_max = 100;
if dim_s < dim
    for i = 1:num_sources
        for g = 1: gen_max
            temp = rand(popsize_s, dim-dim_s);
            knowledge_base(i).solutions{g}=[knowledge_base(i).solutions{g} temp];
        end
    end
end
if dim_s > dim
    for i = 1:num_sources
        for g = 1: gen_max
            knowledge_base(i).solutions{g}(:, dim_s-dim+1:end)=[];
        end
    end
end

while FEsCount < FEsMax
    idx_source=[];
    % offspring generation using the specified operator
    population_parent = population;
    fitness_parent = fitness;
    offspring_generation_command = ['population_child = ',optimizer,...
        '_generator(population_parent,lb,ub);'];
    eval(offspring_generation_command);
    
    % the S-ESTO module
    if mod(gen,gen_trans) == 0
        
        % Measure knowledge transferability
%         metric = metrics{algorithm_id(1)};
        [test_set,label,membership] = Transferability_Measure(knowledge_base,train_set,solutions,Target_s,Source_s,statistics,gen,alpha,para_FKNN);
        
        % Perform solution selection based on class labels and memberships
        [solution_sel, idx_source, candidate_C1] = Solution_Selection(knowledge_base,popsize,lb,ub,label,membership);
        
        % Perform knowledge transfer if solution_set is not empty, which is achieved by
        % randomly replacing one offspring with the transferred solution.
        if ~isempty(solution_sel)
            for i=1:size(solution_sel, 1)
                index_t=randi(popsize);
                population_child(index_t,:) = solution_sel(i, :);
            end
        end
    end

    % offspring evaluation
    fitness_child = zeros(popsize,1);
    for i=1:popsize
        fitness_child(i) = fun(population_child(i,:));
    end
    
    FEsCount = FEsCount+popsize;
    gen = gen+1;

    % selection phase
    selection_command = ['[population,fitness]=',optimizer,...
        '_selector(population_parent,fitness_parent,population_child,fitness_child);'];
    eval(selection_command)
    
    fitness_all=[fitness_parent; fitness_child];

    % update the population
    solutions{gen} = (population-repmat(lb,popsize,1))./(repmat(ub,popsize,1)-...
        repmat(lb,popsize,1));
    fitnesses{gen} = fitness;
    
    % Perform the training data update
    if ~isempty(solution_sel)
       train_set=Training_Data_Update(test_set, idx_source, popsize, train_set, para_train_set_fix, para_train_set_add, fitness_all, index_t, gen);
    end
    
    num_useful_sources{gen} = length(candidate_C1);
    fprintf(['Gen: ',num2str(gen), ', fit:',num2str(min(fitness)),', size:',num2str(length(candidate_C1)),'\n']);
    
end