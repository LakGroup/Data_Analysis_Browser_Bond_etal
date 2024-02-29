function [classes,classes_new] = check_classes_in_bubble(classes,classes_grouped)
bubble_center = mean(classes_grouped{1,2},1);
bubble_max = max(classes_grouped{1,2})-bubble_center;
bubble_min = min(classes_grouped{1,2})-bubble_center;
bubble_max = bubble_max(:,[1,7:8]);
bubble_min = bubble_min(:,[1,7:8]);

to_check = classes(:,3);
to_check = vertcat(to_check{:});
to_check = to_check-bubble_center;
to_check = to_check(:,[1,7:8]);

I = zeros(size(to_check,1),1);
for i = 1:size(to_check,1)
    I(i) = all(to_check(i,:)<=bubble_max & to_check(i,:)>=bubble_min);
end
I = find(I==1);

if isempty(I)==1
    classes_new = classes_grouped;
else
    new_group = group_classes(I,classes);
    classes(I,:) = [];
    classes_grouped = vertcat(new_group,classes_grouped);
    classes_new = group_classes([1,2],classes_grouped);
end
end