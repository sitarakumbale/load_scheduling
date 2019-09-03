tic
clc;
clear;

%% Problem Definition
%Demand Function is called Demand
%CCost Function to be optimized is called CostF


numVar=10;%This is the number of decison Variables. Refers to the number of Loads for our problem
VarSize=[1 numVar];%Matrix Size for the Loads
VarMin=0;%Lower Bound for Decision Variable
VarMax=23;%Upper Bound for Decision Variable

%% ABC Settings

MaxIt=75;              % Maximum Number of Iterations
nPop=100;               % Population Size (Colony Size)
nOnlooker=nPop/2;         % Number of Onlooker Bees
L=round(0.6*numVar*nPop); % Abandonment Limit Parameter (Trial Limit)
a=1;                    % Acceleration Coefficient Upper Bound

%% Load Specifications

s_lower=[2 4 6 4 6 7 4 2 5 4]; %start time
f_upper=[11 18 8 12 16 23 12 21 19 9 ]; %finish time
dur_load=[2 3 3 3 6 5 3 2 4 2]; %duration of load
rating=[4 4 5 6 4 2 5 6 3 5];

D=zeros(24,1); %Initialize Array to Hold all the Demands throughout the day

R = [4 4 10 10 4 4 4 4 4 4 4 10 10 10 4 4 4 4 4 4 4 4 4 4];%Price Standard

%% Initialization

% Creating the Empty Bee Structure
empty_bee.Position=[];
empty_bee.Cost=[];

% Initializing the Bee Population
pop=repmat(empty_bee,nPop,1);

% Initialize Best Solution of Cost to infinity so that you have to
% gradually improve it
BestSol.Cost=inf;

% Randomly Create Initial Population
for i=1:nPop
  for j = 1:numVar
    pop(i).Position(j)= randi([0,f_upper(j)-dur_load(j)-1]);
  end
    pop(i).Cost=CostF1(pop(i).Position,dur_load,rating);
    if pop(i).Cost<=BestSol.Cost && Demand1(pop(i).Position,dur_load,rating) == 0
        BestSol=pop(i);
       
    end
end

% Abandonment Counter
C=zeros(nPop,1);

% Array to Hold Best Cost Values
BestCost=zeros(MaxIt,1);

%% ABC Main Loop

for it=1:MaxIt
    
    % Recruited/Employed Bees
    for i=1:nPop
        
        % Choose k randomly, not equal to i
        K=[1:i-1 i+1:nPop];
        k=K(randi([1 numel(K)]));
        
        % Define Acceleration Coeff.
        phi=a*unifrnd(-1,+1,VarSize);
        
        % New Bee Position
        for j=1:1:numVar
        newbee.Position(j) = pop(i).Position(j) + floor(phi(j).*(pop(i).Position (j) - pop(k).Position(j)));
        if newbee.Position(j) > f_upper(j) - dur_load(j) || newbee.Position(j) < s_lower(j)
          newbee.Position(j) = pop(i).Position(j);
        end
        end
        
        % Evaluation
        newbee.Cost=CostF1(newbee.Position,dur_load,rating);
        
        % Comparision
        if newbee.Cost<=pop(i).Cost && Demand1(newbee.Position,dur_load,rating)==0
            pop(i)=newbee;
        else
            C(i)=C(i)+1;
        end
        
    end
    
    % Calculate Fitness Values and Selection Probabilities
    F=zeros(nPop,1);
    MeanCost = mean([pop.Cost]);
    for i=1:nPop
        F(i) = exp(-pop(i).Cost/MeanCost); % Convert Cost to Fitness
    end
    P=F/sum(F);
    
    % Onlooker Bees
    for m=1:nOnlooker
        
        % Select Source Site
        i=RouletteWheelSelection(P);
        
        % Choose k randomly, not equal to i
        K=[1:i-1 i+1:nPop];
        k=K(randi([1 numel(K)]));
        
        % Define Acceleration Coeff.
        phi=a*unifrnd(-1,+1,VarSize);
        
         % New Bee Position
        for j=1:1:numVar
        newbee.Position(j) = pop(i).Position(j) + floor(phi(j).*(pop(i).Position (j) - pop(k).Position(j)));
        if newbee.Position(j) > f_upper(j) - dur_load(j) || newbee.Position(j) < s_lower(j)
          newbee.Position(j) = pop(i).Position(j);
        end
        end        
        % Evaluation
        newbee.Cost=CostF1(newbee.Position,dur_load,rating);
        
        % Comparision
        if newbee.Cost<=pop(i).Cost && Demand1(newbee.Position,dur_load,rating)==0
            pop(i)=newbee;
        else
            C(i)=C(i)+1;
        end
        
    end
    
 % Scout Bees
    for i=1:nPop
      
        if C(i)>=L
          for j = 1:1:numVar
            pop(i).Position(j)=randi([0,f_upper(j)-dur_load(j)-1]);
          end
            pop(i).Cost=CostF1(pop(i).Position,dur_load,rating);
            C(i)=0;
        end
    end
    
    % Update Best Solution Ever Found
    for i=1:nPop
        if pop(i).Cost<=BestSol.Cost && Demand1(pop(i).Position,dur_load,rating)==0
            BestSol=pop(i);
            
        end
    end
    
    % Store Best Cost Ever Found
    BestCost(it)=BestSol.Cost;
    
    % Display Iteration Information
    disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
    
end
    
%% Results

figure;
%plot(BestCost,'LineWidth',2);
semilogy(BestCost,'LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost');
grid on;

figure;
res = fopen('myfile.bin','r');
A = fscanf(res,'%6d \n');
bar(A,'b')
axis([1 24 1 20])
ylabel('Demand (KW)','FontSize',10,'Color','r')
xlabel('Hour','FontSize',10,'Color','r')
toc

