% -------------
% Description:
% -------------
% This function (called Training_Data_Construction) is aim to construct training data from knowledge base 
% including the estimated solutions of previously solved source tasks.
% -------------
% Input:
% -------------

% -------------
% Output:
% -------------
% train_set: training data including labeled samples

function train_set = Training_Data_Construction(knowledge, sources, K_value, popsize, FEsMax, alpha, para_train_set_fix, statistics)

Gen=FEsMax/popsize;    % the maximal generations
k = length(knowledge); % the number of previously solved source tasks
Dim=sources(1).dims;
 
% save the optimal solution of each source task into X
X=[];
for i=1:k
[~, index] = min(knowledge(i).fitnesses{end, 1});
temp=knowledge(i).solutions{end, index};
X = [X; temp(index, :)];
end

% calculate the Euclidean distance between optimal solutions, and find
% their neighbors
Dist=pdist2(X, X);
[~, index]=sort(Dist, 2);

num_statistics=length(statistics);  % the number of used statistics
num_sample=para_train_set_fix;  % the number of generated samples
difference=zeros(num_sample, num_statistics);  % collect the generated samples
label=zeros(num_sample, 1);  % the quantified degree of performance improvement

for i=1:num_sample
source_index=randi(k);  % randomly select one from k source tasks
set=index(source_index, 1:K_value);  % collect K_value neighboring source tasks

% randomly selec one as source task, and another as target task from
% the neighboring source tasks
list = randperm(K_value);
source_no = set(list(1));
target_no = set(list(2));

% use the recursive method to generate the sample
source_statistics=zeros(num_statistics, Dim);
target_statistics=zeros(num_statistics, Dim);
for g = 1: Gen
    % extract the source population at the g generation
    source_solutions = knowledge(source_no).solutions{g, 1};
    % calculate the statistics on each dimension of the source population
    temp_s = quantile(source_solutions,statistics);
%     temp_s = [mean(source_solutions); std(source_solutions)];
    source_statistics = alpha*source_statistics+(1-alpha)*temp_s;

    % extract target population at the g generation
    target_solutions = knowledge(target_no).solutions{g, 1};
    % calculate the statistics on each dimension of target population
    temp_t = quantile(target_solutions,statistics);
%     temp_t = [mean(target_solutions); std(target_solutions)];
    target_statistics = alpha*target_statistics+(1-alpha)*temp_t;
end
for nn= 1:num_statistics
    difference(i, nn) = norm(target_statistics(nn, :)-source_statistics(nn, :));
end

% calculate the fitness of final population of source task
source_optimum = knowledge(source_no).solutions{end, 1};
fitness = zeros(popsize,1);
fun = sources(target_no).fnc;
for m=1:popsize % function evaluation
    x = sources(target_no).lb+(sources(target_no).ub-sources(target_no).lb).*source_optimum(m,:);
    fitness(m) = fun(x);
end
fitnuss_min=min(fitness);  % find the minimal fitness value

% identify the degree of performance improvement of the optimal solution of 
% source task to target task
if fitnuss_min > min(knowledge(target_no).fitnesses{1, 1})
    label(i, 1)=0;
elseif fitnuss_min <= min(knowledge(target_no).fitnesses{Gen, 1})
    label(i, 1)=Gen;
else
    count = Gen-1;
    while count
       Better=min(knowledge(target_no).fitnesses{count+1, 1});
       Worse=min(knowledge(target_no).fitnesses{count, 1});
       if Worse >= fitnuss_min && fitnuss_min > Better
          label(i, 1)=count;
          break;
       end
       count=count-1;
    end
end

end

% the strategy to divide samples into two classes
value=median(label);  % set the median of labels as one threshold value
label_fuzzy=zeros(num_sample, 1); % the label set of binary labels
for nn=1:num_sample
   if label(nn)>value || label(nn)==Gen
       label_fuzzy(nn)=1;  % positive class
   elseif label(nn)<=value || label(nn)==0
       label_fuzzy(nn)=2;  % negative class
   end
end

% form traininig data by combining features and labels
train_set = [difference label_fuzzy];
end


