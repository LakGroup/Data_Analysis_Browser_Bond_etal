function to_group = find_groups(classes,parameters,link,coefficient_of_variation)
if length(link)>1
    i = 1;
    while true
        i = i+1;
        if i <= length(link)
            to_check = classes(link(1:i),2);
            to_check = vertcat(to_check{:});
            variation = abs(std(to_check,0,1)./mean(to_check,1));
            if any(variation>coefficient_of_variation)
                break
            end
        else
            break
        end
    end
end
to_group = link(1:i-1);
end