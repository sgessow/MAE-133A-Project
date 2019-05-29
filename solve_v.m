function Out=solve_v(v_i_a,vr_i_a,s_w,v_total,m_dot_a,m_dot_w)
    load('a22si')
    load('sup_steam')
    load('sat_steam')

    Air_Table=x;
    Air_Table(:,1)=Air_Table(:,1);
    Steam_Table = sortrows(Table,2); % sort just the first column
    Sat_Steam_Table=Steam_Table_Sat;
    %              1  2  3   4  5   6
    % Air Table:   T, h, pr, u, vr, s_0
    % Steam Table: p, T, v,  u, h,  s
    
    %Sat Steam Tables   1    2   3  4  5   6  7   8  9  10 11  12
    %                  T(C) P(B) vf vg uf, ug hf hfg hg sf sg T(C)
%     v_i_a=6.4753e-05;
%     vr_i_a=63.1079;
%     s_w=9.4991;
%     v_total=8.5569e-04;
%     m_dot_w=0.1250;
%     m_dot_a=1;

    entropies_water=Steam_Table(:,6);

    Possible_Steam_Tables=[];
    for i=1:length(entropies_water)-1
        if (entropies_water(i)<s_w && s_w<=entropies_water(i+1) && (entropies_water(i)-entropies_water(i+1))<3)
            new_row=[];
            for j=1:length(Steam_Table(1,:))
                 new_row=[new_row,interp1(entropies_water(i:i+1),[Steam_Table(i,j),Steam_Table(i+1,j)],[s_w])];
            end
            Possible_Steam_Tables=[Possible_Steam_Tables;new_row];
            %Possible_Steam_Tables=[Possible_Steam_Tables;Steam_Table(i,:)];
         end
    end
    %Possible_Steam_Tables=Steam_Table;
    
    s_f_w=Sat_Steam_Table(:,10);
    s_g_w=Sat_Steam_Table(:,11);
    for i=1:length(s_f_w)
        if s_f_w(i)<s_w && s_g_w(i)>=s_w
            "Need to Implement sat liquid"
        end
    end
    Possible_Air_Tables=[];
    air_temperatures=Air_Table(:,1);
    for i=1:length(Possible_Steam_Tables(:,1))
        Steam_Temp=Possible_Steam_Tables(i,2);
        for j=1:length(Air_Table(:,1))-1
            if Air_Table(j,1)<Steam_Temp && Air_Table(j+1,1)>=Steam_Temp
                new_row=[];
                for k=1:length(Air_Table(1,:))
                     new_row=[new_row,interp1(air_temperatures(j:j+1),[Air_Table(j,k),Air_Table(j+1,k)],[Steam_Temp])];
                end
                Possible_Air_Tables=[Possible_Air_Tables;new_row];
            end
        end
    end
    out=[];
    for i=1:length(Possible_Steam_Tables(:,1))
        v_water=Possible_Steam_Tables(i,3)*m_dot_w;
        vr_o_a=Possible_Air_Tables(i,5);
        v_air=(vr_o_a/vr_i_a)*v_i_a*m_dot_a;
        v=v_air;
        if abs(v-v_total)<.08
            %good_row=i;
            if abs((.287*Possible_Air_Tables(i,1))/v_air*10^-9-Possible_Steam_Tables(i,1))<10
               out=[out;Possible_Air_Tables(i,:),Possible_Steam_Tables(i,:)];
            end
        end
    end
    out_sorted = sortrows(out,1);
    Out=out_sorted(1,:);
end
