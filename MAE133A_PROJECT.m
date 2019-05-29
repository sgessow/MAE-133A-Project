clc; clear all; close all;
load('a22si');
WF_Ratio = 1.6;
FA_Ratio = 1/16;
mdot_a = 1; %Kg/s
WF_Ratio=.01:.01:3;
Effeciencies=[];sl
for i=WF_Ratio
    results=calculate_cycle(i,FA_Ratio,mdot_a);
    Effeciencies=[Effeciencies,results(1)];
end
