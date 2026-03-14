function [X_FT_OFDM_estimated] = single_tap_equalizer(Y_FT_OFDM, H_ft_OFDM)

    X_FT_OFDM_estimated = Y_FT_OFDM ./ H_ft_OFDM;
    
end