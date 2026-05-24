% Author: Xiaoming Xue
% Email: xminghsueh@gmail.com
%
% ------------
% Description:
% ------------
% This file is the script of generating the 12 benchmark problems developed
% in the following paper.
%
% ------------
% Reference:
% ------------
% X. Xue, Y. Hu, C. Yang, et al. ¡°How to Exploit Experience? Revisiting Evolutionary
% Sequential Transfer Optimization: Part A", Submitted for Peer Review.

clc,clear
% rng default
task_families = {'Sphere','Ellipsoid','Schwefel','Quartic','Ackley','Rastrigin','Griewank','Levy'}; % eight task families
transfer_scenarios = {'a','e'}; % intra-family and inter-family transfers
xis = [0 0.7 1]; % the parameter xi that determines optimum coverage
% similarity_distributions = {'c','u','i','d'}; % four representative similarity distributions
similarity_distributions = {'d1','d2','d3','d4','d5'}; % four representative similarity distributions
k = 50; % the number of previously-solved source tasks
folder_problems = '.\benchmarks_My_de';
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

for n = 1:no_problems
    STOP('func_target',task_families{specifications(n,1)},'trans_sce',...
        transfer_scenarios{specifications(n,2)},'xi',xis(specifications(n,3)),'sim_distribution',...
        similarity_distributions{specifications(n,4)},'dim',specifications(n,5),'k',...
        specifications(n,6),'mode','gen','folder_stops',folder_problems);
%     count = count+1;
%     fprintf('#%d of the 12 problems is ready!\n',count);
end

% addpath(folder_problems);