function data_load = spt_simulate_confined_brownian_motion()
input_values = inputdlg({'number of particles:','time step:','number of time steps:','diffusion coefficient: (um^2/s)','size:','trap diameter (um)'},'',1,{'100','0.05','200','0.001','5','0.05'});
if isempty(input_values)==1
    data_load = [];
else
    num_of_particles = str2double(input_values{1});
    dt = str2double(input_values{2});
    num_of_dt = str2double(input_values{3});
    dim = 2;
    D = str2double(input_values{4});
    size_motion = str2double(input_values{5});
    Ltrap = str2double(input_values{6});
    k = sqrt(2*D*dt);    
    kT = 4.2821e-21;
    Ktrap = kT / Ltrap^2;
    t = (0 : num_of_dt-1)' * dt;
    for i = 1:num_of_particles
        X0 = size_motion .* rand(1, dim);        
        Fx = @(x) - Ktrap * (x - X0);        
        X = zeros(num_of_dt, dim);
        X(1, :) = X0;
        for j = 2 : num_of_dt            
            dxtrap = D/kT * Fx(X(j-1,:)) * dt; 
            dxbrownian = k * randn(1, dim);            
            X(j,:) = X(j-1,:) + dxtrap + dxbrownian;            
        end
        trajectory{i,1} = [t X];       
    end
    data_load{1}.tracks = trajectory;
    data_load{1}.name = 'Simulated_Confined_Brownian_Motion';
    data_load{1}.type = 'spt';    
end
end