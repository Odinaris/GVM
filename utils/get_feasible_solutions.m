function feasible_solutions = get_feasible_solutions(num_unused, possible_solutions, U, S)
%GET_FEASIBLE_SOLUTIONS get the fesible solution space according to the max
%num of unused VLCs U for each used VLC and the num of selected peak bins S. 
feasible_solutions = possible_solutions(:,1:S);
feasible_solutions = feasible_solutions(feasible_solutions(:,1) <= (2^U-1),:);
feasible_solutions = feasible_solutions(sum(feasible_solutions,2) <= num_unused,:);
feasible_solutions = unique(feasible_solutions,'rows');
end

