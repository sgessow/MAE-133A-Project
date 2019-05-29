clc; clear all; close all;
load('a22si');
WF_Ratio = 1.6;
FA_Ratio = 1/14.7;
mdot_a = 1; %Kg/s
WF_Ratio=.01:.1:1.2;
Results=[];
for i=WF_Ratio
    results=calculate_cycle(i,FA_Ratio,mdot_a);
    Results=[Results;results];
end
plot(WF_Ratio,Results(:,1))
figure
plot(Results(:,3),Results(:,1))