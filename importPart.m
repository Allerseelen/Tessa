function this_part_notes = importPart(part)

    % initialize variables
    this_part_notes = {};

    % go through children of this part
    number_of_children = size(part, 2);
    
    for i_child = 1 : number_of_children
        this_child = part(i_child);
        if strcmp(this_child.Name, 'measure')
            this_measure_notes = importMeasure(this_child);
            this_part_notes = [this_part_notes; this_measure_notes];
        end
    end
end