function Cost=CostF1(x,dur_load,rating)
%maxDem=[20 10 15 13 14 12 18 15 15 20 10 23 22 11 10 13 16 17 18 15 12 16 18 17 ];
%s_lower=[2 4 6 4 6 7 4 2 5 4 ]; %start time
%f_upper=[11 18 8 12 16 23 12 21 19 9 ]; %finish time
%dur_load=[2 3 3 3 6 5 3 2 4 2]; %duration of load
%rating=[4 4 5 6 4 2 5 6 3 5]; %Maximum Demand Limit
D=zeros(24,1); %Initialize Array to Hold all the Demands throughout the day

R = [4 4 10 10 4 4 4 4 4 4 4 10 10 10 4 4 4 4 4 4 4 4 4 4];%Price Standard
Cost=0;

for i = 1:1:length(x)
  for j = 1:1:dur_load(i)
    Co = R(j+x(i))*rating(i);
     Cost = Co + Cost;   
  end
end
return;
