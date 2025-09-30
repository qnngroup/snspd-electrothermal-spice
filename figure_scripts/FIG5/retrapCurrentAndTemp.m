function [I_R, T_R] = retrapCurrentAndTemp(data)
% row 2 of data is N_state, row 3 is temp, row 4 is current

N_state = data(:,2);

i_one = find(N_state==1, 1, 'first');
if isempty(i_one)
    error('No row has column 2 exactly equal to 1.');
end

i_zero_after = find( N_state(i_one+1:end) < 1, 1, 'first' );
if isempty(i_zero_after)
    % disp('Latched state.');
    I_R = 0;
    T_R = 0;
else

    % Because we searched from i_one+1, add i_one to get the absolute row index:
    i0 = i_one + i_zero_after - 1;

    I_R = data(i0,4);
    T_R = data(i0,3);

end
end