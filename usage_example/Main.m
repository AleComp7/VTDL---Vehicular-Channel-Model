%% Important
% If you use this channel model, please cite our work as

%{

A. Compagnoni, R. Tuninato, C. F. Chiasserini, R. Garello, A. Nordio and E. Viterbo,
"A Highway Vehicular Channel Model for OTFS Performance Evaluation,"
in IEEE Transactions on Communications, vol. 74, pp. 5074-5088, 2026, 
doi: 10.1109/TCOMM.2026.3663522

% BibTex:

@ARTICLE{11390681,
  author={Compagnoni, A. and Tuninato, R. and Chiasserini, C. F. and Garello, R. and Nordio, A. and Viterbo, E.},
  journal={IEEE Transactions on Communications}, 
  title={A Highway Vehicular Channel Model for OTFS Performance Evaluation}, 
  year={2026},
  volume={74},
  number={},
  pages={5074-5088},
  doi={10.1109/TCOMM.2026.3663522}}

%}

%% Simple example: comparison of OTFS and OFDM in highway scenarios

% We consider the traditional Cyclic-Prefix version of OFDM with MMSE
% single-tap equalization. 
% Concerning OTFS, we consider Zero-Padding version
% with MRC delay-time detection, as detailed in [2]

clc
clear
close all

addpath(genpath("other_functions"))
addpath(genpath("vtdl_functions"))

%% Simulation parameters
N_frame_max = 2000;          % maximum number of frames per simulation
Min_frame_errors = 100;      % stop the simulation once Min_frame_errors are collected
SNR_dB = [10, 15, 20, 25];
SNR_Training_Iters = 9e3;

%% Communication system parameters
M = 64;                      % number of subcarriers (delay bins for OTFS)
N = 64;                      % number of symbols per frame (Doppler bins for OTFS)
Delta_f = 30*10^3;           % subcarrier spacing (Hz)
f_c = 3.6*10^9;              % carrier frequency (Hz)
M_mod = 4;                   % QAM constellation size

%% MRC delay-time detection parameters (only for OTFS)
n_ite_MRC = 10;              % maximum number of MRC detector iterations

% damping parameter – reducing omega improves error performance
% at the cost of increased detector iterations
omega = 1;

if (M_mod == 64)
    omega = 0.25; % set omega to a smaller value for higher modulation orders
end

decision = 1;      % 1 = hard decision, 0 = soft decision
init_estimate = 1; % 1 = use TF single-tap estimate as initial estimate
% 0 = initialize the symbol estimates to 0 at the start of the MRC iterations
% (recommended for higher modulation orders such as 64-QAM or 256-QAM)

%% Initialize system parameters
Initialize_parameters_one;

B = M * Delta_f;        % bandwidth
Tf = N * (1 / Delta_f); % frame duration

%% Load VTDL channel parameters
VTDL = VTDL_setting(f_c);

% SNR training
CT = SNR_training(VTDL, B, Tf, SNR_Training_Iters);

% This computes a scaling factor CT such that E[||CT*h||^2] = 1
% Once E[||h||^2] = 1, the AVERAGE SNR defined
% in Eq. (41) of [1] becomes AVE_SNR = Es / sigma^2

%% Simulation
for iesn0 = 1:length(SNR_dB)

    frame_err_OFDM = 0;
    frame_err_OTFS = 0;

    for ifram = 1:N_frame_max

        %% Generate channel
        [P, ell, k, h] = Generate_delay_Doppler_channel(VTDL, B, Tf);
        h = CT * h;

        % High-mobility discrete-time channel generation
        L_set = unique(ell)';
        l_max = max(ell);

        % Eq. (14) in [R1]
        gs = Gen_discrete_time_channel(N, M, P, ell, k, h);

        length_CP_ZP = l_max; % CP length for OFDM / ZP length for OTFS
        Initialize_parameters_two;

        %% Generate random bits
        trans_info_bit = randi([0,1], N_syms_perfram * M_bits, 1);

        %% QAM modulation
        data = qammod(reshape(trans_info_bit, M_bits, N_syms_perfram), ...
                      M_mod, 'gray', 'InputType', 'bit');

        %% ===================== OFDM =====================

        % OFDM symbol placement on the frequency-time grid
        X_FT_OFDM = Generate_FT_data_grid_OFDM(data, M_data, N);

        % OFDM delay-time matrix
        X_DT_OFDM = Fm_OFDM' * X_FT_OFDM;

        % OFDM time-domain vector
        s_OFDM = Parallel_to_serial_add_CP(X_DT_OFDM, M_data, N, length_CP_ZP);

        %% ===================== OTFS =====================

        % OTFS symbol placement on the delay-Doppler grid
        X_DD = Generate_DD_data_grid_OTFS(M, N, data, data_grid);

        % OTFS delay-time matrix
        X_DT_OTFS = X_DD * Fn';

        % OTFS time-domain vector
        s_OTFS = reshape(X_DT_OTFS, N*M, 1);

        %% Channel output (discrete-time domain)

        r_OFDM = zeros(N*M,1);
        r_OTFS = zeros(N*M,1);

        for q = 1:N*M
            for l = (L_set + 1)

                if q >= l
                    r_OFDM(q) = r_OFDM(q) + gs(l,q) * s_OFDM(q-l+1);
                    r_OTFS(q) = r_OTFS(q) + gs(l,q) * s_OTFS(q-l+1);
                end

            end
        end

        %% AWGN
        w = sqrt(sigma_2(iesn0)/2) * ...
            (randn(size(s_OTFS)) + 1i*randn(size(s_OTFS)));

        %% ===================== OFDM Detection =====================

        % Perfect channel estimation
        Y_DT_OFDM = Serial_to_parallel_remove_CP(r_OFDM, M_data, N, length_CP_ZP);
        Y_FT_OFDM = Fm_OFDM * Y_DT_OFDM;

        H_ft_OFDM = Channel_estimation_FT(Y_FT_OFDM, X_FT_OFDM);

        % Add noise
        r_OFDM = r_OFDM + w;

        Y_DT_OFDM = Serial_to_parallel_remove_CP(r_OFDM, M_data, N, length_CP_ZP);
        Y_FT_OFDM = Fm_OFDM * Y_DT_OFDM;

        % MMSE equalization
        X_FT_OFDM_estimated = MMSE_FT(Y_FT_OFDM, H_ft_OFDM, sigma_2(iesn0));

        data_OFDM_estimated = reshape(X_FT_OFDM_estimated, size(data));

        est_bits_OFDM = reshape( ...
            qamdemod(data_OFDM_estimated, M_mod, 'gray', 'OutputType', 'bit'), ...
            N_bits_perfram, 1);

        %% OFDM error counting
        errors_OFDM = sum(xor(est_bits_OFDM, trans_info_bit));

        ave_error_OFDM = (ave_error_OFDM*(ifram-1) + errors_OFDM) / ifram;
        ave_TX_bits_OFDM = (ave_TX_bits_OFDM*(ifram-1) + length(trans_info_bit)) / ifram;

        BER_OFDM(iesn0) = ave_error_OFDM / ave_TX_bits_OFDM;

        if sum(errors_OFDM > 0)
            frame_err_OFDM = frame_err_OFDM + 1;
        end

        FER_OFDM(iesn0) = frame_err_OFDM / ifram;

        %% ===================== OTFS Detection =====================

        [nu_ml_tilda] = Gen_delay_time_channel_vectors(N, M, l_max, gs);

        X_FT_OTFS = Fm * X_DD * Fn';
        Y_DT_OTFS = reshape(r_OTFS, M, N);
        Y_FT_OTFS = Fm * Y_DT_OTFS;

        H_ft_OTFS = Channel_estimation_FT(Y_FT_OTFS, X_FT_OTFS);
        H_tf_OTFS = H_ft_OTFS.';

        r_OTFS = r_OTFS + w;

        [est_bits_OTFS, det_iters_MRC, ~] = ...
            MRC_delay_time_detector_original( ...
            N, M, M_data, M_mod, sigma_2(iesn0), data_grid, ...
            r_OTFS, H_tf_OTFS, nu_ml_tilda, L_set, ...
            omega, decision, init_estimate, n_ite_MRC);

        %% OTFS error counting
        errors_OTFS = sum(xor(est_bits_OTFS, trans_info_bit));

        ave_error_OTFS = (ave_error_OTFS*(ifram-1) + errors_OTFS) / ifram;
        ave_TX_bits_OTFS = (ave_TX_bits_OTFS*(ifram-1) + length(trans_info_bit)) / ifram;

        BER_OTFS(iesn0) = ave_error_OTFS / ave_TX_bits_OTFS;

        if sum(errors_OTFS > 0)
            frame_err_OTFS = frame_err_OTFS + 1;
        end

        FER_OTFS(iesn0) = frame_err_OTFS / ifram;

        %% Iteration statistics
        no_of_detetor_iterations_MRC(iesn0) = ...
            no_of_detetor_iterations_MRC(iesn0) + det_iters_MRC;

        avg_no_of_iterations_MRC(iesn0) = ...
            no_of_detetor_iterations_MRC(iesn0) / ifram;

        %% Display progress
        clc

        disp("OTFS Error frame: " + frame_err_OTFS + ...
             " over " + Min_frame_errors + ...
             " @SNR = " + SNR_dB(iesn0) + " dB ")

        disp("OTFS TX frame: " + ifram + " over " + N_frame_max)

        display(BER_OTFS,'BER')
        display(FER_OTFS,'FER')
        display(avg_no_of_iterations_MRC,'Average MRC detector iterations')

        disp("OFDM Error frame: " + frame_err_OFDM + ...
             " @SNR = " + SNR_dB(iesn0) + " dB ")

        disp("OFDM TX frame: " + ifram)

        display(BER_OFDM,'BER')
        display(FER_OFDM,'FER')

        if frame_err_OTFS >= Min_frame_errors
            break;
        end

    end

end

%% Plot results

figure(1)
semilogy(SNR_dB, BER_OTFS,'--x','LineWidth',2,'MarkerSize',8)
hold on
semilogy(SNR_dB, BER_OFDM,'--o','LineWidth',2,'MarkerSize',8)
grid on
xlabel('Average SNR (dB)')
ylabel('BER')
legend('OTFS','OFDM')
set(gca,'FontSize',13)
axis padded

figure(2)
semilogy(SNR_dB, FER_OTFS,'--x','LineWidth',2,'MarkerSize',8)
hold on
semilogy(SNR_dB, FER_OFDM,'--o','LineWidth',2,'MarkerSize',8)
legend('OTFS','OFDM')
grid on
xlabel('Average SNR (dB)')
ylabel('FER')
set(gca,'FontSize',13)
axis padded

 
%% references
%{

[1] Compagnoni, A., et al. 
"A Highway Vehicular Channel Model for OTFS Performance Evaluation." 
IEEE Transactions on Communications (2026).

[2] Thaj, Tharaj, and Emanuele Viterbo. 
"Low complexity iterative rake detector for orthogonal time frequency space modulation." 
2020 IEEE Wireless Communications and Networking Conference (WCNC). IEEE, 2020.

%}
