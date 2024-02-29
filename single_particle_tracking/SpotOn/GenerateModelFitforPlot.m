function model = GenerateModelFitforPlot(data_to_fit,j)
UseWeights = data_to_fit.UseWeights;
ModelFit = data_to_fit.ModelFit;
FitLocError = data_to_fit.FitLocError;
NumberOfStates = data_to_fit.NumberOfStates;
JumpsPerdT = data_to_fit.JumpsPerdT;
JumpProb = data_to_fit.JumpProb(j,:);
JumpProbCDF = data_to_fit.JumpProbCDF(j,:);
model_params = data_to_fit.best_vals(j,:);
%%%%%%%%%%%%%%%%%%%%%%%% GENERATE MODEL-FIT PDF %%%%%%%%%%%%%%%%%%%%%%%%%%%
 if ModelFit == 1 % force-change the global variable to PDF
    
    % calculate the model PDF using the input model params:
    if NumberOfStates == 2 && FitLocError == 0 % 2-state model, fixed Loc Error
        y = Model_2State(model_params, JumpProb, data_to_fit);
        
    elseif NumberOfStates == 2 && FitLocError == 1 % 2-state model, Loc Error from fitting
        y = Model_2State_fitLocError(model_params, JumpProb, data_to_fit);
        
    elseif NumberOfStates == 3 && FitLocError == 0 % 3-state model, fixed Loc Error
        y = Model_3State(model_params, JumpProb, data_to_fit);
        
    elseif NumberOfStates == 3 && FitLocError == 1 % 3-state model, Loc Error from fitting
        y = Model_3State_fitLocError(model_params, JumpProb, data_to_fit);
    end
    
    % Make model-output normalized PDF for plotting
    model = zeros(size(y,1), size(y,2));
    %Normalize y as a PDF
    for i=1:size(y,1)
        model(i,:) = y(i,:)./sum(y(i,:));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%% GENERATE MODEL-FIT CDF %%%%%%%%%%%%%%%%%%%%%%%%%%%
if ModelFit == 2    
    % calculate the model PDF using the input model params:
    if NumberOfStates == 2 && FitLocError == 0 % 2-state model, fixed Loc Error
        model = Model_2State(model_params, JumpProbCDF, data_to_fit);
        
    elseif NumberOfStates == 2 && FitLocError == 1 % 2-state model, Loc Error from fitting
        model = Model_2State_fitLocError(model_params, JumpProbCDF, data_to_fit);
        
    elseif NumberOfStates == 3 && FitLocError == 0 % 3-state model, fixed Loc Error
        model = Model_3State(model_params, JumpProbCDF, data_to_fit);
        
    elseif NumberOfStates == 3 && FitLocError == 1 % 3-state model, Loc Error from fitting
        model = Model_3State_fitLocError(model_params, JumpProbCDF, data_to_fit);
    end
    
    if UseWeights == 1
        %Normalize CDF to get rid of weighting
        for i=1:length(JumpsPerdT)
            model(i,:) = model(i,:)./JumpsPerdT(i);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model = model(1,:);
end