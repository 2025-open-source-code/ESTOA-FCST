
function [test_set,label,membership] = Transferability_Measure(knowledge_base,train_set,solutions,Target_s,Source_s,statistics,gen,alpha,para_FKNN)

% generate test data
num_sources = length(knowledge_base); % the number of source tasks
difference=zeros(num_sources, length(statistics));
Target_s = alpha*Target_s+(1-alpha)*[mean(solutions{gen});std(solutions{gen})];
% Target_s = alpha*Target_s+(1-alpha)*[mean(solutions{gen}); std(solutions{gen})];
for i=1:num_sources
    Source_s(i).v = alpha*Source_s(i).v+(1-alpha)*[mean(knowledge_base(i).solutions{gen});std(knowledge_base(i).solutions{gen})];
%     Source_s(i).v = alpha*Source_s(i).v+(1-alpha)*[mean(knowledge_base(i).solutions{gen});std(knowledge_base(i).solutions{gen})];
    for n= 1:length(statistics)
       difference(i, n)=norm(Target_s(n, :)-Source_s(i).v(n, :));
    end
end

% using FKNN to predict the class label and membership degree
test_set = difference;
[label,membership] = Fuzzy_KNN(train_set(:, 1:end-2), train_set(:, end-1), test_set, para_FKNN);

end
