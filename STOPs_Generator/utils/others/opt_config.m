% ------------
% Description:
% ------------
% The function of configuring the optima of source and target tasks.
%
% ------------
% Inputs:
% ------------
% xi--->the parameter that determines optimum coverage
% num_tasks--->the number of source tasks
% d--->the problem dimension
% sim_distribution--->the similarity distribution
%
% ------------
% Outputs:
% ------------
% target_opt--->the optimum of the target task
% source_opt--->the optima of the source tasks
% lb_image--->the lower bound of the image in decison space
% ub_image--->the upper bound of the image in decison space
%

function [target_opt,source_opt,lb_image,ub_image] = opt_config(xi,num_tasks,d,sim_distribution)
source_opt = zeros(num_tasks,d);
lb_image = zeros(1,d);
ub_image = zeros(1,d);

for i = 1:d % a randomly generated box-constrained image
    lb_image(i) = rand*(1-xi);
    ub_image(i) = lb_image(i)+xi;
end

% u = unifrnd(0,1,1,num_tasks);
switch(sim_distribution)
     case 'd1'
        pd = makedist('Normal','mu',0.15,'sigma',0.1);
        X1 = random(pd, ceil(num_tasks*(2/3)), 1);
        pd = makedist('Normal','mu',0.45,'sigma',0.2);
        X2 = random(pd, num_tasks-length(X1), 1);      
        X=[X1; X2];
        tau = X;
        
    case 'd2'
        pd = makedist('Normal','mu',0.7,'sigma',0.1);
        X1 = random(pd, ceil(num_tasks*(2/3)), 1);
        pd = makedist('Normal','mu',0.45,'sigma',0.2);
        X2 = random(pd, num_tasks-length(X1), 1);      
        X=[X1; X2];   
        tau = X; 
        
    case 'd3'
        pd = makedist('Normal','mu',0.45,'sigma',0.2);
        X = random(pd, num_tasks, 1);  
        tau = X; 
        
    case 'd4'
        pd = makedist('Normal','mu',0.15,'sigma',0.1);
        X1 = random(pd, ceil(num_tasks/3), 1);
        pd = makedist('Normal','mu',0.45,'sigma',0.1);
        X2 = random(pd, ceil(num_tasks/3), 1);
        pd = makedist('Normal','mu',0.7,'sigma',0.1);
        X3 = random(pd, num_tasks-length(X1)-length(X2), 1);
        X=[X1; X2; X3];
        tau = X;  
        
    case 'd5'
        pd = makedist('Normal','mu',0.15,'sigma',0.1);
        X1 = random(pd, num_tasks/2, 1);
        pd = makedist('Normal','mu',0.7,'sigma',0.1);
        X2 = random(pd, num_tasks/2, 1);
        X=[X1; X2]; 
        tau = X;
        
end

tau(tau>1)=1;
tau(tau<0)=0;
target_opt = lb_image+(ub_image-lb_image).*rand(1,d);
for i = 1:num_tasks
    source_ori = lb_image+(ub_image-lb_image).*rand(1,d);
%     source_opt(i,:) = target_opt*(1-tau(i))+source_ori*tau(i);
    source_opt(i,:) = target_opt*tau(i)+source_ori*(1-tau(i));
end
