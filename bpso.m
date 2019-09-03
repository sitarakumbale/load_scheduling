clc;close all;
tic
%MD =20;
MD=[10 7 12 13 4 2 8 5 5 0 10 15 6 18 10 13 16 17 18 15 12 16 18 17 ];
maxD=0;  no_part=20; no_bits=4;itermax=100;%MD=max. demand %
T=24;%no. of hours in a day
%no_load=10; %number of loads
d_mat=zeros(no_load,T);
schedulmat=zeros(no_load,T);
epk_tmp=[];
glmin_tmp=[];%Global min.
wait_time=zeros(1,no_load);
P=[4 4 10 10 4 4 4 4 4 4 4 10 10 10 4 4 4 4 4 4 4 4 4 4]; %tariff structure fig1.(reference paper
%P=ones(24,1);
for j=1 : 24
    co(j)=0;
    d(j)=0;
end

for t = 1:no_part
   pbest(t)=1000;%personal best
   gbest=1000.0;%global best
end
   

no_load = input('Number of loads: ');
%{
s=zeros(1,no_load);
for i=1:no_load 
    X=sprintf('Enter the starting time of  load %d',i);
    disp(X);
    s(i)=input('enter :');
end
s
f=zeros(1,no_load);
for i=1:no_load 
    X=sprintf('Enter the Finishing time of  load %d',i);
    disp(X);
    f(i)=input('enter :');
end
f
l=zeros(1,no_load);
for i=1:no_load 
    X=sprintf('Enter the Duration of  load %d',i);
    disp(X);
    l(i)=input('enter :');
end
l
r= zeros(no_load,max(l));
for i=1:no_load
    for j=1:l(i)
       X=sprintf('Enter the power consumed by load %d at hour%d',i,j);
       disp(X);
       r(i,j)=input('enter :') ;
    end
end
r
%}

disp('please select the load from the list given below :');
disp('Light-1');
disp('Fan-2');
disp('Air Conditioner-3');
disp('Refrigerator-4');
disp('Room Heater-5');
disp('Washing Machine/Dishwasher-6');
disp('TV/PC Desktop-7');
disp('Laptop-8');
disp('Water Pump-9');
disp('Grinder/Mixer-10');
disp('Iron Box-11');
disp('Vacuum Cleaner-12');
l_name=zeros(1,no_load);
for i=1:no_load
    X=sprintf('Load %d is ',i);
    disp(X); 
    l_name(i)=input('Enter :');
end


%load categorisation 

%load prioritsation
%category can be 1 2 or 3
%app_set--> application setting can be 0 for off and 1 for on
%system type 1 for cooling, 2 for heating, 3 for battery-run
%heating device has upper limit and lowr limit
%cooling device has upper and lower limit

%input temp, app_set, charge by user

%load type like fan, AC etc is l_name
cat=zeros(1,no_load);
priority=zeros(1,no_load);
temp_AC=0;
temp_fridge=0;
temp_h=0;
system_type_AC=0;
system_type_fridge=0;
system_type_h=0;
charge_lap=0;
system_type_lap=0;
app_set=10;
c_upper_limit_ac=30; %celcius
c_lower_limit_ac=20; %celcius
c_upper_limit_f=20; %celcius
c_lower_limit_f=5; %celcius
h_upper_limit=27; %celcius
h_lower_limit=20; %celcius

for k=1:no_load
    switch l_name(k)
        case 1
        case 2
        case 7
        case 10
        case 11
        case 12
         cat(k)=1;
        case 3
        case 4
        case 5
        case 8
            cat(k)=2;
        case 6
        case 9
            cat(k)=3;
        otherwise disp('Invalid load type entered!');
    end

    if(cat(k)==2)
        if(l_name(k)==3)
            temp_AC=input(' Enter the temperature of the cooling device \n');
            system_type_AC=1;
        end
        if(l_name(k)==4)
            temp_fridge=input(' Enter the temperature of the cooling device \n');
            system_type_fridge=1;
        end 
        if(l_name(k)==5)
            temp_h=input('Enter the temperature of the heating device \n');
            system_type_h=2;
        end
        if (l_name(k)==8)
            charge_lap=input('Enter the battery charge %d \n');
            system_type_lap=3;
       end
    end
    
    
     %prioritisation of loads
    if(cat(k)==1)
        if(app_set==1) %on or off
            priority(k)=1;
        else
            priority(k)=0;
        end
    end
    if(cat(k)==2)
            if(system_type_AC==1)
                if(temp_AC>c_upper_limit_ac)
                    priority(k)=1;
                end
                if(temp_AC<c_upper_limit_ac & temp_AC>c_lower_limit_ac)
                    priority(k)=2;
                end
                if(temp_AC<c_lower_limit_ac)
                    priority(k)=3;
                end
            end
            if(system_type_fridge==1)
                if(temp_fridge>c_upper_limit_f)
                    priority(k)=1;
                end
                if(temp_fridge<c_upper_limit_f & temp_fridge>c_lower_limit_f)
                    priority(k)=2;
                end
                if(temp_fridge<c_lower_limit_f)
                    priority(k)=3;
                end
            end
            if(system_type_h==2)
                if(temp_h<h_lower_limit)
                    priority(k)=1;
                end
                if(temp_h<h_upper_limit & temp_h>h_lower_limit)
                    priority(k)=2;
                end
                if( temp_h > h_upper_limit)
                    priority(k)=3;
                end
            end
            if(system_type_lap==3)
                    if(charge_lap<30)
                        priority(k)=1;
                    end
                    if(charge_lap<50)
                        priority(k)=2;
                    end
                    if(charge_lap>50)
                       priority(k)=3;
                    end
            end
            
    end
    if(cat(k)==3)  
        if(24-st_p(k)-l(k)<=1)
            priority(k) =1;
        else
            priority(k)=3;
        end
        
    end
 
    
    
    

end     
            
    
    
                
    

        
%setting for fixed load, category 1, whether on or off

%s=[2 4 6 4 6 7 4 2 5 4 ]; %start time
%f=[16 18 8 12 16 23 12 21 19 9 ]; %finish time
%l=[6 3 3 3 6 5 3 2 4 2]; %duration of load
% r=[4 4 4 5 5 6 7  ];% power consumed by the load
%r=[[4 5 0 0 0 0]; [4 4 3 0 0 0] ;[4 3 3 0 0 0]; [5 5 6 0 0 0] ;[5 3 5 4 5 4]; [6 5 6 4 0 0]; [4 3 3 0 0 0]; [3 5 0 0 0 0]; [4 5 3 2 0 0]; [4 3 0 0 0 0] ]

for j=1: no_load
    m(j) = f(j)-s(j)-l(j)+2;  
end

for i= 1 : no_load
    bm=dec2bin(m(i),4);%bm is a temporary variable
    for j=1 : 4
        binarym(i,j)=bm(j);%the  binary bits are stored in matrix form
    end   
end

for i= 1:no_part
    for j=1 : no_load
           p(i,j)=0;
           pbest_particle(i,j)=0;
           gbest_particle(j)=0;
        for k=1:4
            binary_p(i,j,k)='0';
            pbest_p(i,j,k)='0';
        end 
    end
end

for i= 1 : no_part
    
    for j=1 : no_load
        p(i,j)= randi([0,m(j)]);
        b_p= dec2bin(p(i,j),no_bits);
        for k=1 : 4
             binary_p(i,j,k)=b_p(k);
        end
        
    end
    
    for j=1:no_load
       vel_max(j) = (m(j)/100);
    end
        
    for j= 1: no_load
        for k = 1:no_bits
            vel(j,k)=unifrnd(-vel_max(j), vel_max(j));%velocity max. and min.
        end
    end
end
   

for n=1:itermax
    
   for i= 1 : no_part  %no. of particles
        for j= 1 : no_load
             d_mat=zeros(no_load,T);
             schedulmat=zeros(no_load,T);
        end
        for x=1:24
            co(x)=0;
            d(x)=0;
        end
        
   % calculation of starting time from p(i,j)
        for j= 1:no_load
            st_p(j)=s(j)+p(i,j);%starting time from p
      
       %prioritization here
       
       
            for x = (st_p(j) : (st_p(j) + l(j) -1))
                schedulmat (j,x) = P(x) *r(j,1+x-st_p(j)); %  P is tariff rates . r is power consumed by loads . energy cost is the schedulemat
                d_mat (j,x) = r(j,1+x-st_p(j)); %table in reference paper pg 3 table 3
                co(x) =co(x) + schedulmat(j,x);%cost function (energy )
                d(x) = d(x) + d_mat(j,x);%sum of  scheduled loads for each hour
                
            end
            
        end
        
        fit(i)=0.0;MD_limit=0;
        for x=1 :24
            if(d(x)>MD(x)) MD_limit=1;
            end
            fit(i)= fit(i)+co(x);
        end
      
        if ((fit(i)<pbest(i))&&(MD_limit==0))
           pbest(i)=fit(i);
           for j=1 :no_load
               pbest_particle(i,j)=p(i,j);
               for k=1 : 4
                    pbest_p(i,j,k)= binary_p(i,j,k);
               end
           end         
        end
       
        if(pbest(i)<=gbest)
          
             gbest=pbest(i);
             for j=1 :no_load
               gbest_particle(j)=pbest_particle(i,j);
               for k=1:no_bits
                 gbest_p(j,k)=pbest_p(i,j,k);
               end
             end  
        end
   
        wmin=0.4;wmax=0.9;
        w=((wmax-wmin)*n/itermax);
        c1=2.05;c2=2.05;
     
   
    %Velocity Update
        for j= 1: no_load
          
            for k = 1:no_bits
                vel(j,k)=w* vel(j,k)+c1*rand()*(pbest_p(i,j,k)-binary_p(i,j,k))+c2*rand()*(gbest_p(j,k)-binary_p(i,j,k));
                if (abs(vel(j,k))>vel_max(j)) 
                    if(vel(j,k)<0.0) 
                        vel(j,k)=-vel_max(j);
                    end
                    if(vel(j,k)>0.0)
                        vel(j,k)=vel_max(j);
                    end
                end
                s_vel(j,k)=(1/(1+exp(-vel(j,k))));% sigmoid function
                if (rand()<s_vel(j,k))
                    newbinary_p(i,j,k)='1';
                else newbinary_p(i,j,k)='0';
                end
             
            end
          
        % Find the decimal value of new particle
            dec_p=0;
            for k = 1:4
                if(newbinary_p(i,j,k)=='1')
                    dec_p=dec_p+pow2(4-k); % pow2 is in built function which says 2 raised to power (4-k)
                end
            end
        
            if (dec_p>(m(j)-1))
                p(i,j)=m(j)-1;
                b_p= dec2bin(p(i,j),no_bits);
                for k=1 : 4
                    newbinary_p(i,j,k)=b_p(k);
                end
          
            else
                p(i,j)=dec_p;          
            end
            for k= 1:no_bits
                binary_p(i,j,k)=newbinary_p(i,j,k);
            end
 
           end
   end
 
      epk_tmp=[epk_tmp;n];
  
     glmin_tmp=[glmin_tmp;gbest];
    % Array to Hold Best Cost Values

    
end


% 
 for j=1 :no_load
        sched_p(j)=gbest_particle(j);
               
 end
           

 
  for j= 1 : no_load
             d_mat=zeros(no_load,T);
        schedulmat=zeros(no_load,T);

   end
  for x=1:24
      co(x)=0;
      d(x)=0;
  end

 for j= 1:no_load
       st_p(j)=s(j)+sched_p(j);
       
         for x = (st_p(j) : (st_p(j) + l(j) -1))
              schedulmat (j,x) = P(x) *r(j,1+x-st_p(j));
                   d_mat (j,x) = r(j,1+x-st_p(j));
              co(x) =co(x) + schedulmat(j,x);
              d(x) = d(x) + d_mat(j,x);
        end
 end
  
   
 for i= 1:T
    total_d(i)=0;
    for j= 1:no_load
    total_d(i)=total_d(i)+d_mat(j,i);
    end
 end
 
 for j=1:no_load       
            if ((st_p(j) + l(j) ) > f(j))
                wait_time(j)=st_p(j)+l(j)-f(j);
            else
                wait_time(j)=0;
            end
        end
 %user- satisfaction levels
 user_sat=zeros(1,no_load);
for j=1:no_load  
    if wait_time(j)>= 15 
        user_sat(j)=0;
    end
    if wait_time(j)>= 10 & wait_time(j) <15
        user_sat(j)=1;
    end    
    if wait_time(j)>=5  & wait_time(j) <10
        user_sat(j)=2;
    end
    if wait_time(j)>=3 & wait_time(j) <5
        user_sat(j)=3;
    end
    if wait_time(j)>0 & wait_time(j) <3
        user_sat(j)=4;
    end
    if wait_time(j)==0 
        user_sat(j)=5;
    end
end

 plot (epk_tmp,glmin_tmp)

ylabel('Best Cost','FontSize',10,'Color','r')
xlabel('Iteration','FontSize',10,'Color','r')
% grid on;

 figure;

bar(total_d,'b')
axis([1 24 1 20])
ylabel('Demand  (KW)','FontSize',11,'Color','r')
xlabel('Hour','FontSize',11,'Color','r')

figure;
bar( MD,'c')
axis([1 24 1 25])
ylabel('Maximum demand','FontSize',11,'Color','r')
xlabel('Hour','FontSize',11,'Color','r')

figure;
name={'load1','load2','load3','load4','load5', 'load6'};
bar(user_sat)
ylim([0 5]);
set(gca,'xticklabel',name)
ylabel('User satisfaction ','FontSize',11,'Color','r');
%xlabel('load ','FontSize',11,'Color','r');

toc
f
l
st_p
wait_time
