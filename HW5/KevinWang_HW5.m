clear all;
close all;
clc;

%read in data file
data = readtable('training_data.csv', 'PreserveVariableNames', true);

%%
%% Encode Categorical Data

%Planet
k = unique(data.Planet);
temp_var = [];
var = data.Planet;

for i = 1:length(k)
    temp_var(:,i) = double(ismember(var,k(i)));
end

k = cellstr(k);

pl = array2table(temp_var, 'VariableNames',k);

data = [data pl];           %add planet to collection

%Color
k = unique(data.Color);
temp_var = [];
var = data.Color;

for i = 1:length(k)
    temp_var(:,i) = double(ismember(var,k(i)));
end

k = cellstr(k);

cl = array2table(temp_var, 'VariableNames',k);

data = [data cl];       %add color to collection

%Required action 
k = unique(data.Action);
temp_var = [];
var = data.Action;

for i = 1:length(k)
    temp_var(:,i) = double(ismember(var,k(i)));
end

k = cellstr(k);

at = array2table(temp_var, 'VariableNames',k);

data = [data at]       %add action to collection 


%Convert Names from Cell to String to Numerical value 

% Antarean names have numerical number following a vowel
% Federation names always have a vowel for their second character
% Romulan names also always have a vowel for second char, differentiate the
% two by their murds,ratio,gigahz

%create a vector representation the pattern of consonants, vowels, or
%numbers
% C = -1
% V = 1
% N = 0

names = string(data.Name);      %now the names are in string format
charAt = @(names,ind)names(ind);

all_names = zeros(20,8);

for i = 1:20
    for j = 1:length(names(i))
        s = charAt(names(i),j);
        c = char(s);
        c = lower(c);
        all_names(i,:) =2;      %placeholder value
        for x = 1:length(c)
           digit = isstrprop(c,'digit');
           letter = isstrprop(c,'alpha');
           name_vec = zeros(length(c),1);
        end
        for x = 1:length(c)
           if letter(x) == 1
               if c(x) == "a" || c(x) == "e" || c(x) == "i" || c(x) == "o" || c(x) == "u"
                   name_vec(x) = 1;     %char is vowel
               else
                   name_vec(x) = -1;     %char is consonant
               end
           else
               name_vec(x) = 0;        %char is number
           end
           for y = 1:length(name_vec)
               all_names(i,y) = name_vec(y);
           end
        end
    end
end

%add NameCode to data
% data.NameCode = rand(20,1);
for i = 1:20
    m = getNameCode(all_names,i);
end
% q = getNameCode(all_names,1)
%%
%%Import Noisy Data

noise = readtable('noisy_data.csv','PreserveVariableNames', true)       %initial state

%%
%%Find Origin Stats
Klingon = data(:,{'Klingon','Murds','GigaHz','Ratio','ColorC'});
Klingon = Klingon(1:4,:)
avgKM = mean(Klingon.Murds);
avgKHz = mean(Klingon.GigaHz);
avgKR = mean(Klingon.Ratio);

Romulan = data(:,{'Romulan','Murds','GigaHz','Ratio','ColorC'});
Romulan = Romulan(6:10,:)
avgRM = mean(Romulan.Murds);
avgRHz = mean(Romulan.GigaHz);
avgRR = mean(Romulan.Ratio);

Antarean = data(:,{'Antarean','Murds','GigaHz','Ratio','ColorC'});
Antarean = Antarean(11:15,:)
avgAM = mean(Antarean.Murds);
avgAHz = mean(Antarean.GigaHz);
avgAR = mean(Antarean.Ratio);

Federation = data(:,{'Federation','Murds','GigaHz','Ratio','ColorC'});
Federation = Federation(16:20,:)
avgFM = mean(Federation.Murds);
avgFHz = mean(Federation.GigaHz);
avgFR = mean(Federation.Ratio);

%%
%%Generate Scores & Predict Results
trials = 0;
 for iter = 1:20          %use iter = 1:20 to run all the data , use iter = __ for specific noisy data calculation
     trials = trials +1;
    nameMatchScores = zeros(20,1);
    murdsScore = zeros(20,1);
    ratioScore = zeros(20,1);
    colorMatchScores = zeros(20,1);
    gigaScore = zeros(20,1);
    composite = zeros(20,1);
    in =0;    
    for i = iter
        in = in+1;
        n = noise(iter,{'Name','Murds','GigaHz','Ratio','ColorC'})
        N = genNameCode(string(n.Name));
        M = n.Murds;
        R = n.Ratio;
        C = n.ColorC;
        G = n.GigaHz;
        colorMatch = 1;
        %How close the name and color matches
        for r = 1:20
             T = data(r,{'Name','Planet','GigaHz','ColorC','Murds','Ratio'});   
            %use how close the name code matches to amplify the results for the
            %other categories (if they match up to 3 spots, the error is reduced by 3 times)
            matchCount =1;      %start at 1 so we don't divide by 0
            T_n = getNameCode(all_names,r);
            for x = 1:length(N)
                if N(x) == T_n(x)
                    matchCount = matchCount +1;
                else
                    break;
                end
                if x > 3
                    break;         %first 3 character is sufficient
                end
            end
            nameMatchScores(r,in) = matchCount;
            if C == T.ColorC
                colorMatchScores(r,in) = colorMatch +1;     %color match
            end
        end

            %Error Correction
        for row = 1:length(nameMatchScores)
            epsilon = nameMatchScores(row,in) + colorMatchScores(row,in);
            T = data(row,{'Name','Planet','GigaHz','ColorC','Murds','Ratio'});
%             murdsScore(row,in) = ((M-T.Murds)/epsilon)^2;      %highest scores have highest error reduction
%             ratioScore(row,in) = ((R - T.Ratio)/epsilon)^2;
%             gigaScore(row,in) = ((G-T.GigaHz)/epsilon)^2;
            murdsScore(row,in) = ((M-T.Murds)/epsilon)^2;      %highest scores have highest error reduction
            ratioScore(row,in) = ((R - T.Ratio)/epsilon)^2;
            gigaScore(row,in) = ((G-T.GigaHz)/epsilon)^2;            
        end

        %deal with missing values and total the errors
        for q = 1:20
            x = ratioScore(q);
            ratio = ~isnan(x);
            y = murdsScore(q);
            murds = ~isnan(y);
            z = gigaScore(q);
            gigs = ~isnan(z);
            if ratio == 0
                ratioScore(q) = 0;
            end
            if murds == 0
                murdsScore(q) = 0;            
            end
            if gigs == 0
                gigaScore(q) = 0;
            end

            if gigs == 0 && ratio == 0 && murds ==0     %in the event that no numerical values are present
                composite(q) = 0 -  nameMatchScores(q);
            else
                composite(q,in) = ratioScore(q,in) + murdsScore(q,in) + gigaScore(q,in);
            end
        end


        %calculate error per cluster 
        pKlingon = mean(composite(1:4)); %leave out 5 because Glorek used to be Antarean
        pRomulan = mean(composite(6:10));
        pAntarean = mean(composite(11:15));
        pFederation = mean(composite(16:20));
%         Origin=      which(pKlingon,pRomulan,pAntarean,pFederation); 
%         noise.Planet(i) =   cellstr(Origin);      <- taken out becuase it
%         wasn't as accurate, but gets #11 ship to be a Klingon Fleet
%         instead of Federation 
%
%         ^^ function is not used to calculate results, only to see group
%         values, 

        %Go to the row of the training data set that is associated with the
        %minimum error 
        mm = min(composite(:,in));
        ansI = find(composite == mm);
        T = data(ansI(1),{'Name','Planet','GigaHz','ColorC','Murds','Ratio','Action'});
        Origin = T.Planet;
        disp("Predicted Planet of Origin: ")
        disp(Origin)
        noise.Planet(i) = Origin;
        Req = T.Action;
        disp("Predicted Action Required: ")
        disp(Req);
        noise.Action(i) = Req;

    end
 end

 disp("After classification: ")
 disp(noise)
disp(trials)
 
%%
%%Helper functions
function row = getNameCode(all_names,index)

    n = all_names(index,:);
    row = n(find(n~=2));
    %row = num2str(row);
end

function winner = which(pK,pR,pA,pF)
    %want to find closest to zero 
    set = [pK pR pA pF];
    closest = min(set);
    
    if closest == pK
        winner = 'Klingon';
    end
    if closest == pR
        winner = 'Romulan';
    end    
    if closest == pA
        winner = 'Antarean';
    end    
    if closest == pF
        winner = 'Federation';
    end

end


function nameCode = genNameCode(name)
    names = string(name);      %now the names are in string format
    charAt = @(names,ind)names(ind);

    sz = strlength(name);
    nameCode = zeros(1,sz);
    
    for i = 1:sz
        s = charAt(char(name),i);
        c = lower(char(s));
        for j = 1:length(c)
            digit = isstrprop(c,'digit');
            letter = isstrprop(c,'alpha');
            vec = zeros(length(c),1);
        end
        for x = 1:length(c)
            if  letter(x) ==1
                if c(x) == 'a' || c(x) == 'e' || c(x) == 'i' || c(x) == 'o' || c(x) == 'u'
                    vec(x) = 1;         %vowel
                else
                    vec(x) = -1;        %consonant
                end
            else
                vec(x) = 0;             %number
            end
            if c(x) == '!'
                vec(x) = 2;             %missing value
            end
            for y = 1:length(vec)
                nameCode(i) = vec(y);
            end
        end
    end
end

    