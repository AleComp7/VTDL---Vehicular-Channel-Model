% bits per QAM symbol
M_bits = log2(M_mod);

% Average symbol energy
Es = ((M_mod==2)+(M_mod~=2)*sqrt((M_mod-1)/6*(2^2)))^2;  

% Initializing simulation count variables

current_frame_number=zeros(1,length(SNR_dB));
err_ber_OFDM = zeros(1,length(SNR_dB));
err_ber_OTFS = zeros(1,length(SNR_dB));
no_of_detetor_iterations_MRC= zeros(length(SNR_dB),1);
avg_no_of_iterations_MRC=zeros(1,length(SNR_dB));
FER_OFDM = zeros(1,length(SNR_dB));
FER_OTFS = zeros(1,length(SNR_dB));
BER_OFDM = zeros(1,length(SNR_dB));
BER_OTFS = zeros(1,length(SNR_dB));

ave_error_OFDM = 0;
ave_error_OTFS = 0;

ave_TX_bits_OFDM = 0;
ave_TX_bits_OTFS = 0;


% Normalized DFT matrix

 Fn=dftmtx(N);  
 Fn=Fn./norm(Fn);  

 Fm=dftmtx(M);  
 Fm=Fm./norm(Fm);  


% compute sigma_2 vector (E[||alpha||^2] = 1 is fixed)
SNR = 10.^(SNR_dB/10);
sigma_2 = Es ./ SNR;
