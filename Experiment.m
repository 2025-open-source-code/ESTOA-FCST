

clc,clear

task_families = {'Sphere','Ellipsoid','Schwefel','Quartic','Ackley','Rastrigin','Griewank','Levy'}; % eight task families
transfer_scenarios = {'a','e'}; % intra-family and inter-family transfers
xis = [0 0.7 1]; % the parameter xi that determines optimum coverage
similarity_distributions = {'d1','d2','d3','d4','d5'};  % four representative similarity distributions
% similarity_distributions = {'c','u','i','d'}; % four representative similarity distributions
k = 100; % the number of previously-solved source tasks


folder_problems = 'C:\Research\STOPs_Generator\benchmarks_My';
specifications = [
    1 1 3 1 35 100; 
    2 2 3 1	50 100; 
    3 1 3 1	60 100; 
    4 2 3 2	35 100; 
    5 1 3 2 50 100; 
    6 2 3 2	60 100; 
    7 1 3 3	35 100; 
    8 2 3 3	35 200; 
    2 1 3 4	50 100; 
    4 2 3 4 50 200; 
    5 1 3 5	60 100; 
    7 2 3 5	60 200;
    ];
% specifications(:, 6)=50;

num_problems = size(specifications,1); % the number of individual benchmark problems
optimizer = 'ea'; % evolutionary optimizer
popsize = 50; % population size
FEsMax = 5000; % the number of function evaluations available
runs = 50; % the number of independent runs
metrics_set = {'FKNN'};
alpha = 0.2;
K_value = 10; % no meaning
para_FKNN = 5;
para_train_set_fix=100;
para_train_set_add=0.5;
statistics=[1 1];
% opts_sesto.gen_trans  =1; % the generation gap of periodically triggering the knowledghe transfer
algorithm_list = [transpose(1:length(metrics_set)),zeros(length(metrics_set),...
    1)]; % selection-based S-ESTO algorithms
% [naming rule of an S-ESTO algorithm: idxS-idxA, while 0 is random selection or no adaptation]
% examples: [4 0] denotes a selection-based S-ESTO equipped with the metric S-M1
% [0 4] denotes an adaptation-based S-ESTO equipped with the adaptation A-M2-A
% [6 7] denotes an integration-based S-ESTO equipped with S-WD and A-OC-A
% h=waitbar(0,'Starting'); % process monitor
runs_total = size(algorithm_list,1)*num_problems*runs;
% count = 0*num_problems*runs;
% s=rng; %keep the seed for generating numbers to be the same in all compared algorithms
rng default

for a = 1
    for n =1:num_problems
        results_opt = struct;
        % import the black-box STO problem to be solved
        stop_tbo = STOP('func_target',task_families{specifications(n,1)},'trans_sce',...
            transfer_scenarios{specifications(n,2)},'xi',xis(specifications(n,3)),...
            'sim_distribution',similarity_distributions{specifications(n,4)},'dim',...
            specifications(n,5),'k',specifications(n,6),'mode','opt','folder_stops',folder_problems);
       
        target_task = stop_tbo.target_problem;
        knowledge_base = stop_tbo.knowledge_base;
        source_tasks = stop_tbo.source_problems;

        problem.fnc = target_task.fnc;
        problem.lb = target_task.lb;
        problem.ub = target_task.ub;

        % parameter configurations of the sesto solver
        opts_sesto.algorithm_id = algorithm_list(a,:);
        opts_sesto.knowledge_base = knowledge_base;
        opts_sesto.gen_trans  =1; % the generation gap of periodically triggering the knowledghe transfer
        opts_sesto.metrics = metrics_set; % similarity metrics
        method = metrics_set{a};
        
        K_value = 1*length(knowledge_base);
        train_set = Training_Data_Construction_xue(knowledge_base, source_tasks, K_value, popsize, FEsMax, alpha, para_train_set_fix, statistics);

        parfor r = 1: runs   % 1:runs
            [solutions,fitnesses,num_useful_sources] = sesto_optimizer_main(problem,popsize,FEsMax,...
                optimizer,opts_sesto, train_set, alpha, para_FKNN, para_train_set_fix, para_train_set_add, statistics);
            results_opt(r).solutions = solutions;
            results_opt(r).fitnesses = fitnesses;
            results_opt(r).num_useful_sources = num_useful_sources;

            fprintf(['Algorithm: ','S-',opts_sesto.metrics{a},'+A-N, STOP-',...
                num2str(n),', run: ',num2str(r),'\n']);
%             waitbar(count/runs_total,h,sprintf('Optimization in progress: %.2f%%',...
%                 count/runs_total*100));
        end
        % save the results
        mkdir (strcat('.\experimental studies_final_xue_tec_c1\', metrics_set{algorithm_list(a,1)}));
        save(['.\experimental studies_final_xue_tec_c1\',metrics_set{algorithm_list(a,1)}, '\', task_families{specifications(n,1)},'-T',...
            transfer_scenarios{specifications(n,2)},'-xi',num2str(xis(specifications(n,3))),...
            '-S',similarity_distributions{specifications(n,4)},'-d',num2str(specifications(n,5)),...
            '-k',num2str(specifications(n,6)),'-S-',metrics_set{algorithm_list(a,1)},...
            '+A-N.mat'],'results_opt');
    end
end
% close(h);