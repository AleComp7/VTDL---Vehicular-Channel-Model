function [s_OFDM] = Parallel_to_serial_add_CP(X_DT_OFDM, M_data, N, length_CP)

    
    s_OFDM = zeros(N * (M_data + length_CP),1);
    
    position = 1;
    
    for col = 1:N
        current_column = X_DT_OFDM(:, col);
        
        cyclic_prefix = current_column(end-length_CP+1:end);
        
        s_OFDM(position:position+length_CP-1) = cyclic_prefix;
        s_OFDM(position+length_CP:position+length_CP+M_data-1) = current_column;
        
        position = position + length_CP + M_data;
    end
    
end
