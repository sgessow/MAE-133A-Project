function Out=calculate_cycle(WF_Ratio,FA_Ratio, mdot_a)
    %% SET CONDITIONS
    %WF_Ratio = 1.6;
    %FA_Ratio = 1/16;
    WA_Ratio = FA_Ratio*WF_Ratio;
    %mdot_a = 1; %Kg/s
    T_atmosphere = 25 + 273.15;
    P_atmosphere = 1*10^(5); %(Pa)
    R_a = 0.287; %(kJ/(kg*K))
    r_simple = 10;
    mdot_w = mdot_a*WA_Ratio;
    %% State 1
    % Asssumptions - intake is at atmospheric conditions and the cp
    % contribution of fuel is negligible in the mixture
    T_1 = T_atmosphere; %(Kelvin)
    P_1 = P_atmosphere; %(Pa)
    Vr_1 = IdealAir(T_1,'T','vr');
    u_1 = IdealAir(T_1,'T','u');
    v_1 = ((R_a*T_1)/P_1)*10^3*mdot_a;

    %% Simple Cycle
    Vr_2_Simple = Vr_1/r_simple;
    T_2_Simple = IdealAir(Vr_2_Simple,'vr','T');
    v_2_Simple = (Vr_2_Simple/Vr_1)*v_1;
    T_auto_ignition = T_2_Simple;


    %% State 2
    % assumptions: water injection conditions are P_2 and atmospheric
    % Temperature
    %air conditions
    T_2 = T_auto_ignition;
    Vr_2 = IdealAir(T_2,'T','vr');
    v_2 = v_1*Vr_2/Vr_1;
    u_2 = IdealAir(T_2,'T','u');
    P_2 = (R_a*T_2)/v_2*10^3;

    %water conditions 
    P_i_w = P_2;
    T_i_w = T_atmosphere; %(Kelvin)
    u_i_w = XSteam('u_pt',P_i_w/10^(5),T_i_w - 273.15); %Note: in Celcius and Bars
    

    %% State 3
    % Solve energy balance for internal energies of water and air in the
    % cylander
    Tf=sym('Tf');
    T_3=sym('T_3');
    %sym T_3
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
    P_o_w = P_i_w; %constant Pressure assumption
    u_o_w = XSteam('u_pt',P_o_w/10^(5),T_o_w - 273.15); %Note: in Celcius and Bars
    Vr_3 = IdealAir(T_3,'T','vr'); 
    P_3 = P_2; %constant Pressure assumption
    v_3_a = (T_3*R_a)/P_3*10^3*mdot_a;
    u_3_a = IdealAir(T_3,'T','u');
    s_o_w = XSteam('s_pt',P_o_w/10^(5),T_o_w - 273.15); %Note: in Celcius and Bars
    u_3 = u_3_a*mdot_a+u_o_w*mdot_w;
    %% State 4
    % assumptions 3-4 is isentropic and T_4 is T_autoignition again
    T_4 = T_auto_ignition;
    Vr_4 = IdealAir(T_4,'T','vr');
    v_4_a = v_3_a * (Vr_4/Vr_3);
    P_4 = (R_a*T_4)/v_4_a*10^3;
    u_4_a = IdealAir(T_4,'T','u');
    u_4_w = XSteam('u_ps',P_4/10^(5),s_o_w); %Note: in Celcius and Bars
    u_4 = u_4_a*mdot_a + u_4_w*mdot_w;
    v_4_w = XSteam('v_pT',P_4/10^(5),T_4 - 273.15)*mdot_w; %Note: in Celcius and Bars
    v_4=v_4_a-v_4_w;
    r_new = v_1/v_4_a;

    %% State 5
    % T at 5 is from the temp of the burning fuel
    % v5 = v4 for both air and water
    T_5 = solve_T_5(T_4,mdot_a, FA_Ratio, WF_Ratio);
    u_5_a = IdealAir(T_5,'T','u');
    v_5_a = v_4_a;
    Vr_5=IdealAir(T_5,'T','vr');
    v_5_w = v_4_w;
    u_5_w = OurSteam("Tvu",T_5 - 273.15, v_5_w/mdot_w);
    %s_5_w = OurSteam("Tvs",T_5 - 273.15, v_5_w/mdot_w);
    u_5 = u_5_a*mdot_a + u_5_w*mdot_w;
    P_5 = (R_a*T_5)/v_5_a*10^3;
    v_5=v_5_a+v_5_w;

    %% State 6
    v_6_a=v_1;
    Vr_6=v_6_a/v_5_a*Vr_5;
    T_6 = IdealAir(Vr_6,'vr','T');
    P_6=(R_a*T_6)/v_6_a*10^3;
    u_6_a=IdealAir(Vr_6,'vr','u');
    u_6_w=XSteam('u_pt',P_6/10^(5),T_6 - 273.15);
    u_6=u_6_a*mdot_a+u_6_w*mdot_w;

    %% Overall Outputs and Effeciencies
    W_net = (u_5 - u_6) - ((u_2 - u_1) + (u_4 - u_3));
    Q_in = (u_5 - u_4);
    Effeciency = W_net/Q_in; %Q_in2A initially
    E_Comp = 1 - 1/r_new^.4 ;
    Out=[Effeciency,W_net,r_new];
end
