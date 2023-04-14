classdef bmmoDevbenchSFTPInterface < handle
%% <help_update_needed>
%  for the class and for the function
%
%      
    methods (Static)
        
        function rval = get_file_from_devbench(filename, machine_name, ip_address, targetdir)
            
            bmmoDevbenchSFTPInterface.verify_ip_address(ip_address);
            
            current_dir = cd(targetdir);
            dos_command = sprintf('sftp atl.%s@%s:%s', machine_name, ip_address, filename);
            rval = dos(dos_command);
            cd(current_dir);
        end
        
        function verify_ip_address(ip_address)
            [~, cmdout] = dos(['ssh-keyscan -t ecdsa ' ip_address]);
            
            [~, result] = dos(['ssh-keygen -l -F ' ip_address]);
            found_string = sprintf('Host %s found', ip_address);
            if ~contains(result, found_string)
            
                ecdsa_components = split(cmdout);
                ecdsa_string = strjoin(ecdsa_components(1:3), ' ');
                
                known_hosts_file = sprintf('c:\\users\\%s\\.ssh\\known_hosts', username);
                fd = fopen(known_hosts_file, 'a');
                fprintf(fd, '%s\n', ecdsa_string);
                fclose(fd);
            end            
        end   
    end
 end