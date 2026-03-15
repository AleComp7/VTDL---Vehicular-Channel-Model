# VTDL---Vehicular-Channel-Model

This repository contains the MATLAB code for the VTDL channel model and can be used to simulate multipath channels in high-mobility vehicular scenarios.

VTDL is a tapped delay line channel model specifically designed for vehicular communications and, despite being simple to implement, its parameters have been derived from extensive simulations of geometry-based stochastic models, considering multiple traffic scenarios and road geometries. The parameters used to model the reflected power of multipath components have been derived by considering the bistatic radar cross sections of the reflecting vehicles. Unlike independent tapped delay line models, our model tracks the correlation between reflections, particularly in the Doppler domain. This aspect is particularly relevant when evaluating OTFS, since its performance can be overestimated if independent paths are assumed. For more details please refer to our paper (see below).

**How to Use This Code**

In the **VTDL** folder, you will find all the files required to implement the channel model.

In the **usage_example** folder, you will instead find a ready-to-run example showing how the model can be used to compare the performance of OTFS and OFDM modulation schemes in vehicular scenarios.

**Important**

If you use this channel model for your research, please cite our work as:


A. Compagnoni, R. Tuninato, C. F. Chiasserini, R. Garello, A. Nordio and E. Viterbo,
"A Highway Vehicular Channel Model for OTFS Performance Evaluation,"
in IEEE Transactions on Communications, vol. 74, pp. 5074-5088, 2026, 
doi: 10.1109/TCOMM.2026.3663522

BibTex:

@ARTICLE{11390681,
  author={Compagnoni, A. and Tuninato, R. and Chiasserini, C. F. and Garello, R. and Nordio, A. and Viterbo, E.},
  journal={IEEE Transactions on Communications}, 
  title={A Highway Vehicular Channel Model for OTFS Performance Evaluation}, 
  year={2026},
  volume={74},
  number={},
  pages={5074-5088},
  doi={10.1109/TCOMM.2026.3663522}}
