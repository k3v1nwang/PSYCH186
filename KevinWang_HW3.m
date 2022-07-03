close all
clear all
clc
disp("Output for Oscillations and Convergence");
for pairs = [20,40,60,80]
    
    %default values
    dim = 100; 
    max_iter = 150000;
    ep = 1/1000;
    
    for k = [1-ep,0.1,-1]       

        %generate f, g, and h hectors (cenetered and normalized) 
        f_set = genRandVec(dim,pairs);
        g_set = genRandVec(dim,pairs);
        h_set = genRandVec(dim,pairs);
        
        %collection 
        mean_error = zeros(1,max_iter);
        len_g = zeros(1,max_iter);
        len_gp = zeros(1,max_iter);

        %generate A 
        A = g_set * f_set.';
        
        count = 0;

        for i = 1:max_iter

            count = count +1;
            j = randi(pairs);
            f = f_set(:,j);

            g = g_set(:,j);     %target
            gp = A * f;         %computed

            
            len_g(i) = norm(g);
            len_gp(i) = norm(gp);


            error = (g-gp);         %error =  target - computed
            
            if k == -1
                k = (1/(f'*f)-ep)/i;    %changing k w/ iterations    
            end
            
            %gradient descent
            dA = delt(k,error,f);
            if dA < 0
                A = A - dA;
            else
                A = A + dA;
            end

            %calculate mean squared error 
            mean_error(i) = mean(norm(error))^2;

            %stopping condition 
            if i ==1
                continue
            else
                p = abs(mean_error(i)-mean_error(i-1)/mean_error(i));       % percentage increase from last error
                if  p < 0.01
                    cos_angle = findCos(g,gp);
                    if cos_angle > 0.99               %continue until the target and computed are almost the orthogonal
                        s = strcat("K= ", string(k)," & ");
                        ps = strcat(string(pairs)," Pairs of associations");
                        s = strcat(s,ps);
                        v = nonzeros(mean_error);
                        figure('name',s);
                        plot(v);
                        disp(strcat(s," | Iterations until convergence: ", string(count)));
                        disp(strcat("    p-value = " , num2str(p)));
                        disp(strcat("cosine between target and computed: ", num2str(cos_angle)))
                        disp(" ")
                        break;
                    else
                        continue;
                    end
                end
            end
        end
    end
end

disp("If there are less than 12 figures that are generated, please run the script again or increase # max_iter");
disp(" ")

% figure('name','len g')
% a = nonzeros(len_g);
% plot(a)
% figure('name','len gp')
% b = nonzeros(len_gp);
% plot(b)
% figure('name','mean error')
% c = nonzeros(mean_error);
% plot(c)

disp("Running simulation on Deterioration (c) ")
numRuns = 40;           %change this variable to change # of times the intial pair increments
input1_score = 0;
input2_score = 0;
for q = 1:numRuns
    dim = 100;
    if q == 1
        pairs = 70;     %set intial # of associations
    else 
        pairs = new;
    end
    ep = 1/1000;
    k = 1-ep;
    max_iter = 10000;
        %generate f, g, and h hectors (cenetered and normalized) 
    f_set = genRandVec(dim,pairs);
    g_set = genRandVec(dim,pairs);
    h_set = genRandVec(dim,pairs);

    %collection 
    mean_error = zeros(1,max_iter);
    mean_error2 = zeros(1,max_iter);
    len_g = zeros(1,max_iter);
    len_gp = zeros(1,max_iter);
    len_hp = zeros(1,max_iter);
   
    %generate A 
    A = g_set * f_set.';
    B = A;      %secondary B for comparison 

    count = 0;
    
    for i = 1:max_iter 
        
        j = randi(pairs);
        f = f_set(:,j);     %input
        h = h_set(:,j);     %input 2
        
        g = g_set(:,j);     %target
        
        gp = A * f;         %output
        hp = A * h;         %secondary output
        
        len_g(i) = norm(g);
        len_gp(i) = norm(gp);
        len_hp(i) = norm(hp);
        
        avg_hp = mean(len_hp);
        avg_gp = mean(len_gp);
        avg_g = mean(len_g);

        error = (g-gp);         %error =  target - computed      
        error2 = (h-gp);
        
        dA = delt(k,error,f);
        if dA < 0
            A = A - dA;
        else
            A = A + dA;
        end
        
        %calculate mean squared error 
        mean_error(i) = mean(norm(error))^2;
        mean_error2(i) = mean(norm(error))^2;
        %stopping condition 
        if i ==1
            continue
        else
            p = abs(mean_error(i)-mean_error(i-1)/mean_error(i));       % percentage increase from last error
            cos_angle = findCos(g,gp);
            if  p < 0.01 && cos_angle > 0.99
%                 diff = abs(avg_g - avg_gp);
%                 diff2 = abs(avg_g - avg_hp);
                diff = (mean(mean_error));
                diff2 = (mean(mean_error2));
                if(diff2 < diff)
                    input2_score = input2_score +1;
                else
                    input1_score = input1_score +1;
                end
                if(input1_score <= input2_score)
                    disp(strcat("Input1 was no better than input2 at  ",num2str(pairs), " associations"))
                    disp("input1 (f) score ");
                    disp(input1_score);
                    disp("input2 (h) score");
                    disp(input2_score);
                    disp(" ");
                    break;
                else
                    disp(strcat("input1 was better at ", num2str(pairs), " associations"))
                    input1_score = 0;       %reset the score
                    new = pairs +1;
                    break;
                end
            end
        end
       %new = pairs +1;
    end
end
disp(" ")
disp(strcat("The system deterioated at about ",num2str(pairs), " associations"))
disp("If there is no output for deterioration, due to random chance input 1 was never better, please change the starting conditions or run the sim again");
disp(" ")

disp("Sequential Learning");
disp("Forward")
for pairs = [20,40,60,80]
    disp(strcat("Pairs: ", num2str(pairs)))
    %default values
    dim = 100; 
    max_iter = 1000;
    ep = 1/1000;
    %generate f, g, and h hectors (cenetered and normalized) 
    f_set = genRandVec(dim,pairs);
    g_set = genRandVec(dim,pairs);

    %collection 
    mean_error = zeros(1,max_iter);
    len_g = zeros(1,max_iter);
    len_gp = zeros(1,max_iter);

    %generate A 
    A = g_set * f_set.';
    for i = 1:max_iter
        for j = 1:pairs

            f = f_set(:,j);
            g = g_set(:,j);     %target
            gp = A * f;         %computed

            len_g(i) = norm(g);
            len_gp(i) = norm(gp);

            error = (g-gp);         %error =  target - computed
            k = 1-ep;   %(1/(f'*f)-ep)/i;
            %gradient descent
            dA = delt(k,error,f);
            if dA < 0
                A = A - dA;
            else
                A = A + dA;
            end


            %calculate mean squared error 
            mean_error(i) = mean(norm(error))^2;
        end
                %stopping condition 
        if i ==1
            continue
        else
            p = abs(mean_error(i)-mean_error(i-1)/mean_error(i));      % percentage increase from last error
            cos_angle = findCos(g,gp);
            q = abs(mean_error(i));
            if  q < 0.01 && cos_angle >0.99
                           %continue until the target and computed are almost the orthogonal
                s = strcat("Forwards: ","K= ", string(k)," & ");
                ps = strcat(string(pairs)," Pairs of associations");
                s = strcat(s,ps);
                v = nonzeros(mean_error);
                figure('name',s);
                plot(v);
                disp(strcat(s," | Iterations until convergence: ", string(i)));
                disp(strcat("    p-value = " , num2str(p)));
                disp(strcat("cosine between target and computed: ", num2str(cos_angle)))
                disp(" ")
                break;
            else
                continue;
            end
            
        end
    end
end

disp(" ")
disp("Backwards")
for pairs = [20,40,60,80]
    disp(strcat("Pairs: ", num2str(pairs)))
    %default values
    dim = 100; 
    max_iter = 2000;
    ep = 1/1000;
    %generate f, g, and h hectors (cenetered and normalized) 
    f_set = genRandVec(dim,pairs);
    g_set = genRandVec(dim,pairs);

    %collection 
    mean_error = zeros(1,max_iter);
    len_g = zeros(1,max_iter);
    len_gp = zeros(1,max_iter);

    %generate A 
    A = g_set * f_set.';
    for i = 1:max_iter
        for j = pairs:-1:2

            f = f_set(:,j);
            g = g_set(:,j);     %target
            gp = A * f;         %computed

            len_g(i) = norm(g);
            len_gp(i) = norm(gp);

            error = (g-gp);         %error =  target - computed
            k = (1/(f'*f)-ep)/i;
            %gradient descent
            dA = delt(k,error,f);
            if dA < 0
                A = A - dA;
            else
                A = A + dA;
            end


            %calculate mean squared error 
            mean_error(i) = mean(norm(error))^2;
        end
                %stopping condition 
        if j ==pairs
            continue
        else
            p = abs(mean_error(j)-mean_error(j+1)/mean_error(j));      % percentage increase from last error
            cos_angle = findCos(g,gp);
            q = abs(mean_error(i));
            if  q < 0.01 && cos_angle >0.99
                           %continue until the target and computed are almost the orthogonal
                s = strcat("Backwards ", "K= ", string(k)," & ");
                ps = strcat(string(pairs)," Pairs of associations");
                s = strcat(s,ps);
                v = nonzeros(mean_error);
                figure('name',s);
                plot(v);
                disp(strcat(s," | Iterations until convergence: ", string(i)));
                disp(strcat("    p-value = " , num2str(p)));
                disp(strcat("cosine between target and computed: ", num2str(cos_angle)))
                disp(" ")
                break;
            else
                continue;
            end
            
        end
    end
end

disp("It appears that when the simulation is run non-randomly, it is faster for 20 and 40 pairs but slower for 60 and 80 pairs");
disp("Sometimes,the 60 and 80 pair associations do never converge to a mean squared error of < 0.01")

disp("I was only able to get the 80 pair association to work a handful of times when the sequantial learning was backwards")
disp("The total number of figures produced on average should be 12 from parts a and b, and 8 from part d, for a total of 20 figures (on average)");

%%
%%helper funcitons

function randVec = genRandVec(dim,pair)
    vec = rand(dim,pair) -.5;
    randVec = vec/norm(vec);
end

%delta A calculation
function da = delt(k,e,f)
    da = k * e * f';
end

function cos =findCos(v1,v2) 
    cos= dot(v1,v2)/(norm(v1)*norm(v2));
end

