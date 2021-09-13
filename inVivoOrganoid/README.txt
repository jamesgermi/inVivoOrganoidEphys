inVivoOrganoidWrapper.m is the encompassing script to run the analysis

%LFP Analysis%
buildCSCstruct (/Users/jgermi/Documents/Perelman/MTR/ChenLab/Code/GermiToolbox) makes a structure with the CSC voltages, sample rates and timestamps for each CSC file using importCSC_JG.m (/Users/jgermi/Documents/Perelman/MTR/ChenLab/Code/GermiToolbox) which uses Nlx2MatCSC_v3 (/Users/jgermi/Documents/Perelman/MTR/ChenLab/Code/DataProcessing/releaseDec2015/binaries).

%Unit analysis%
buildUnitStruct (/Users/jgermi/Documents/Perelman/MTR/ChenLab/Code/GermiToolbox) creates a structure where unit_struct.Timestamp gives the timestamps of spikes, unit_struct.CellNumbers refers to unit number and unit_struct.DataPoints shows the plot of the AP. Each structure row refers to a tetrode. Datapoints are 32 x 4 x # of spikes. 32 refers to the time, 4 references the tetrode and the last dimension references different units. This code should be run on TT*_cells.ntt The code uses importTTs_v3 (/Users/jgermi/Documents/Perelman/MTR/ChenLab/Code/DataProcessing/Nadir/prep/ImportNLX_CodeV3/importTTs_v3.m) which calls NLx2MatCSC_v3 as above.

