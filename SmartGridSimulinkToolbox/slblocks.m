function blkStruct = slblocks
        % This function specifies that the library should appear
        % in the Library Browser
        % and be cached in the browser repository
 
        Browser.Library = 'sgtoolbox';
        % 'sgtb_tlbx_v_1_0_demo' is the name of the library
 
        Browser.Name = 'Smart Grid Toolbox test';
        % 'NIST Smart Grid Testbed Toolbox' is the library name that appears 
             % in the Library Browser
 
        blkStruct.Browser = Browser; 
