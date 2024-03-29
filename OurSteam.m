function Out=OurSteam(code,In1,In2)
    % code="Tv";
    % In1=2000;
    % In2=.1808;
    %Table=xlsread('Sup_Heated_Steam_Tables_For_Comp.xlsx');
    load('sup_steam.mat','Table');
    if code ~= "Tvu" && code ~= "Tvs"
        eror("Only Temperature specific volume is implemented")
    end
    Temperatures=Table(:,2);
    entropies=Table(:,6);
    volumes=Table(:,3);
    internal_energies=Table(:,4);
    possible_volumes=[];
    for i =1:length(Temperatures)-1
         if (Temperatures(i)<In1 && In1<=Temperatures(i+1) && (Temperatures(i)-Temperatures(i+1))<300)
             temp_v=interp1(Temperatures(i:i+1),volumes(i:i+1),[In1]);
             temp_u=interp1(Temperatures(i:i+1),internal_energies(i:i+1),[In1]);
             temp_s=interp1(Temperatures(i:i+1),entropies(i:i+1),[In1]);
             possible_volumes=[possible_volumes;i,temp_v,temp_u,temp_s];

         end
    end   
    for i =1:length(possible_volumes(:,2))-1
        %possible_volumes(i,2), In2
        if (possible_volumes(i,2)>=In2 && In2>possible_volumes(i+1,2))
            u=interp1([possible_volumes(i,2),possible_volumes(i+1,2)],[possible_volumes(i,3),possible_volumes(i+1,3)],In2);
            s=interp1([possible_volumes(i,2),possible_volumes(i+1,2)],[possible_volumes(i,4),possible_volumes(i+1,4)],In2);
         end
    end
    if code=="Tvu"
        Out=u;
    elseif code=="Tvs"
        Out=s;
    end
end