function this_measure_notes = importMeasure(measure)

    % initialize variables
    this_measure_notes = {};
    
    % go through children of this part
    number_of_children = size(measure.Children, 2);
    
    for i_child = 1 : number_of_children
        this_child = measure.Children(i_child);
        if strcmp(this_child.Name, 'note')
            this_note = importNote(this_child);
            this_measure_notes = [this_measure_notes; this_note];
        elseif strcmp(this_child.Name, 'attributes')
            importAttribute(this_child);
        end
    end
end