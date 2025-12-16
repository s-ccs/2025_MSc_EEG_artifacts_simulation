Scripts etc. - everything that runs something on its own and is not a function, goes here. Pluto notebook filenames are prefixed with `nb_`.

- nb_artifacts_tutorial.jl - Notebook containing a sample simulation of artifacts using UnfoldSimArtifacts code (i.e. code developed for this thesis) and some plots to explore the individual artifacts as well as final simulated data. This uses a dev version of UnfoldSim containing the artifact simulation. Section 1 walks through simulating EEG with noise and all three artifacts, Section 2 contains code for saving/reading the simulation results to/from a file in order to skip simulating data from scratch if you just want to inspect the data without changing simulation parameters. 

- nb_eeg_import.jl - Notebook to import and explore data from a [combined EEG+Eye-Tracking dataset](https://github.com/s-ccs/2024FreeViewingMSCOCO). Not actively used. 


Other files required in order to run the scripts/notebooks:

- `combined_eeg_artifacts`, `signal`, `pln` - simulated EEG and artifact data, saved to a file after simulating once, in order to easily load and inspect it later without having to re-run the simulation each time.

- `HArtMuT_NYhead_*.mat` - Eye-source-point head-models based on HArtMuT, having the shape of the eyeballs being modified to be more spherical. 

- `clipped_data_2025-07-16-pm.csv` - a snippet of data from the previously mentioned combined dataset. It contains synchronized Eye-tracking and EEG data, with one row corresponding to one channel. The first seven channels are eye-tracking channels; channels 1-7: x/y left, pupil left, x/y right, pupil right, DIN. The remaining channels contain the corresponding EEG data.


