function spt_tracks_displacement_histogram_plot(data)
figure()
set(gcf,'name','Tracks Displacement Plot','NumberTitle','off','color','w','units','normalized','position',[0.4 0.3 0.4 0.6],'menubar','none','toolbar','none')

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

spt_tracks_displacement_plot_inside(data,slider_one_value,slider_two_value)

uimenu('Text','Fit Model','ForegroundColor','k','CallBack',@fit_model_callback);

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        if size(data{slider_one_value}.JumpProb,1)>1
            slider_two.SliderStep = [1/(size(data{slider_one_value}.JumpProb,1)-1),1];
            slider_two.Max = size(data{slider_one_value}.JumpProb,1);
            slider_two.Min = 1;
            slider_two.Value = 1;
        end
        slider_two_value = 1;
        spt_tracks_displacement_plot_inside(data,slider_one_value,slider_two_value)
    end

    function sld_two_callback(~,~,~)
        slider_two_value = round(slider_two.Value);        
        spt_tracks_displacement_plot_inside(data,slider_one_value,slider_two_value)
    end   

    function fit_model_callback(~,~,~)
        %input_values = inputdlg({'LocError (um):','UseWeights','ModelFit (PDF=1, CDF =2)','FitLocError','FitLocErrorRange','FitIterations','D_Free_2State','D_Bound_2State'},'',1,{'0.035','0','2','1','0.010 0.075','2','0.5 25','0.0001 0.05'});
        input_values = inputdlg({'LocError (um):','UseWeights','ModelFit (PDF=1, CDF =2)','FitLocError','NumberOfStates','FitLocErrorRange','FitIterations','D_Free_2State','D_Bound_2State','D_Free1_3State','D_Free2_3State','D_Bound_3State'},'',1,{'0.035','0','2','1','2','0.010 0.075','2','0.5 25','0.0001 0.05','0.5 25','0.5 25','0.0001 0.05'});
        if isempty(input_values)==1
            return
        else            
            LocError = str2double(input_values{1}); % If FitLocError=0, LocError in units of micrometers will be used.
            UseWeights = str2double(input_values{2}); % If UseWeights=0, all TimePoints are given equal weights. If UseWeights=1, TimePoints are weighted according to how much data there is. E.g. 1dT will be weighted more than 5dT.
            ModelFit = str2double(input_values{3}); %Use 1 for JumpProb-fitting; Use 2 for JumpProbCDF-fitting
            FitLocError = str2double(input_values{4}); % If FitLocError=1, the localization error will fitted from the data
            NumberOfStates = str2double(input_values{5}); % If NumberOfStates=2, a 2-state model will be used; If NumberOfStates=3, a 3-state model will be used
            FitLocErrorRange = str2num(input_values{6}); % min/max for model-fitted localization error in micrometers.
            FitIterations = str2double(input_values{7}); % Input the desired number of fitting iterations (random initial parameter guess for each)
            D_Free_2State = str2num(input_values{8}); % min/max Diffusion constant for Free state in 2-state model (units um^2/s)
            D_Bound_2State = str2num(input_values{9}); % min/max Diffusion constant for Bound state in 2-state model (units um^2/s)
            D_Free1_3State = str2num(input_values{10}); % min/max Diffusion constant #1 for Free state in 3-state model (units um^2/s)
            D_Free2_3State = str2num(input_values{11}); % min/max Diffusion constant #2 for Free state in 3-state model (units um^2/s)
            D_Bound_3State = str2num(input_values{12}); % min/max Diffusion constant for Bound state in 3-state model (units um^2/s)            
            for i = 1:length(data) 
                data_to_send{i} = data{i};
                data_to_send{i}.LocError = LocError;
                data_to_send{i}.UseWeights = UseWeights;
                data_to_send{i}.ModelFit = ModelFit;
                data_to_send{i}.FitLocError = FitLocError;
                data_to_send{i}.NumberOfStates = NumberOfStates;
                data_to_send{i}.FitLocErrorRange = FitLocErrorRange;
                data_to_send{i}.FitIterations = FitIterations;
                data_to_send{i}.D_Free_2State = D_Free_2State;
                data_to_send{i}.D_Bound_2State = D_Bound_2State;
                data_to_send{i}.D_Free1_3State = D_Free1_3State;
                data_to_send{i}.D_Free2_3State = D_Free2_3State;
                data_to_send{i}.D_Bound_3State = D_Bound_3State;
                f = waitbar(0,'Fitting');
                for j = 1:size(data_to_send{i}.JumpProb,1)                    
                    data_to_send{i} = ModelFitting_main(data_to_send{i},j);
                    data_to_send{i}.model_PDF_CDF(j,:) = GenerateModelFitforPlot(data_to_send{i}, j); 
                    waitbar(j/size(data_to_send{i}.JumpProb,1),f,'Fitting')
                end
                close(f)
            end
            spt_tracks_displacement_model_plot(data_to_send)
        end
    end
end

function spt_tracks_displacement_plot_inside(data,slider_one_value,slider_two_value)
JumpProb = data{slider_one_value}.JumpProb;
JumpProbCDF = data{slider_one_value}.JumpProbCDF;
HistVecJumps = data{slider_one_value}.HistVecJumps;
HistVecJumpsCDF = data{slider_one_value}.HistVecJumpsCDF;
name = data{slider_one_value}.name;

subplot(2,1,1)
ax = gca; cla(ax);
plot(HistVecJumps,JumpProb(slider_two_value,:),'b','linewidth',1)
xlabel('Displacement','interpreter','latex','FontSize',14)
ylabel('PDF (Counts)','interpreter','latex','FontSize',14)
title({'',['File Name = ',regexprep(name,'_',' ')],['Delay =',num2str(data{slider_one_value}.dT*slider_two_value)]},'interpreter','latex','fontsize',14)

subplot(2,1,2)
ax = gca; cla(ax);
plot(HistVecJumpsCDF,JumpProbCDF(slider_two_value,:),'b','linewidth',1)
xlabel('Displacement','interpreter','latex','FontSize',14)
ylabel('CDF','interpreter','latex','FontSize',14)
end