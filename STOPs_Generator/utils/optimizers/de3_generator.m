function population_child = de3_generator(population_parent,lb,ub)
[popsize,dim] = size(population_parent);
population = (population_parent-repmat(lb,popsize,1))./(repmat(ub,popsize,1)-repmat(lb,popsize,1));

beta_min = 0.2;   % Lower Bound of Scaling Factor
beta_max = 0.8;   % Upper Bound of Scaling Factor
pCR = 0.2;        % Crossover Probability
VarSize = [1 dim];   % Decision Variables Matrix Size

population_child = zeros(popsize,dim);

for i=1:popsize
    x = population(i,:);
    indorder = randperm(popsize);
    indorder(indorder==i)=[];
    p1 = indorder(1); % population_parent 1
    p2 = indorder(2); % population_parent 2
    p3 = indorder(3); % population_parent 3
    
    %mutation
    beta = unifrnd(beta_min, beta_max, VarSize);
    y = population(p1,:)+beta.*(population(p2,:)-population(p3,:));
    y = max(y, 0);
    y = min(y, 1);
    
    %crossover
    z = zeros(size(x));
    j0 = randi([1 numel(x)]);
    for j = 1:numel(x)
        if j == j0 || rand <= pCR
            z(j) = y(j);
        else
            z(j) = x(j);
        end
    end
    
    child = z;
    population_child(i,:) = lb+child.*(ub-lb);
end