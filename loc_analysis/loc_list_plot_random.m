function loc_list_plot_random(data)
I = randperm(length(data),10);
data_to_plot = data(I);
figure()
set(gcf,'name','Random Plot','NumberTitle','off','color','w','units','normalized','outerposition',[0.2 0.2 0.7 0.7],'menubar','none','toolbar','figure');
subplot = @(m,n,p) subtightplot (m, n, p, [0 0], [0.08 0.08], [0 0]);
subplot(1,1,1)
dx = 5;
dy = 5;
delta_x = -dx;
for i = 1:5
    [~,cluster] = pca([data_to_plot{i}.x_data,data_to_plot{i}.y_data]);
    hold on
    delta_x = delta_x+dx;    
    cluster(:,1) = cluster(:,1) + delta_x;
    cluster(:,2) = cluster(:,2);
    data_final{i} = cluster;
    if data_to_plot{i}.area(1) == 1
        scatter(cluster(:,1),cluster(:,2),1,'m','filled')
    elseif data_to_plot{i}.area(1) == -1
        scatter(cluster(:,1),cluster(:,2),1,'b','filled')
    else
        scatter(cluster(:,1),cluster(:,2),1,'g','filled')
    end
    axis equal
    axis off
    clear cluster
end

delta_x = -dx;
for i = 6:10
    [~,cluster] = pca([data_to_plot{i}.x_data,data_to_plot{i}.y_data]);
     
    delta_x = delta_x+dx;  
    cluster(:,1) = cluster(:,1) + delta_x;
    cluster(:,2) = cluster(:,2) + dy;
    data_final{i} = cluster;
    if data_to_plot{i}.area(1) == 1
        scatter(cluster(:,1),cluster(:,2),1,'m','filled')
    elseif data_to_plot{i}.area(1) == -1
        scatter(cluster(:,1),cluster(:,2),1,'b','filled')
    else
        scatter(cluster(:,1),cluster(:,2),1,'g','filled')
    end
    axis equal
    axis off
    clear cluster
end
data_final = vertcat(data_final{:});


pixel_size = 116;
scale_bar_size = 1;
ax_lim = get(gca,'XLim');
ax_position = get(gca,'Position');
data_x_lim = [min(data_final(:,1)) max(data_final(:,1))];

%find a and b for linear equation
a = (ax_lim(1)-ax_lim(2))/(ax_position(1)-(ax_position(3)+ax_position(1)));
b = ax_lim(1)-a*ax_position(1);

x_initial = (data_x_lim(1)-b)/a;
x_final = (data_x_lim(2)-b)/a;
x_size = x_final-x_initial;
pixels = data_x_lim(2)-data_x_lim(1);
pixels_um = pixels*pixel_size/1000;
size_bar = scale_bar_size*x_size/pixels_um;
annotation('textbox',[x_initial 0.01  size_bar 0.025],'units','pixels','string',[num2str(scale_bar_size),' um'],'Backgroundcolor','w','color','k','Margin',1)

end

function h=subtightplot(m,n,p,gap,marg_h,marg_w,varargin)
%function h=subtightplot(m,n,p,gap,marg_h,marg_w,varargin)
%
% Functional purpose: A wrapper function for Matlab function subplot. Adds the ability to define the gap between
% neighbouring subplots. Unfotrtunately Matlab subplot function lacks this functionality, and the gap between
% subplots can reach 40% of figure area, which is pretty lavish.  
%
% Input arguments (defaults exist):
%   gap- two elements vector [vertical,horizontal] defining the gap between neighbouring axes. Default value
%            is 0.01. Note this vale will cause titles legends and labels to collide with the subplots, while presenting
%            relatively large axis. 
%   marg_h  margins in height in normalized units (0...1)
%            or [lower uppper] for different lower and upper margins 
%   marg_w  margins in width in normalized units (0...1)
%            or [left right] for different left and right margins 
%
% Output arguments: same as subplot- none, or axes handle according to function call.
%
% Issues & Comments: Note that if additional elements are used in order to be passed to subplot, gap parameter must
%       be defined. For default gap value use empty element- [].      
%
% Usage example: h=subtightplot((2,3,1:2,[0.5,0.2])
if (nargin<4) || isempty(gap),    gap=0.01;  end
if (nargin<5) || isempty(marg_h),  marg_h=0.05;  end
if (nargin<5) || isempty(marg_w),  marg_w=marg_h;  end
if isscalar(gap),   gap(2)=gap;  end
if isscalar(marg_h),  marg_h(2)=marg_h;  end
if isscalar(marg_w),  marg_w(2)=marg_w;  end
gap_vert   = gap(1);
gap_horz   = gap(2);
marg_lower = marg_h(1);
marg_upper = marg_h(2);
marg_left  = marg_w(1);
marg_right = marg_w(2);
%note n and m are switched as Matlab indexing is column-wise, while subplot indexing is row-wise :(
[subplot_col,subplot_row]=ind2sub([n,m],p);  
% note subplot suppors vector p inputs- so a merged subplot of higher dimentions will be created
subplot_cols=1+max(subplot_col)-min(subplot_col); % number of column elements in merged subplot 
subplot_rows=1+max(subplot_row)-min(subplot_row); % number of row elements in merged subplot   
% single subplot dimensions:
%height=(1-(m+1)*gap_vert)/m;
%axh = (1-sum(marg_h)-(Nh-1)*gap(1))/Nh; 
height=(1-(marg_lower+marg_upper)-(m-1)*gap_vert)/m;
%width =(1-(n+1)*gap_horz)/n;
%axw = (1-sum(marg_w)-(Nw-1)*gap(2))/Nw;
width =(1-(marg_left+marg_right)-(n-1)*gap_horz)/n;
% merged subplot dimensions:
merged_height=subplot_rows*( height+gap_vert )- gap_vert;
merged_width= subplot_cols*( width +gap_horz )- gap_horz;
% merged subplot position:
merged_bottom=(m-max(subplot_row))*(height+gap_vert) +marg_lower;
merged_left=(min(subplot_col)-1)*(width+gap_horz) +marg_left;
pos_vec=[merged_left merged_bottom merged_width merged_height];
% h_subplot=subplot(m,n,p,varargin{:},'Position',pos_vec);
% Above line doesn't work as subplot tends to ignore 'position' when same mnp is utilized
h=subplot('Position',pos_vec,varargin{:});
if (nargout < 1),  clear h;  end
end