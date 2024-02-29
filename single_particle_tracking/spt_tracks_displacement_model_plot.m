function spt_tracks_displacement_model_plot(data)
figure()
set(gcf,'name','Tracks Displacement Model Plot','NumberTitle','off','color','w','units','normalized','position',[0.4 0.3 0.4 0.6],'menubar','none','toolbar','none')

if length(data)>1
    slider_step_one=[1/(length(data)-1),1];
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.04,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step_one,'Callback',{@sld_one_callback});
end
slider_one_value=1;

if size(data{slider_one_value}.JumpProb,1)>1
    slider_step_two=[1/(size(data{slider_one_value}.JumpProb,1)-1),1];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.04,0,0.96,0.04],'value',1,'min',1,'max',size(data{slider_one_value}.JumpProb,1),'sliderstep',slider_step_two,'Callback',{@sld_two_callback});
end
slider_two_value=1;

spt_tracks_displacement_model_plot_inside(data,slider_one_value,slider_two_value)


    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        if size(data{slider_one_value}.JumpProb,1)>1
            slider_two.SliderStep = [1/(size(data{slider_one_value}.JumpProb,1)-1),1];
            slider_two.Max = size(data{slider_one_value}.JumpProb,1);
            slider_two.Min = 1;
            slider_two.Value = 1;
        end
        slider_two_value = 1;
        spt_tracks_displacement_model_plot_inside(data,slider_one_value,slider_two_value)
    end

    function sld_two_callback(~,~,~)
        slider_two_value = round(slider_two.Value);        
        spt_tracks_displacement_model_plot_inside(data,slider_one_value,slider_two_value)
    end 
end

function spt_tracks_displacement_model_plot_inside(data,slider_one_value,slider_two_value)
name = data{slider_one_value}.name;

if data{slider_one_value}.ModelFit == 2
    y = data{slider_one_value}.JumpProbCDF;
    x = data{slider_one_value}.HistVecJumpsCDF;
else
    y = data{slider_one_value}.JumpProb;
    x = data{slider_one_value}.HistVecJumps;
end
ax = gca; cla(ax);
plot(x,y(slider_two_value,:),'b','linewidth',1)
hold  on
plot(x,data{slider_one_value}.model_PDF_CDF(slider_two_value,:),'r','linewidth',1)
xlabel('Displacement','interpreter','latex','FontSize',14)
ylabel('PDF (Counts)','interpreter','latex','FontSize',14)

name_title = ['File Name = ',regexprep(name,'_',' ')];
delay = ['Delay =',num2str(data{slider_one_value}.dT*slider_two_value)];

if data{slider_one_value}.NumberOfStates == 2 && data{slider_one_value}.FitLocError == 0
    D_free = ['D Free = ',num2str(data{slider_one_value}.best_vals(slider_two_value,1))];
    D_bound = ['D Bound = ',num2str(data{slider_one_value}.best_vals(slider_two_value,2))];
    Fraction = ['Fraction Bound = ',num2str(data{slider_one_value}.best_vals(slider_two_value,3))];    
    title({'',name_title,delay,D_free,D_bound,Fraction},'interpreter','latex','fontsize',14)
elseif data{slider_one_value}.NumberOfStates == 2 && data{slider_one_value}.FitLocError == 1
    D_free = ['D Free = ',num2str(data{slider_one_value}.best_vals(slider_two_value,1))];
    D_bound = ['D Bound = ',num2str(data{slider_one_value}.best_vals(slider_two_value,2))];
    Fraction = ['Fraction Bound = ',num2str(data{slider_one_value}.best_vals(slider_two_value,3))];    
    Loc_Error = ['LocError = ',num2str(data{slider_one_value}.best_vals(slider_two_value,4))];
    title({'',name_title,delay,D_free,D_bound,Fraction,Loc_Error},'interpreter','latex','fontsize',14)   
elseif data{slider_one_value}.NumberOfStates == 3 && data{slider_one_value}.FitLocError == 0
    D_free_1 = ['D Free 1 = ',num2str(data{slider_one_value}.best_vals(slider_two_value,1))];
    D_free_2 = ['D Free 2 = ',num2str(data{slider_one_value}.best_vals(slider_two_value,2))];
    D_Bound = ['D Bound = ',num2str(data{slider_one_value}.best_vals(slider_two_value,3))];
    Fraction_1 = ['Fraction Bound = ',num2str(data{slider_one_value}.best_vals(slider_two_value,4))];
    Fraction_2 = ['Fraction Free 1 = ',num2str(data{slider_one_value}.best_vals(slider_two_value,5))];
    title({'',name_title,delay,D_free_1,D_free_2,D_Bound,Fraction_1,Fraction_2},'interpreter','latex','fontsize',14)
elseif data{slider_one_value}.NumberOfStates == 3 && data{slider_one_value}.FitLocError == 1
    D_free_1 = ['D Free 1 = ',num2str(data{slider_one_value}.best_vals(slider_two_value,1))];
    D_free_2 = ['D Free 2 = ',num2str(data{slider_one_value}.best_vals(slider_two_value,2))];
    D_Bound = ['D Bound = ',num2str(data{slider_one_value}.best_vals(slider_two_value,3))];
    Fraction_1 = ['Fraction Bound = ',num2str(data{slider_one_value}.best_vals(slider_two_value,4))];
    Fraction_2 = ['Fraction Free 1 = ',num2str(data{slider_one_value}.best_vals(slider_two_value,5))];
    Loc_Error = ['LocError = ',num2str(data{slider_one_value}.best_vals(slider_two_value,6))];
    title({'',name_title,delay,D_free_1,D_free_2,D_Bound,Fraction_1,Fraction_2,Loc_Error},'interpreter','latex','fontsize',14)   
end
end