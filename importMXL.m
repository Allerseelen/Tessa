% Christopher Apfelbach


function importMXL(input_xml, output_filename)

%==========================================================================
              
    % ACQUIRES MAIN MATLAB STRUCTURE FILE     
        
        % Parses XML structure
        temporary_struct = parseXML(input_xml);

        % Saves parsed MatLab struct file to filename specified by user
        output_filename = strcat(output_filename, '.mat');
        save(output_filename, 'temporary_struct');
        
end