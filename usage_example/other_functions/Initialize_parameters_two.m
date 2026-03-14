% data positions of OTFS/OFDM in the 2-D grid
M_data = M-length_CP_ZP;
data_grid=zeros(M,N);
data_grid(1:M_data,1:N) = 1;

% number of symbols per frame
N_syms_perfram = sum(sum(data_grid));
% number of bits per frame
N_bits_perfram = N_syms_perfram*M_bits;

est_info_bits = zeros(N_bits_perfram,1);

Fm_OFDM = dftmtx(M_data);
Fm_OFDM = Fm_OFDM./norm(Fm_OFDM);

