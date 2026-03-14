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

function [CT] = SNR_training(VTDL,B,Tf,SNR_Training_Iters)

%% SNR_Training: Set a scaling factor CT such that E[||h||^2] = 1
 % This is used to set E[||h||^2] = 1, then the AVERAGE SNR defined
 % in Eq. (41) of [1], is simply given as AVE_SNR = Es/sigma^2
 % with Es being the average symbol energy and sigma^2 the noise variance

 % initialization
 CT = 1; 
 target_average_square_norm = 1;
 average_square_norm = 0;
     
 for iter = 1:SNR_Training_Iters

          [~,~,~,h] = Generate_delay_Doppler_channel(VTDL,B,Tf);
          
          h = CT*h;
          
          average_square_norm = ( average_square_norm*(iter-1) + norm(h/CT)^2)/iter;

          CT = sqrt(target_average_square_norm/average_square_norm);
          display(100*iter/SNR_Training_Iters,'SNR training phase (percentage)');     

  end

 % now E[||CT*h||^2] = 1 
 % verify it: 
 % CT^2 * average_square_norm

%% references
%{

[1] Compagnoni, A., et al. 
"A Highway Vehicular Channel Model for OTFS Performance Evaluation." 
IEEE Transactions on Communications (2026).

[2] Thaj, Tharaj, and Emanuele Viterbo. 
"Low complexity iterative rake detector for orthogonal time frequency space modulation." 
2020 IEEE Wireless Communications and Networking Conference (WCNC). IEEE, 2020.

%}