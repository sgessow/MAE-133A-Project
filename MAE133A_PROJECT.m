clc; clear all; close all;
load('a22si');

%% SET CONDITIONS
WF_Ratio=3;
FA_Ratio=1/16;
WA_Ratio=FA_Ratio*WF_Ratio;
mdot_a = 1; %Kg/s
T_auto_ignition=576;
T_atmosphere= 25 + 273.15;
P_atmosphere=1*10^(5);
T_max_engine=2000; %Can be 1500-2500

%% State 1
% Asssumptions - intake is at atmospheric conditions and the cp
% contribution of fuel is negligible in the mixture
T_1 = T_atmosphere; %(Kelvin)
P_1 = P_atmosphere; %(Pa)
Pr_1 = IdealAir(T_1,'T','pr');
u_1 = IdealAir(T_1,'T','u');


%% State 2 For Simple Cycle
T_2_Simple = T_auto_ignition; %(Kelvin)
Pr_2_Simple = IdealAir(T_2_Simple,'T','pr');
r_Simple = Pr_2_Simple/Pr_1; %Compression Ratio
P_2_Simple = r_Simple * P_1;

%% State 2
% assumptions: water injection conditions are P_2 and atmospheric
% Temperature
%air conditions
T_2 = T_auto_ignition;
Pr_2 = IdealAir(T_2,'T','pr');
P_2 = P_1*Pr_2/Pr_1;
u_2 = IdealAir(T_2,'T','u');

%water conditions 
P_i_w = P_2;
T_i_w = T_atmosphere; %(Kelvin)
u_i_w = XSteam('u_pt',P_i_w/10^(5),T_i_w - 273.155); %Note: in Celcius and Bars
mdot_w = mdot_a*WA_Ratio;

%% State 3
syms Tf T_3 

% Solve system of equations to get T_3
a_w = 29.182;
b_w = 14.503/1000;
c_w = -2.0235/1000^(2);
d_w = 0;

cp_w = a_w + b_w*Tf + c_w*Tf^(2) + d_w*Tf^(3);

a_a = 27.453;
b_a = 6.1839/1000;
c_a = 0.89932/1000^(2);
d_a = 0;

cp_a = a_a + b_a*Tf + c_a*Tf^(2) + d_a*Tf^(3);
eqn = mdot_w*int(cp_w, T_i_w, T_3) + mdot_a*int(cp_a, T_2, T_3) == 0;
T_3 = solve(eqn, T_3);

T_3 = eval(vpa(T_3(1))); 

T_o_w = T_3;
P_o_w=P_i_w; %constant Pressure assumption
u_o_w = XSteam('u_pt',P_o_w/10^(5),T_o_w - 273.155); %Note: in Celcius and Bars
Pr_3 = IdealAir(T_3,'T','pr'); 
P_3 = P_2; %constant Pressure assumption
u_3_a=IdealAir(T_3,'T','u');
s_o_w = XSteam('s_pt',P_o_w/10^(5),T_o_w - 273.155); %Note: in Celcius and Bars
u_3=u_3_a*mdot_a+u_o_w*mdot_w;

%% State 4
T_4 = T_auto_ignition;
Pr_4 = IdealAir(T_4,'T','pr');
vr_4 = IdealAir(T_4,'T','vr');
P_4 = P_3 * (Pr_4/Pr_3);
u_4_a=IdealAir(T_4,'T','u');
u_4_w=XSteam('u_ps',P_4/10^(5),s_o_w);
u_4=u_4_a*mdot_a+u_4_w*mdot_w;
r = P_4 / P_1;


%% State 5
T_5=T_max_engine;
LLLLL






