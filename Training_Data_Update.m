
function train_set=Training_Data_Update(test_set, idx_source, popsize, train_set, para_train_set_fix, ~, fitness_all, index_t, gen)

[~, index]=sort(fitness_all,'ascend');
for i = 1: length(idx_source)
new_sample=test_set(idx_source(i), :);
temp=find(index(1:popsize)==popsize+index_t);
if isempty(temp)
    label_new=2;
else
    label_new=1;
end
example=[new_sample label_new];
train_set=[train_set; example];
end
if size(train_set,1) > para_train_set_fix
    train_set(1:size(train_set, 1)-para_train_set_fix,:)=[];
end