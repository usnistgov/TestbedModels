function blkStruct = slblocks
% This function specifies that the library 'NistSmartGridLibrary'
% should appear in the Library Browser with the 
% name 'NistSmartGridLibrary'

    Browser.Library = 'NistSmartGridLibrary';
    % 'NistSmartGridLibrary' is the name of the library

    Browser.Name = 'NistSmartGridLibrary';
    % 'My Library' is the library name that appears
    % in the Library Browser

    blkStruct.Browser = Browser;
