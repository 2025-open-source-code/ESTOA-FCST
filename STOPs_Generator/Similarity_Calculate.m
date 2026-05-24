

clc,clear
rng default
task_families = {'Sphere','Ellipsoid','Schwefel','Quartic','Ackley','Rastrigin','Griewank','Levy'}; % eight task families
transfer_scenarios = {'a','e'}; % intra-family and inter-family transfers
xis = [0 0.7 1]; % the parameter xi that determines optimum coverage
% similarity_distributions = {'c','u','i','d'}; % four representative similarity distributions
similarity_distributions = {'d1','d2','d3','d4','d5'}; % four representative similarity distributions
k = 50; % the number of previously-solved source tasks
folder_problems = '.\benchmarks_My';
if ~isfolder(folder_problems)
    mkdir(folder_problems);
end
% function - intra/inter - coverage rate - similarity distribution - dimension - number of sources

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


no_problems = size(specifications,1);
% count = 0; % the number of available STOPs
count=zeros(no_problems, 3);

for n = 1:no_problems
    % import the black-box STO problem to be solved
    load(['.\benchmarks_My\',task_families{specifications(n,1)},'-T',...
        transfer_scenarios{specifications(n,2)},'-xi',num2str(xis(specifications(n,3))),...
        '-S',similarity_distributions{specifications(n,4)},'-d',...
        num2str(specifications(n,5)),'-k',num2str(specifications(n,6)),'.mat']);
    
    S=zeros(1, length(sources));
    target_opt=(target.x_best-target.lb)./(target.ub-target.lb);
    for i=1:length(sources)
       source_opt=(sources(i).x_best-sources(i).lb)./(sources(i).ub-sources(i).lb);
       S(i)= 1-max(abs(target_opt-source_opt));
    end
    count(n, 1)=sum(S<=0.3)/length(sources);
    count(n, 3)=(sum(S>=0.7))/length(sources);
    count(n, 2)=1-count(n, 1)-count(n, 3);
end
count
