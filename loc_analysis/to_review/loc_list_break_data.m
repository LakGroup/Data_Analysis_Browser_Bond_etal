function loc_list_break_data(data)
input_values = inputdlg({'X_axis Pile Size','Y_axis Pile Size'},'',1,{'10','10'});
if isempty(input_values)~=1
    x_axis_pile_size = str2double(input_values{1,1});
    y_axis_pile_size = str2double(input_values{2,1});
    data_break = cell(1,length(data));
    for i = 1:length(data)
        counter(1) = i;
        counter(2) = length(data);
        data_break{i} = loc_list_break_data_inside(data{i},x_axis_pile_size,y_axis_pile_size,counter);
    end
    data_break = horzcat(data_break{:});
    loc_list_plot(data_break)
end
end

function data_break = loc_list_break_data_inside(data,x_axis_pile_size,y_axis_pile_size,counter)
x_data = data.x_data;
y_data = data.y_data;
color = data.color;
area = data.area;

x_axis_no = ceil(max(x_data)/x_axis_pile_size);
y_axis_no = ceil(max(y_data)/y_axis_pile_size);
x_step = ceil(max(x_data))/x_axis_no;
y_step = ceil(max(y_data))/y_axis_no;

initial_x = 0;
initial_y = 0;
final_x = x_step;
final_y = y_step;

% figure()
% x = x_data;
% y = y_data;
% if length(x)>50000
%     x = downsample(x,ceil(length(x)/50000));
%     y = downsample(y,ceil(length(y)/50000));
% end
% scatter(x,y,1,'y','filled')
% hold on
% min_x = min(x_data);max_x = max(x_data);min_y = min(y_data);max_y = max(y_data);
% for n=1:x_axis_no
%     x_grid = min_x+(n-1)*x_step;
%     line([x_grid,x_grid],[min_y,max_y],'color','r')
% end
% for m=1:y_axis_no
%     y_grid = min_y+(m-1)*y_step;
%     line([min_x,max_x],[y_grid,y_grid],'color','r')
%     if x_axis_no*y_axis_no <= 20
%         text(x_grid+x_step/2,y_grid+y_step/2,strcat('{',num2str(n),',',num2str(m),'}'),'color','r','fontsize',12)
%     end
% end
% line([max_x,max_x],[min_y,max_y],'color','r')
% line([min_x,max_x],[max_y,max_y],'color','r')
% set(gca,'color','k');set(gcf,'color','k');axis off;axis equal


k = 0;
[x_sort,x_sort_idx] = sort(x_data);
[y_sort,y_sort_idx] = sort(y_data);
f=waitbar(0,['Breaking Data...',num2str(counter(1)),'/',num2str(counter(2))]);
for n=1:x_axis_no
    x_find = x_sort>=initial_x & x_sort<=final_x;
    for m=1:y_axis_no
        y_find = y_sort>=initial_y & y_sort<=final_y;
        I_find = intersect(x_sort_idx(x_find),y_sort_idx(y_find));
        if length(x_data(I_find))>1
            k = k+1;
            %square = [initial_x,initial_y;final_x,final_y;initial_x,final_y;final_x,initial_y];
            wanted(:,1) = x_data(I_find);
            wanted(:,2) = y_data(I_find);
            color_wanted = color(I_find);
            area_wanted = area(I_find);
            %color_square = [1,1,1,1];
            %color_wanted = cat(1,color_wanted,color_square');
            %wanted = cat(1,wanted,square);
            data_break{k}.x_data = wanted(:,1);
            data_break{k}.y_data = wanted(:,2);
            data_break{k}.color = color_wanted;
            data_break{k}.area = area_wanted;
            data_break{k}.name = [data.name,'_','{',num2str(n),',',num2str(m),'}'];
            data_break{k}.type = 'loc_list';
            clear wanted color_wanted area_wanted
        end
        initial_y = final_y;
        final_y = initial_y+y_step;
    end
    initial_y = 0;
    final_y = y_step;
    initial_x = final_x;
    final_x = initial_x+x_step;
    waitbar(n/x_axis_no,f,['Breaking Data...',num2str(counter(1)),'/',num2str(counter(2)),'...',num2str(n),'/',num2str(x_axis_no)]);
end
close(f)
end