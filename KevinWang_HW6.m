clear all;
close all;
clc;

%parameters
eta= 1;

% set up pattern tha tnetwork will be trained on
A = randi([0,1],[8,8])
disp("================================================================================")

% determine desired output for each pattern
t = zeros(1,8);
for i = 1:8
    r = sum(A(:,i) ==1);
    even = mod(r,2) == 0;
    if even
        t(i) = 1;
    else
        t(i) = 0;
    end
end

disp("Desired Output: ")
disp(t)
disp("Note: the input pattern is a column of the A matrix")
disp("================================================================================")

% create weights that connect the layers
disp("Weighted Connections")

w_fg = rand(3,8) - 0.5
w_gh = rand(1,3) - 0.5

epoch = 0;
max = 1000; 
check = false;
e = zeros(1,8);
stored_sse = zeros(1,max);
stored_cos = zeros(1,max);
disp("================================================================================")

%loop until epoch > 1000 or sse < 0.01
disp("Begin Training" + newline)
while check == false 
    
    if epoch >= max
        check = true;
    end
    
    for i = 1:8
        f = A(:,i);
        % a) pass activation from input units to hidden units
        input_to_hidden = w_fg *f;
        
        % b) determine hidden unit activation 
        g = activation_fn(input_to_hidden);
        
        % c) pass activation from hidden units to output units
        input_to_output = w_gh * g;
        
        % d) determine output activing
        h = activation_fn(input_to_output);
        
        % e) compute output error
        e(i) = t(i)-h;
        
        % f) deterine weight chage dw for each layer
        dw_fg = eta * diag(derive(g)) * w_gh' * diag(e(i)) * derive(h) * f';
        dw_gh = eta * diag(derive(h))* e(i) * g';
        
        % g) apply weight changes
        w_fg = w_fg + dw_fg;
        w_gh = w_gh + dw_gh;
    end
    
    % h) repeat a-e with all input patterns at once
    input_to_hidden = w_fg * A;
    g = activation_fn(input_to_hidden);
    input_to_output = w_gh *g;
    h = activation_fn(input_to_output);
    error = t - h;
    
    sse = trace(e' * error);

    if sse <0.01
        check = true;
    end
    
    epoch = epoch +1;
    
    stored_sse(epoch) = sse;
    stored_cos(epoch) = findCos(t,h);
    if mod(epoch,10) == 0
        s1 = strcat("Epoch: ", num2str(epoch));
        s2 = strcat("    SSE: ", num2str(sse));
        disp( strcat(s1,s2));
        disp(" ");
    end
    
end
stored_sse = nonzeros(stored_sse);

if epoch > max
    disp("The model did not converge")
else
    disp(strcat("Converged on Epoch #",num2str(epoch)))
    disp(strcat("SSE: ", num2str(sse)))
    figure('name', "Desired Output and Computed Output")
    subplot(1,2,1)
    imagesc(t);
    subplot(1,2,2)
    imagesc(h);
    figure('name',"SSE per Epoch")
    plot(stored_sse)
    xlabel("Epoch");
    ylabel("SSE");
    
%     stored_cos = nonzeros(stored_cos);
%     figure('name',"Cosine angle between desired and computed")
%     plot(stored_cos)

    disp("================================================================================")
    disp("Testing on New Patterns" + newline)

    B = randi([0,1],[8,8]);

    t2 = zeros(1,8);
    for i = 1:8
        r = sum(B(:,i) ==1);
        even = mod(r,2) == 0;
        if even
            t2(i) = 1;
        else
            t2(i) = 0;
        end
    end
%     disp("Desired Output on New Pattern: ")
%     disp(t2)
    epoch2 = 0;
    e2 = zeros(1,8);
    max = 1000;
    stored_sse2 = zeros(1,max);
    stored_diff = zeros(1,max);

    converge_count = 0;
    while epoch2 < max
        for i = 1:8
            f2 = B(:,i);
            % a) pass activation from input units to hidden units
            input_to_hidden = w_fg *f2;

            % b) determine hidden unit activation 
            g2 = activation_fn(input_to_hidden);

            % c) pass activation from hidden units to output units
            input_to_output = w_gh * g2;

            % d) determine output activing
            h2 = activation_fn(input_to_output);

            % e) compute output error
            e2(i) = t2(i)-h2;
            
%             % f) deterine weight chage dw for each layer
%             dw_fg2 = eta * diag(derive(g2)) * w_gh' * diag(e2(i)) * derive(h2) * f2';
%             dw_gh2 = eta * diag(derive(h2))* e2(i) * g2';
%             % g) apply weight changes
%             w_fg = w_fg + dw_fg2;
%             w_gh = w_gh + dw_gh2;
        end
        
        epoch2 = epoch2 +1; 
        
        %steps a-e for all patterns
        input_to_hidden = w_fg * B;
        g2 = activation_fn(input_to_hidden);
        input_to_output = w_gh *g2;
        h2 = activation_fn(input_to_output);
        error2 = t2 - h2;
        sse2 = trace(e2' * error2);
        
        stored_sse2(epoch2) = sse2;
        stored_diff(epoch2) = findCos(h2,h);
        if sse2< 0.01
            converge_count = converge_count + 1;
        end
        
        B = randi([0,1],[8,8]);     %create a new set of patterns after running through one

        if mod(epoch2,100) == 0
            s1 = strcat("Trial: ", num2str(epoch2));
            s2 = strcat("    current SSE average: ", num2str(mean(sse2)));
            disp( strcat(s1,s2));
            disp(" ");
        end 
        
        
    end
    disp("Results after running " + num2str(max) + " new patterns: ")
    avg_sse = mean(stored_sse2)
    avg_sd = std(stored_sse)
    avg_cos = mean(stored_diff)
    converge_count
    
    pct_on_convergence = converge_count/max
    
%     figure('name', "Desired Output2 and Computed Output2")
%     subplot(1,2,1)
%     imagesc(t2);
%     subplot(1,2,2)
%     imagesc(h2);
%     
    stored_sse2 = nonzeros(stored_sse2);
    stored_diff = nonzeros(stored_diff);
    
%     figure('name',"SSE per Epoch")
%     
%     plot(stored_sse2);
%     xlabel("Epoch");
%     ylabel("SSE");
%     
%     figure('name',"cos angle")
%     plot(stored_diff)
%     xlabel("Epoch");
%     ylabel("Cos Angle");
    
    
end

%%
%%Helper Functions

%activation funciton (sigmoid funciton)
function f = activation_fn(x)
    f = 1./(1+exp(-x));
end

%derivative of sigmoid function
function f = derive(A)
    f = A .* (1 - A);

end
