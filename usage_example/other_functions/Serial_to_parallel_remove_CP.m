function [Y_DT_OFDM] = Serial_to_parallel_remove_CP(r_OFDM, M_data, N, length_CP)

    Y_DT_OFDM = zeros(M_data, N);
    
    position = 1;
    
    for col = 1:N
        cp_and_column = r_OFDM(position:position + length_CP + M_data - 1);
        
        current_column = cp_and_column(length_CP + 1:end);
        
        Y_DT_OFDM(:, col) = current_column;
        
        position = position + length_CP + M_data;
    end
    
end