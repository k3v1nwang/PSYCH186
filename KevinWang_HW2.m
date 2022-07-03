clear; 
close all; 

%%Part 1

%(a-c)generate random vectors f and g
disp("Problem 1")
f = makeRandVec(100,1);
g = makeRandVec(100,1);

%(d)compute the outer product (cross product) A
A = g * f';
g_out = A*f;

%(e)
disp("cosine angle between g and g':")
g_gp_cosine = findCos(g,g_out)
%dot(g,g_out);
g_out_length = norm(g_out);
disp("g' length:")
disp(g_out_length)


%%
%%Part 2
disp("Problem 2")
%(a) generate new normalized randon vector f'
f_prime = makeRandVec(100,1);

%(b)
disp("cosine angle between f and f'");
f_fp_cosine = findCos(f_prime,f)
f_fp_dot = dot(f_prime,f);

%(c)
Af_prime =( A * f_prime);
Af_prime_length = norm(Af_prime);
disp("Af' length: ")
disp(Af_prime_length)


%%
%%Part 3
disp("Problem 3")
%(a) generate many pairs of normalized random vectors, fi and gi
 
for d = [1,20,40,50,60,80,100]
    disp("Current dimensionality: ")
    disp(d);
    vals = 500;
    %(A) generate many pairs of normalized random vectors 
    f = makeRandVec(vals,d);
    g = makeRandVec(vals,d);
 
    A = zeros(vals,vals);
 
    nRuns = d;
 
    %(b) and (c) compute outer products and form connectivty matrix
    A = iterate(vals,nRuns,f,g);
 
    %(d) (i)
    g_prime = A * f;
 
    % %(ii) compare g' with orignal g
    disp("average cosine between g and g'");
    g_gp_cosine2 = mean(dot(g,g_prime)/norm(dot(g,g_prime)))
    g_gp_dot = norm(dot(g,g_prime))

    % %(iii) compute length of g'
    gp_len = norm(g_prime)
 
 
    % %(iv) selectivity 
    h = makeRandVec(vals,d);
    h_prime = zeros(vals,d);
    h_prime = A * h;
    hp_len = norm(h_prime);
    %det(corrcoef(h_prime,g))
    %g_avg_len = norm(mean(g))
    %h_prime_avg_len = norm(mean(h_prime))
 
    %when difference between average length is increasing, then the system
    %is increasingly more selective
    %selectivity is the distance from the average length of g and h' 
    %the system will lose selectivity as more vectors are stored 
    selectivity = norm(mean(g)) - norm(mean(h_prime))
    
%     figure('name',"avg g length");
%     histogram(mean(g));
%     figure('name',"avg h' length");
%     histogram(mean(h_prime));
    s = strcat(string(d),"-Pair selectivity");
    figure('name',s)
    histogram(mean(g)- mean(h_prime));
end

%%
%%Part 4 (e) Threshold
disp("Problem 4")
n = 100;
runs = 1;
d = 100;
input = makeRandVec(n,d);       %input vector
T = makeRandVec(n,d);           %target vector 
input_copy = input;
%calculate threshold 
cross_prod = input * T';
threshold = norm(mean(cross_prod))*1.5      

%t2 = mean(prctile(T,75))       %secondary threshold calculation (omiited)
x = find(input < threshold);
for i = x
    input(i) = 0;       %set values from input that did not reach threshold to 0
end

B = zeros(n,n);

for i = 1:runs
    input = input/norm(input);
    T = T/norm(T);
    B_it = input(:,i) * T(:,i)';
    B = B + B_it;
end
%see how many values were removed 
vals_removed = size(find(B == 0))
total =n*d;
pct_vals_remain = ((total)-(vals_removed(1)))/(total) %perecentage of values that were actually taken from the input to generate the output
%generally, the percentage remaning hovers around 75% by the threshold
%calculation

%calculate the output from intial input (using the copy)
C = iterate(n,1,input_copy,T);
pre_mod_output = C * input_copy;
pre_mod_len = norm(pre_mod_output)

%find the output after changing the input to meet threshold
output = B * input;
output_len = norm(output)

%average cosine angle between expected output and actual output after
%modification
angle = dot(output,pre_mod_output)/norm(dot(output,pre_mod_output));
avg_cos_angle = mean(angle)

%%
%%Helper Functions

%Formally generates matrix normalzing 2 passed in
%vectors and iterators through and summing the iterations to the output
%vector
function A = iterate(v,n,f,g)
    A = zeros(v,v);
    for i = 1:n
        f = f/norm(f);
        g = g/norm(g);
        A_it = g(:,i) * f(:,i)'; 
        A = A + A_it;
    end
end

%helper function to generate r by c number of random,normalized vectors
function randVec = makeRandVec(r,c)
    vals = rand(r,c);
    rawVec = vals - 0.5;
    randVec = rawVec/norm(rawVec);
end

%helper function that returns the cosine angle between two normalized
%vectors
function cos_angle = findCos(v1,v2)
    cos_angle = dot(v1,v2)/norm(dot(v1,v2));
    if cos_angle == 1
        disp("The two vectors are orthogonal and pointing in the same direction");
    else
        disp(cos_angle);
    end
end