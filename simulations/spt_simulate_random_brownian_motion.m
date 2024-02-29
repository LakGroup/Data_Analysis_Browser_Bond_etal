function data_load = spt_simulate_random_brownian_motion()
input_values = inputdlg({'number of particles:','time step:','number of time steps:','diffusion coefficient: (um^2/s)','size:'},'',1,{'10','0.05','100','0.001','2'});
if isempty(input_values)==1
    data_load = [];
else
    num_of_particles = str2double(input_values{1});
    dt = str2double(input_values{2});
    num_of_dt = str2double(input_values{3});
    dim = 2;
    D = str2double(input_values{4});
    size_motion = str2double(input_values{5});
    k = sqrt(2*D*dt);    
    t = (0:num_of_dt-1)'*dt;    
    for i = 1:num_of_particles
        X0 = size_motion*rand(1, dim);
        dX = k * randn(num_of_dt, dim);
        dX(1,:) = X0;
        X = cumsum(dX, 1);
        trajectory{i,1} = [t X];       
    end
    data_load{1}.tracks = trajectory;
    data_load{1}.name = 'Simulated_Random_Brownian_Motion';
    data_load{1}.type = 'spt';
end
end