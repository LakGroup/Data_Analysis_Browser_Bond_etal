function spt_log_log_plot(data)
for i = 1:length(data)
    temp = data{i}.msd; 
    for k=1:length(temp)
        temp_temp_x = real(log(temp{k}(:,1)));
        temp_temp_y = real(log(temp{k}(:,2)));
        
        I = temp_temp_x==Inf;
        temp_temp_x(I) = [];
        temp_temp_y(I) = [];
        
        I = temp_temp_x==-Inf;
        temp_temp_x(I) = [];
        temp_temp_y(I) = [];
        
        I = temp_temp_y==Inf;
        temp_temp_x(I) = [];
        temp_temp_y(I) = [];
        
        I = temp_temp_y==-Inf;
        temp_temp_x(I) = [];
        temp_temp_y(I) = [];

        temp{k} = [];
        temp{k}(:,1) = temp_temp_x;
        temp{k}(:,2) = temp_temp_y;
        clear temp_temp_x temp_temp_y
    end    
    data{i}.msd = temp;
    clear temp
end
spt_plot(data);
end