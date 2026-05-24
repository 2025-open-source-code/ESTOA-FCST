
function [label,membership] = Fuzzy_KNN(data, labels, test, para_K)
    
x = data;
y = labels;
n = size(test, 1);
% num表示有多少个类标签
num = max(labels);
 
for k = para_K
    % for k1 = 1 : 5
    for k1 = 3
        u = memberships_III(x, y, num, k1);
        test_y = zeros(n ,1);
        U = zeros(n ,num);
        for i = 1 : n
            % 在样本集中选择一个样本作为测试集，其他样本作为训练集
            test_x = test(i, :);
            [test_y(i, :),U(i, :)] = fknn(x, test_x, k, num, u);
        end
    end
end
label=test_y;
membership=max(U, [], 2);
end

function [test_y, U] = fknn(x, test_x, k, num, u)
% x:nxm,test_x:n0xm,test_y:n0x1,
% u:n*num,这个num代表类别,u->menbershiip,k代表最近邻k个
n0 = size(test_x, 1);
m = 2;
% 表示每个样本属于每个类的概率
U = zeros(n0, num);
for i = 1 : n0
    Dist = sum((x - test_x(i, :)).^2,2);
    % 从小大大排序，取前k个
    [D,I] = sort(Dist);
    D = D(1:k, :);
    % 防止除0
    D(D==0) = 0.00001;
    D = D.^(-1 / (m - 1));
    Sum_DIST = sum(D);
    for j = 1 : num
        Sum_MULT = sum(u(I(1:k), j) .* D);
        U(i, j) = Sum_MULT / Sum_DIST;
    end 
end
% 求U每行最大值以及对应的索引
[~, I] = max(U, [], 2);
test_y = I;
end


function u = memberships_III(x, y, num, k1)
% x:nxm,y:nx1,k1是一个常数,u:n*num,这个num代表类别
n = size(x, 1);
u = zeros(n, num);
for i = 1 : n
    ind = [1 : i - 1, i + 1 : n];
    Dist = sum((x(ind, :) - x(i, :)).^2,2);
    % 从小大大排序，取前k1个
    [~,I] = sort(Dist);
    D_y = y(I(1:k1), :);
    for j = 1 : num
        nj = sum(D_y == j);
        if y(i, :) == j
            u(i, j) = 0.51 + (nj / k1) * 0.49;
        else
            u(i, j) = (nj / k1) * 0.49;
        end    
    end
end
end

function u = memberships_II(x, y, num, ~)
n = size(x, 1);
u = zeros(n, num);
for i = 1 : n
    for j = 1 : num
        f=3.0;
        x_1=mean(x(y==1,:));
        x_2=mean(x(y==2,:));
        d1=norm(x(i,:)-x_1);
        d2=norm(x(i,:)-x_2);
        d=norm(x_1-x_2);
        if y(i, :) == 1
            u(i, 1) = 0.5+(exp(f*(d2-d1)/d)-exp(-f))/(2*(exp(f)-exp(-f)));
            u(i, 2) = 1-u(i, 1);
        else
            u(i, 2) = 0.5+(exp(f*(d1-d2)/d)-exp(-f))/(2*(exp(f)-exp(-f)));
            u(i, 1) = 1-u(i, 2); 
        end
        
    end
end
end

function u = memberships_I(x, y, num, ~)
n = size(x, 1);
u = zeros(n, num);
for i = 1 : n
    for j = 1 : num
        if y(i, :) == j
            u(i, j) = 1;
        else
            u(i, j) = 0;
        end
    end
end
end