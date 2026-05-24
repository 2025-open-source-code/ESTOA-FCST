
function [solution_sel, idx_source, candidate_C1]=Solution_Selection(knowledge_base,popsize,lb,ub,label,membership)

solution_sel=[];
idx_source=[];
candidate_C1 = find(label==1);  % collect promising source tasks
if ~isempty(candidate_C1)
    % perform solution selection
    set = find(membership(candidate_C1) == max(membership(candidate_C1)));
    idx = set(randi(length(set)));
    idx_source = idx;  % the index of the most promising source task
    idx_population = knowledge_base(idx_source).solutions{end};
%     normalized_solution = idx_population(randi(popsize),:);
    list = randperm(popsize);
    normalized_solution = idx_population(list(1),:);
    solution_sel = [solution_sel; lb+(ub-lb).*normalized_solution]; % the transferred solution
else
%     idx_source = randi(length(knowledge_base));
%     idx_population = knowledge_base(idx_source).solutions{end};
%     list = randperm(popsize);
%     normalized_solution = idx_population(list(1),:);
%     solution_sel = [solution_sel; lb+(ub-lb).*normalized_solution]; % the transferred solution
end

