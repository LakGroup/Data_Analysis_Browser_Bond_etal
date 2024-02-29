function data_simulated = loc_list_gaussian_point_pattern_simulation()
input_values = inputdlg({'Sigma Range:','Number of Gaussian Clusters:','Number of Points in Clusters:','Image Size:'},'',1,{'0 5','10','200','50'});
if isempty(input_values)==1
    data_simulated = [];
else
    sigma_input = str2num(input_values{1});
    N = str2num(input_values{2});
    M = str2num(input_values{3});  
    Size = str2num(input_values{4});  
    for i = 1:N
        sigma = [rand(1)*sigma_input(2) sigma_input(1); sigma_input(1) rand(1)*sigma_input(2)];
        mu = [rand(1)*Size rand(1)*Size];
        X{i}=mvnrnd(mu,sigma,M);
    end
    X = vertcat(X{:});
    data_simulated{1}.x_data = X(:,1);
    data_simulated{1}.y_data = X(:,2);
    data_simulated{1}.area = 0.7+zeros(length(X(:,1)),1);
    data_simulated{1}.name = 'rand_loc_list';
    data_simulated{1}.type = 'loc_list';  
end