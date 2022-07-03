clear all;
close all; 
clc;

%global constants
 
dim= 80;
half = 40;
upper_limit = 50;
lower_limit = 0;
num_iter = 50;

%initializing initial state for fig 4.19-4.23
initial_state_vec = zeros(dim,1);

initial_state_vec(1:20) = 10;
initial_state_vec(21:60) = 40;
initial_state_vec(61:80) = 10;

state_vec = initial_state_vec;

first = makeFirst(state_vec);
sec = makeSec(state_vec);
new_vec = zeros(dim,1);
%%
%%Figure 4.19 max = 0.1, length = 2.0
A = generateA(0.1,2.0,initial_state_vec);
ep = 0.5;
% for i = 1:num_iter
%     for j = 1:dim
%         new_vec(j) = state_vec(j) + ep *(initial_state_vec(j) + dot(A(:,j),state_vec) - state_vec(j));
%     end
%     limit_state_vec(new_vec);
%     if i == num_iter
%         dist = norm(new_vec(i)) - norm(new_vec(i-1));
%         disp(dist);
%         state_vec = new_vec;
%     end
% end

 compute(A,initial_state_vec,ep,'4.19');

%%
%%Figure 4.20 max = 0.2, length = 2.0
B = generateA(0.2,2.0,initial_state_vec);
ep = 0.5;
compute(B,initial_state_vec,ep,'4.20');

%%
%%Figure 4.21 max = 0.5, length = 2.0 
C = generateA(0.5,2.0,initial_state_vec);
ep = 0.33;
compute(C,initial_state_vec,ep,'4.21');


%%
%%Figure 4.22 max = 1.0, length = 2.0
D = generateA(1.0,2.0,initial_state_vec);
ep = 0.2;
compute(D, initial_state_vec,ep,'4.22');

%%
%%Figure 4.23 max = 2.0, length = 2.0
E = generateA(2.0,2.0,initial_state_vec);
ep = 0.1175;
compute(E,initial_state_vec,ep,'4.23');

%%
%%Winner Take All
%%
%%Figure 2.26  max= 1.0, length = 10.0
initial_WTA = zeros(dim,1);

initial_WTA(16) = 10;
initial_WTA(24) = 10;
initial_WTA(17) = 20;
initial_WTA(23) = 20;
initial_WTA(18) = 30;
initial_WTA(22) = 30;
initial_WTA(19) = 40;
initial_WTA(21) = 40;
initial_WTA(20) = 50;


WA = generateA(1.0,10.0,initial_WTA);
new = zeros(dim,1);
state = initial_WTA;

[peak,index] = maxk(initial_WTA,3);
for i = 1:length(initial_WTA)
    if i == index(2) || i == index(3)   %neurons next to peak get halved
        state(i) = state(i)/2;
    end
    if i ~= index
        state(i)= 0;        %anywhere else that is not within peak indexes are surpressed
    end
end


for i = 1:num_iter 
    for j = 1:dim    
        if j == index(1)     %change step size for peak index  
            ep = 0.05;
            new(j) = state(j) + ep*(initial_WTA(j) + dot(WA(:,j),state) - state(j));
        else
            ep = 0.3;
            new(j) = state(j) + ep*(initial_WTA(j) + dot(WA(:,j),state) - state(j));
        end
    end
    new = limit_state_vec(new);
    if i == num_iter
            state = new;
            makeGraph(initial_WTA,state,'4.26');
        break
    end
end

%%
% %%Figure 2.27   max = 1.0, length = 10.00
initial_WTA(1:16) = 10;
initial_WTA(24:80) = 10;

WA = generateWTA(1.0,10.0,initial_WTA);
new = zeros(dim,1);
state = initial_WTA;

[peak,index] = maxk(initial_WTA,3);
for i = 1:length(initial_WTA)
    if i == index(2) || i == index(3)   %neurons next to peak get halved
        state(i) = state(i)/2;
    end
    if i ~= index
        state(i)= 0;        %anywhere else that is not within peak indexes are surpressed
    end
end

for i = 1:num_iter 
    for j = 1:dim    
        if j == index(1)     %change step size for peak index  
            ep = 0.1;
            new(j) = state(j) + ep*(initial_WTA(j) + dot(WA(:,j),state) - state(j));
        else
            ep = 0.75;
            new(j) = state(j) + ep*(initial_WTA(j) + dot(WA(:,j),state) - state(j));
        end
    end
    new = limit_state_vec(new);
    if i == num_iter
            state = new;
            makeGraph(initial_WTA,state,'4.27');
        break
    end
end
%%
%%Figure 4.28 max = 1.0 length = 10.0 
initial_WTA(17) = 10;
initial_WTA(18) = 10;
initial_WTA(14) = 20;
initial_WTA(16) = 20;
initial_WTA(19) = 20;
initial_WTA(23) = 20;
initial_WTA(15) = 30;
initial_WTA(20) = 30;
initial_WTA(22) = 30;
initial_WTA(21) = 40;
WA = generateWTA(1.0,10.0,initial_WTA);
new = zeros(dim,1);
state = initial_WTA;

[peak,index] = maxk(initial_WTA,2);
for i = 1:length(initial_WTA)
    if i ~= index
        state(i)= 0;        %anywhere else that is not within peak indexes are surpressed
    end
end

for i = 1:num_iter 
    for j = 1:dim    
        if j == index(1)     %change step size for peak index  
            ep = 0.5;
            new(j) = state(j) + ep*(initial_WTA(j) + dot(WA(:,j),state) - state(j));
        else
            ep = 0.75;
            new(j) = state(j) + ep*(initial_WTA(j) + dot(WA(:,j),state) - state(j));
        end
    end
    new = limit_state_vec(new);
    if i == num_iter
            state = new;
            makeGraph(initial_WTA,state,'4.28');
        break
    end
end


%%
%%Figure 4.29  max = 2.0   length = 10.0 
WA = generateWTA(2.0,10.0,initial_WTA);
new = zeros(dim,1);
state = initial_WTA;

[peak,index] = maxk(initial_WTA,2);
for i = 1:length(initial_WTA)
    if i ~= index
        state(i)= 0;        %anywhere else that is not within peak indexes are surpressed
    end
end

for i = 1:num_iter 
    for j = 1:dim    
        if j == index(1)     %change step size for peak index  
            ep = .2;
            new(j) = state(j) + ep*(initial_WTA(j) + dot(WA(:,j),state) - state(j));
        else
            ep = 0.75;
            new(j) = state(j) + ep*(initial_WTA(j) + dot(WA(:,j),state) - state(j));
        end
    end
    new = limit_state_vec(new);
    if i == num_iter
            state = new;
            makeGraph(initial_WTA,state,'4.29');
        break
    end
end


%%
%%Helper functions

function compute(A,initial,ep,figName)
num_iter = 50;
dim = 80;
half = 40;
state = initial;
new = zeros(dim,1);
    for i = 1:num_iter
        for j = 1:half
            new(j) = state(j) + ep*(initial(j) + dot(A(:,j),state) - state(j));
        end
        for j = half+1:dim
            new(j) = state(j) + ep*(initial(j) + dot(A(:,j),state) - state(j));
        end
         new = limit_state_vec(new);        %limit test
        if i == num_iter
            dist = norm(new(i)) - norm(new(i-1));
            disp(dist);     %convergence test
            state = new;
            makeGraph(initial,state,figName);
            break;
        end
    end

end

function first_half = makeFirst(state_vec)
    half = 40;
%     first_half = zeros(half-1,1);
    first_half(1:half-1) = state_vec(2:half);
end

function sec_half = makeSec(state_vec)
    half = 40;
    sec_half(1:half) = state_vec(half+1:80);
end

function v2 = limit_state_vec(vec)
    v2 = vec;
    for i = 1:length(vec)
        if vec(i) < 0
            v2(i) = 0;
            disp(strcat("less than 0 at: ", num2str(i)));
        end
        if vec(i) > 50
            v2(i) = 50;
            disp(strcat("greater than 50 at: ", num2str(i)));
        end
    end
end


function A = generateWTA(max_strength,length_constant,input)
    len = length(input);
    A = zeros(len,len);
    for i = 1:len
        for j = 1:len
            if i == j
                A(i,j) = 0;
            else
                A(i,j) = -max_strength * exp((-abs(j-i))/length_constant);
            end
        end
    end
end

function A = generateA(max_strength,length_constant,input)
    len = length(input);
    A = zeros(len,len);
    for i = 1:len
        for j = 1:len
            A(i,j) = -max_strength * exp((-abs(j-i))/length_constant);
        end
    end
end

function makeGraph(initial, state,figName)
    x = 12:1:30;     %x axis is 1-19 seperated by 1 (for the spots 12:30)
    y1 = initial(12:30);
    y2 = state(12:30);
    figure('name',figName);
    plot(x,y1,'+',x,y2,'*');
    ylim([0 55])
end