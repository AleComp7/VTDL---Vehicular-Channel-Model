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

%% V-TDL Vehicular traffic parameters

function [VTDL] = VTDL_setting(f_c) % use the carrier frequency f_c (in Hz) as input

% Set the following inputs according to your scenario
mu_d = 80;           % Average distance between vehicles (meters) lower distance implies higher traffic intensity
N_L = 3;             % Number of lanes per travel direction
DeltaTau = 4500;     % Delay Spread (nanoseconds). Here the delay spread is the difference between tha LoS delay and that of the last signal's replica.
v_max = 160;         % Maximum vehicles' velocity (km/h) 

%% Output
% The output of this code is a strcture named VTDL, with fields:

% P: the number of multipath components.

% pdp [Px1 double]: the power delay profile in dB, where pdp(1)= 0 dB is the LoS path, 
% pdp(j>1) represents the average power loss of path j w.r.t. the LoS path,
% expressed in dB.

% delays [Px1 double]: the average delay of different paths, expressed in
% nanoseconds, where delays(1) = 0 represents the delay of the LoS path.

% DopplerModel: this is a gmdistribution, and can be used to generate
% a Px1 random vector using random(VTDL.DopplerModel). The elements will
% represent the Doppler shifts of the different paths, expressed in KHz.

%%
f_c = f_c/10^9;      % Carrier frequency (GHz)

%% Number of paths (Eq. (26) and (27) in [1])
gamma_1 = 0.0070 * N_L^2 - 0.0563 * N_L - 0.0320;
gamma_2 = -1.6068 * N_L^2 + 14.1875 * N_L + 10.3568;
P = round(gamma_1 * mu_d + gamma_2);

%% Doppler shift of different paths

% Average Doppler shift of different paths (Eq. (12), (13), (14), (17)
% and (18) in [1])

p_1 = 3.063 * 10^-3;
p_2 = 1.180 * 10^-2;
p_3 = 7.214 * 10^-4;
p_4 = -1.576 * 10^-3;
p_5 = 1.227 * 10^-5;
p_6 = -1.977 * 10^-6;

a = p_1 + p_2*N_L + p_3*mu_d + p_4*N_L^2 + p_5*N_L*mu_d + p_6*mu_d^2;

% Average Doppler shift of LoS
mu_nu_1 = a*f_c;

alpha_1 = -(mu_nu_1)/(P^2-1)^2;
alpha_2 = -2*alpha_1;
alpha_3 = (mu_nu_1*P^2*(P^2-2))/(P^2-1)^2;

p_vec = 1:1:P;

% Mean vector (across paths) 
mu_nu = alpha_1 * p_vec.^4 + alpha_2 * p_vec.^2 + alpha_3; % KHz

% correlation coeffs.(Eq. (23) in [1])
beta_1 = 99*(P-1)^2 / 2401;
beta_2 = (P+1) / 2;

% Pearson correlation coefficients between the Doppler shift of different 
% paths and the LoS path (Eq. (21) in [1])
g_nu = 0.5 - (p_vec - beta_2) ./ sqrt(beta_1 + 4*(p_vec - beta_2).^2);

% Correlation matrix (Eq. (24) in [1])
Sigma_nu = zeros(P);
% Maximum Doppler shift (KHz)
nu_max = (10^6) * f_c * (v_max/3.6) / (3*10^8); 
variance = ((nu_max-mu_nu_1)/3)^2; % (from the 3*sigma rule)
for i=1:P
    for j=1:P

        if i==j
        
            Sigma_nu(i,j) = variance;
        
        elseif i==1 && j>1

            Sigma_nu(i,j) = variance*g_nu(j);

        elseif i>1 && j==1

            Sigma_nu(i,j) = variance*g_nu(i);

        else

            Sigma_nu(i,j) = variance*min(g_nu(i),g_nu(j));

        end

    end
end

% Compute the gmm model
gmm_Doppler = gmdistribution(mu_nu,Sigma_nu);

%% Average delays

% Average normalized derivative (Eq. (30) in [1])
D_bar = 7.7601; 

% Delay coefficients (Eq. 32 in [1])
epsilon_1 = exp((1/P) * (P * log(DeltaTau) + D_bar*(1-P)*log(P-1)));
epsilon_2 = D_bar*(P-1)/P;

% Delays (Eq. 28 in [1]) 
x = 1:P;
delays = epsilon_1*(x-1).^epsilon_2;


%% Average power across paths

% Eq. (36) in [1] 
b = -9.60e-7 * mu_d.^2 - 2.03e-5 * mu_d + 9.54e-2;
q = 8.10e-7 * mu_d.^2 + 3.45e-4 * mu_d - 1.20e-1;

% Eq. (35) in [1]
E_second = b*f_c + q;


% Eq. (39) in [1]
E_first = 1;
p = (2:P)';

D = (P - 2)*(P^2*((11/30)*(P+2))^2 - 4*P^2*((11/30)*(P+2)) + 4*P^2 ...
    - 2*P*((11/30)*(P+2))^3 + 8*P*((11/30)*(P+2))^2 - 8*P*((11/30)*(P+2)) ...
    + ((11/30)*(P+2))^4 - 4*((11/30)*(P+2))^3 + 4*((11/30)*(P+2))^2);

z1 = (4*0.0032 - 4*(1/6)*E_second - 4*0.0032*((11/30)*(P+2)) ...
    + 4*(1/6)*E_second*((11/30)*(P+2)) - P^2*E_second + P^2*(1/6)*E_second ...
    - E_second*((11/30)*(P+2))^2 + 0.0032*((11/30)*(P+2))^2 ...
    + 2*P*E_second*((11/30)*(P+2)) - 2*P*(1/6)*E_second*((11/30)*(P+2)))/D;

z2 = -(8*0.0032 - 8*(1/6)*E_second - P^3*E_second + P^3*(1/6)*E_second ...
    - 2*E_second*((11/30)*(P+2))^3 - 6*0.0032*((11/30)*(P+2))^2 ...
    + 2*0.0032*((11/30)*(P+2))^3 + 6*(1/6)*E_second*((11/30)*(P+2))^2 ...
    + 3*P*E_second*((11/30)*(P+2))^2 - 3*P*(1/6)*E_second*((11/30)*(P+2))^2)/D;

z3 = (16*0.0032*((11/30)*(P+2)) - 16*(1/6)*E_second*((11/30)*(P+2)) ...
    - E_second*((11/30)*(P+2))^4 - 12*0.0032*((11/30)*(P+2))^2 ...
    + 0.0032*((11/30)*(P+2))^4 + 12*(1/6)*E_second*((11/30)*(P+2))^2 ...
    + 3*P^2*E_second*((11/30)*(P+2))^2 - 3*P^2*(1/6)*E_second*((11/30)*(P+2))^2 ...
    - 2*P^3*E_second*((11/30)*(P+2)) + 2*P^3*(1/6)*E_second*((11/30)*(P+2)))/D;

z4 = -(- E_second*P^3*((11/30)*(P+2))^2 + 4*(1/6)*E_second*P^3*((11/30)*(P+2)) ...
    - 4*(1/6)*E_second*P^3 + 2*E_second*P^2*((11/30)*(P+2))^3 ...
    - 6*(1/6)*E_second*P^2*((11/30)*(P+2))^2 + 8*(1/6)*E_second*P^2 ...
    - E_second*P*((11/30)*(P+2))^4 + 12*(1/6)*E_second*P*((11/30)*(P+2))^2 ...
    - 16*(1/6)*E_second*P*((11/30)*(P+2)) + 2*0.0032*((11/30)*(P+2))^4 ...
    - 8*0.0032*((11/30)*(P+2))^3 + 8*0.0032*((11/30)*(P+2))^2)/D;

% Eq. (37) in [1]
J = z1*p.^3 + z2*p.^2 + z3*p + z4; % p=2,...,P
E_power_linear = [E_first;J];

% Eq. (40) in [1]
pdp = 10*log10(E_power_linear);

%% save outputs

VTDL.P = P;
VTDL.pdp = pdp;
VTDL.delays = delays';
VTDL.DopplerModel = gmm_Doppler;

% Other (non mandatory) outputs
%VTDL.mu_d = mu_d;
%VTDL.N_L = N_L;
%VTDL.DeltaTau = DeltaTau;
%VTDL.v_max = v_max;

