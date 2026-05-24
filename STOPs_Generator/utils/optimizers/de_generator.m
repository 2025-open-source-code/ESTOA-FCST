function population_child = de_generator(population_parent,lb,ub)
[popsize,dim] = size(population_parent);
population = (population_parent-repmat(lb,popsize,1))./(repmat(ub,popsize,1)-repmat(lb,popsize,1));
CR = 1;     % index of Simulated Binary Crossover (tunable)
F=0.5;
mum = 15;    % index of polynomial mutation
probswap = 0.5; % probability of variable swap
population_child = zeros(popsize,dim);
indorder_all = randperm(popsize);

for i=1:popsize/2
    p1 = indorder_all(i); % population_parent 1
    indorder = randperm(popsize);
    indorder(indorder==i)=[];
    p2 = indorder(1); % population_parent 2
    p3 = indorder(2); % population_parent 3
    child1 = population(p1,:);
    Site = rand(1,dim) < CR;
    child1(Site) = child1(Site)+F*(population(p2,Site)-population(p3,Site));
    child1(child1<0) = 0;
    child1(child1>1) = 1;
    
    p1 = indorder_all(i+(popsize/2)); % population_parent 2
    indorder = randperm(popsize);
    indorder(indorder==i)=[];
    p2 = indorder(2); % population_parent 2
    p3 = indorder(3); % population_parent 3
    child2 = population(p1,:);
    Site = rand(1,dim) < CR;
    child2(Site) = child2(Site)+F*(population(p2,Site)-population(p3,Site));
    child2(child2<0) = 0;
    child2(child2>1) = 1;
    
    % mutation
    temp1 = child1;
    for j=1:dim
        if rand(1)<1/dim
            u=rand(1);
            if u <= 0.5
                del=(2*u)^(1/(1+mum)) - 1;
                temp1(j)=child1(j) + del*(child1(j));
            else
                del= 1 - (2*(1-u))^(1/(1+mum));
                temp1(j)=child1(j) + del*(1-child1(j));
            end
        end
    end

    child1 = temp1;
    child1(child1<0) = 0;
    child1(child1>1) = 1;
    temp2 = child2;
    for j=1:dim
        if rand(1)<1/dim
            u=rand(1);
            if u <= 0.5
                del=(2*u)^(1/(1+mum)) - 1;
                temp2(j)=child2(j) + del*(child2(j));
            else
                del= 1 - (2*(1-u))^(1/(1+mum));
                temp2(j)=child2(j) + del*(1-child2(j));
            end
        end
    end
    child2 = temp2;
    child2(child2<0) = 0;
    child2(child2>1) = 1;
    
    % variable swap (uniform X)
    swap_indicator = (rand(1,dim) >= probswap);
    temp = child2(swap_indicator);
    child2(swap_indicator) = child1(swap_indicator);
    child1(swap_indicator) = temp;
    
    population_child(i,:) = lb+child1.*(ub-lb);
    population_child(i+popsize/2,:) = lb+child2.*(ub-lb);
end