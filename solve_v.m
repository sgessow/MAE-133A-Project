function Out=solve_v(v_i_a,vr_i_a,s_w,v_total,m_dot_a,m_dot_w)
    load('a22si')
    load('sup_steam')
    %load('sat_steam')

    Air_Table=x;
    Air_Table(:,1)=Air_Table(:,1)-273.15;
    Steam_Table = sortrows(Table,2); % sort just the first column
    %              1  2  3   4  5   6
    % Air Table:   T, h, pr, u, vr, s_0
    % Steam Table: p, T, v,  u, h,  s
%     v_i_a=6.4753e-05;
%     vr_i_a=63.1079;
%     s_w=9.4991;
%     v_total=8.5569e-04;
%     m_dot_w=0.1250;
%     m_dot_a=1;

    entropies_water=Steam_Table(:,6);
    % volumes_water=Steam_Table(:,3);
    % Temperatures_water=Steam_Table(:,2);

    Possible_Steam_Tables=[];
    for i=1:length(entropies_water)-1
        if (entropies_water(i)<s_w && s_w<=entropies_water(i+1) && (entropies_water(i)-entropies_water(i+1))<3)
            new_row=[];
            for j=1:length(Steam_Table(1,:))
                 new_row=[new_row,interp1(entropies_water(i:i+1),[Steam_Table(i,j),Steam_Table(i+1,j)],[s_w])];
            end
            Possible_Steam_Tables=[Possible_Steam_Tables;new_row];
         end
    end
    % Add on values for 



    Possible_Air_Tables=[];
    air_temperatures=Air_Table(:,1);
    for i=1:length(Possible_Steam_Tables(:,1))
        Steam_Temp=Possible_Steam_Tables(i,2);
        for j=1:length(Air_Table(:,1))-1
            if Air_Table(j,1)<=Steam_Temp && Air_Table(j+1,1)>Steam_Temp
                new_row=[];
                for k=1:length(Air_Table(1,:))
                     new_row=[new_row,interp1(air_temperatures(j:j+1),[Air_Table(j,k),Air_Table(j+1,k)],[Steam_Temp])];
                end
                Possible_Air_Tables=[Possible_Air_Tables;new_row];
            end
        end
    end
    for i=1:length(Possible_Steam_Tables(:,1))
        v_water=Possible_Steam_Tables(i,3)*m_dot_w*10^-3;
        vr_o_a=Possible_Air_Tables(i,5);
        v_air=vr_o_a/vr_i_a*v_i_a*m_dot_a;
        v=v_air+v_water;
        if abs(v-v_total)<.0001
            good_row=i;
            if abs((.287*Possible_Air_Tables(i,1))/v_air*10^-9-Possible_Steam_Tables(i,1))<.05
                good_row=i;
                break
            end
        end
    end
    Out=Possible_Steam_Tables(good_row,:);
end
