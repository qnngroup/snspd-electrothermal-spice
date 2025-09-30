function results = parse_spice_sweeps(filename)
% PARSE_SPICE_SWEEPS   Parse a multi‐run LTspice text export and reshape into a 2D grid.
%
%   results = parse_spice_sweeps_grid(filename) reads the entire text file
%   “filename” (exported from LTspice with multiple .step param runs).  It
%   locates each “Step Information:” line to extract the numeric values of
%   I_bias (in A) and R_load (in Ω).  Then it collects all the subsequent
%   numeric rows (time‐series) for that run.  At the end you get a struct:
%
%     results.I_bias    % 1×Nbias array of distinct I_bias (sorted, in amperes)
%     results.R_load    % 1×Nload array of distinct R_load (sorted, in ohms)
%     results.data      % Nload×Nbias cell array
%
%   Each cell results.data{r,c} is an M×4 double matrix whose columns are:
%       [ time, V(u1:n_state), V(u1:tsub), abs(I(u1:L_kinetic)) ]
%   for the run where
%       I_bias = results.I_bias(c)  and  R_load = results.R_load(r).
%
%   Example usage:
%       res = parse_spice_sweeps_grid('sim_output.txt');
%       % Then res.I_bias might be [7.4e-6, 7.6e-6, 7.8e-6, 8.0e-6, 8.2e-6]
%       % and    res.R_load might be [140, 150, 160, 170, 180, 190, 200]
%       % To get the time‐series for I_bias=7.8e-6, R_load=160, do:
%       iB = 7.8e-6;    iR = 160;
%       idxB = find(abs(res.I_bias - iB)<1e-12,1);
%       idxR = find(res.R_load == iR,1);
%       M = res.data{idxR, idxB};  % M is M×4: [time, n_state, tsub, I_Lkinetic_abs]
%

    if nargin<1
        error('You must supply the name of the text file, e.g. parse_spice_sweeps_grid(''sim_output.txt'').');
    end

    fid = fopen(filename,'r');
    if fid<0
        error('Could not open file "%s".', filename);
    end

    %----------------------------------------------------------------------
    % First pass: Collect a temporary struct array “runs(k)”:
    %   runs(k).I_bias  = (scalar, in A)
    %   runs(k).R_load  = (scalar, in Ω)
    %   runs(k).data    = M_k×4 matrix of [ time, V(n_state), V(tsub), abs(I_Lkinetic) ]
    % We will dynamically append rows to runs(k).data as we read numeric lines.
    %----------------------------------------------------------------------
    runs = struct('I_bias', {}, 'R_load', {}, 'data', {}); 
    runCount   = 0;
    haveHeader = false;
    colIndex   = struct();  % will hold .time, .n_state, .tsub, .Lkin once we see the “time …” header

    % define regex patterns to extract I_bias and R_load from the “Step Information” line:
    %   we expect something like “Step Information: I_bias=7.4µ R_load=100  (Run: 1/36)”
    % so:
    biasPattern  = 'I_bias\s*=\s*([0-9]*\.?[0-9]+)\s*µ';
    rloadPattern = 'R_load\s*=\s*([0-9]*\.?[0-9]+)';

    %----------------------------------------------------------------------
    % Loop over each line
    %----------------------------------------------------------------------
    while ~feof(fid)
        thisLine = fgetl(fid);
        if isempty(thisLine)
            continue
        end

        % 1) Detect the header line that begins with “time”
        if strncmp(thisLine,'time',4)
            tokens = regexp(thisLine,'\s+','split');
            colIndex.time    = find(strcmp(tokens,'time'),1);
            colIndex.n_state = find(strcmp(tokens,'V(u1:n_state)'),1);
            colIndex.tsub    = find(strcmp(tokens,'V(u1:t)'),1);
            colIndex.Lkin    = find(strcmp(tokens,'abs(I(u1:L_kinetic))'),1);
            if isempty(colIndex.time) || isempty(colIndex.n_state) || ...
               isempty(colIndex.tsub)  || isempty(colIndex.Lkin)
                fclose(fid);
                error(['Could not find all required column names in header. ' ...
                       'Make sure the header line exactly contains:' newline ...
                       '  time    V(u1:n_state)    V(u1:t)    abs(I(u1:L_kinetic))']);
            end
            haveHeader = true;
            continue
        end

        % 2) Detect “Step Information:” line
        if startsWith(strtrim(thisLine),'Step Information:')
            if ~haveHeader
                fclose(fid);
                error('Found "Step Information" before any header. Check file format.');
            end
            runCount = runCount + 1;

            % Extract numeric I_bias (in A) and R_load (in Ω) using regexp
            ts = regexp(thisLine, biasPattern, 'tokens');
            if isempty(ts)
                fclose(fid);
                error('Could not parse I_bias value from line: %s', thisLine);
            end
            Ival = str2double(ts{1}{1}) * 1e-6;  % convert “7.4” → 7.4e-6 A

            ts2 = regexp(thisLine, rloadPattern, 'tokens');
            if isempty(ts2)
                fclose(fid);
                error('Could not parse R_load value from line: %s', thisLine);
            end
            Rval = str2double(ts2{1}{1});        % R_load in Ω

            % Initialize runs(runCount) with these values and an empty 0×4 data matrix
            runs(runCount).I_bias = Ival;
            runs(runCount).R_load = Rval;
            runs(runCount).data   = zeros(0,4);
            continue
        end

        % 3) If we have already started a run (runCount>0) and seen a header, parse numeric rows
        if runCount>0  &&  haveHeader
            trimmed = strtrim(thisLine);
            if isempty(trimmed)
                continue
            end
            c0 = trimmed(1);
            if (c0>='0' && c0<='9') || c0=='-' || c0=='.'
                % Parse all floating‐point numbers in this line
                nums = sscanf(trimmed, '%f');
                if numel(nums) < max([colIndex.time, colIndex.n_state, colIndex.tsub, colIndex.Lkin])
                    fclose(fid);
                    error('Numeric line has fewer columns than expected. Check format.');
                end
                % Extract the four columns we want:
                row4 = [ ...
                    nums(colIndex.time)*10^9, ...
                    nums(colIndex.n_state), ...
                    nums(colIndex.tsub), ...
                    nums(colIndex.Lkin) ...
                ];
                % Append to the current run’s data
                runs(runCount).data(end+1, :) = row4;
            end
        end
        % otherwise ignore
    end

    fclose(fid);

    if runCount==0
        error('No “Step Information:” blocks found. Are you sure the file has .step sweeps?');
    end

    %----------------------------------------------------------------------
    % Now we have a struct array “runs(1:runCount)”, each with fields:
    %   runs(k).I_bias
    %   runs(k).R_load
    %   runs(k).data    (M_k×4 matrix)
    %
    % Next: extract unique lists of I_bias and R_load, sort them, and build a
    % 2D cell array “data{ r_index, c_index } = runs(k).data”.
    %----------------------------------------------------------------------

    allBias  = [runs.I_bias];
    allRload = [runs.R_load];

    uniqueBias  = unique(allBias, 'sorted');
    uniqueRload = unique(allRload, 'sorted');

    Nb = numel(uniqueBias);
    Nr = numel(uniqueRload);

    % Prepare the 2D cell array
    dataGrid = cell(Nr, Nb);

    % For each run, find its row/col indices
    for k = 1:runCount
        bval = runs(k).I_bias;
        rval = runs(k).R_load;
        cidx = find(abs(uniqueBias - bval) < 1e-12, 1);
        ridx = find(uniqueRload == rval,        1);
        if isempty(cidx) || isempty(ridx)
            error('Could not locate run %d in the bias/load grid (this should not happen).', k);
        end
        dataGrid{ridx, cidx} = runs(k).data;
    end

    % Return results
    results.I_bias = uniqueBias;   % 1×Nb (in A)
    results.R_load = uniqueRload;  % 1×Nr (in Ω)
    results.data   = dataGrid;     % Nr×Nb cell array

    fprintf('Parsed %d runs.\n', runCount);
    fprintf('Found %d distinct I_bias values and %d distinct R_load values.\n', Nb, Nr);
    fprintf('results.I_bias = [ %s ] (in A)\n', sprintf('%.3g ', uniqueBias));
    fprintf('results.R_load = [ %s ] (in Ω)\n', sprintf('%g ', uniqueRload));
    fprintf('The cell array results.data is %d×%d, with rows=R_load, cols=I_bias.\n', Nr, Nb);
end
