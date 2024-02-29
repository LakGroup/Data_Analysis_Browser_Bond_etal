function data_load = spt_simulate_directed_brownian_motion()
input_values = inputdlg({'number of particles:','time step:','number of time steps:','diffusion coefficient: (um^2/s)','size:','mean velocity (um/s)'},'',1,{'10','0.05','100','0.001','2','0.05'});
if isempty(input_values)==1
    data_load = [];
else
    num_of_particles = str2double(input_values{1});
    dt = str2double(input_values{2});
    num_of_dt = str2double(input_values{3});
    dim = 2;
    D = str2double(input_values{4});
    size_motion = str2double(input_values{5});
    v_m = str2double(input_values{6});
    k = sqrt(2*D*dt);    
    t = (0:num_of_dt-1)'*dt;    
    for i = 1:num_of_particles
        theta = 2 * pi * rand;        
        v = v_m*(1+1/4*randn);
        dX_brownian = k*randn(num_of_dt, 2);
        dX_directed = v*dt*[cos(theta)*ones(num_of_dt,1) sin(theta)*ones(num_of_dt,1)];
        dX = dX_brownian + dX_directed;        
        X0 = size_motion*rand(1, dim);        
        dX(1,:) = X0;
        X = cumsum(dX, 1);
        trajectory{i,1} = [t X];       
    end
    data_load{1}.tracks = trajectory;
    data_load{1}.name = 'Simulated_Directed_Brownian_Motion';
    data_load{1}.type = 'spt';
end
end