import mne
# from mne.datasets.eyelink import data_path
from mne.preprocessing.eyetracking import read_eyelink_calibration
from mne.viz.eyetracking import plot_gaze
import re
import numpy as np
import matplotlib.pyplot as plt

# ---------------------------------------------------
# mne tutorial
# et_fpath = "./_research/data/VP3/WLFO_subj3.asc"
# eeg_fpath = "./_research/data/VP3/preprocessed/3_ITW_WLFO_subj3_channelrejTriggersXensor.mat"

# mne sample dataset EEG+ET
# et_fpath = data_path(path="/store/users/marathe", update_path=True) / "eeg-et" / "sub-01_task-plr_eyetrack.asc"
# eeg_fpath = data_path(path="/store/users/marathe", update_path=True) / "eeg-et" / "sub-01_task-plr_eeg.mff"


# raw_et = mne.io.read_raw_eyelink(et_fpath, create_annotations=["saccades","blinks"])
# # raw_eeg = mne.io.read_raw_egi(eeg_fpath, events_as_annotations=True).load_data()
# raw_eeg = mne.io.read_raw_eeglab(eeg_fpath).load_data()
# raw_eeg.filter(1, 30)

# print(raw_et.annotations[0]["ch_names"]) # channel names will give an idea of which eye this event occurred in

# cals = read_eyelink_calibration(et_fpath)
# print(f"number of calibrations: {len(cals)}")
# first_cal = cals[0]  # let's access the first (and only in this case) calibration
# print(first_cal)

# first_cal["screen_resolution"] = (1920, 1080)
# first_cal["screen_size"] = (0.53, 0.3)
# first_cal["screen_distance"] = 0.9
# mne.preprocessing.eyetracking.convert_units(raw_et, calibration=first_cal, to="radians")
# mne.preprocessing.eyetracking.get_screen_visual_angle(first_cal)

# # make the pupil size traces legible when plotting raw data
# ps_scalings = dict(pupil=1e3)
# raw_et.plot(scalings=ps_scalings)

# extract events and sync the eeg and et data
# et_events = mne.find_events(raw_et, min_duration=0.01, shortest_event=1, uint_cast=True)
# eeg_events = mne.find_events(raw_eeg, stim_channel="DIN3")
# eeg_events = mne.find_events(raw_eeg)


# events_from_annot, event_dict = mne.events_from_annotations(raw_et)

# # Convert event onsets from samples to seconds
# et_flash_times = et_events[:, 0] / raw_et.info["sfreq"]
# eeg_flash_times = eeg_events[:, 0] / raw_eeg.info["sfreq"]
# # Align the data
# mne.preprocessing.realign_raw(
#     raw_et, raw_eeg, et_flash_times, eeg_flash_times, verbose="error"
# )
# # Add EEG channels to the eye-tracking raw object
# raw_et.add_channels([raw_eeg], force_update_info=True)

# events_from_annot, event_dict = mne.events_from_annotations(raw_et)
# del raw_eeg  # free up some memory

# # Define a few channel groups of interest and plot the data
# frontal = ["E19", "E11", "E4", "E12", "E5"]
# occipital = ["E61", "E62", "E78", "E67", "E72", "E77"]
# pupil = ["pupil_right"]

# eye_chan = ["E1","E33", "E8", "E26"]
# # picks must be numeric (not string) when passed to `raw.plot(..., order=)`
# picks_idx = mne.pick_channels(
#     raw_et.ch_names, eye_chan + pupil, ordered=True
# )
# raw_et.plot(
#     events=et_events,
#     event_id=event_dict,
#     event_color="g",
#     order=picks_idx,
#     scalings=ps_scalings,
# )

# # extract epochs around saccades
# epochs = mne.Epochs(
#     raw_et, events=events_from_annot, event_id=event_dict, tmin=-0.3, tmax=3, baseline=None
# )
# epochs.plot(
#     events=events_from_annot, event_id=event_dict, order=picks_idx, scalings=ps_scalings
# )

# mne.export.export_epochs("mne-sampledata-saccades-epochs-test.set", epochs)

# ---------------------------------------------

# sync-code adapted from s-ccs/mne-bids-pipeline fork: temp_dev branch


# mscoco dataset
et_fpath = "/home/marathe/Documents/2025_MSc_EEG_artifacts_simulation/_research/data/2024FreeViewingMSCOCO/sub-030/ses-001/beh/sub-030_ses-001_task-Default_run-001_sub_30.asc"
eeg_fpath = "/home/marathe/Documents/2025_MSc_EEG_artifacts_simulation/_research/data/2024FreeViewingMSCOCO/sub-030/ses-001/eeg/sub-030_ses-001_task-2024FreeViewingMSCOCO_eeg.set"

# raw_et = mne.io.read_raw_eyelink(et_fpath, find_overlaps=True)
raw_eeg_loaded = mne.io.read_raw_eeglab(eeg_fpath).load_data()
chan_list = ["AF7","AF8", "Fpz", "FT9", "FT10", "HEOGL", "HEOGR", "VEOGU", "VEOGL"] # missing:  "FFT10h", "FFT9h", "CPz", "F9", "F10" from hartmut.
# raw_eeg.pick_channels(raw_eeg.info["ch_names"], include=chan_list)
raw_eeg = raw_eeg_loaded.copy().pick(chan_list)
# raw_eeg.filter(1, 30)

raw_et_loaded = mne.io.read_raw_eyelink(et_fpath, find_overlaps=True) #, create_annotations=["saccades","blinks"]
raw_et_new = raw_et_loaded.copy()
regex_sync = '.*trigger=02.*' # pick stimulus presentation (trigger id 02) events
et_sync_times = [annotation["onset"] for annotation in raw_et_new.annotations if re.search(regex_sync,annotation["description"])]
# et_sync_times
sync_times    = [annotation["onset"] for annotation in raw_eeg.annotations    if re.search(regex_sync,   annotation["description"])]
assert len(et_sync_times) == len(sync_times),f"Detected eyetracking and EEG sync events were not of equal size ({len(et_sync_times)} vs {len(sync_times)}). Adjust your regular expressions via 'sync_eventtype_regex_et' and 'sync_eventtype_regex' accordingly"

# # finding trigger events: stimulus event shown
# ev_trigger, event_dict2 = mne.events_from_annotations(raw_eeg, regexp="1-trigger=02")

# RuntimeWarning: Channel(s) xpos_left, ypos_left, pupil_left, xpos_right, ypos_right, pupil_right, DIN in `other` contain NaN values. Resampling these channels will result in the whole channel being NaN. (If realigning eye-tracking data, consider using interpolate_blinks and passing interpolate_gaze=True)
# so, try interpolating if we want to resample.

mne.preprocessing.realign_raw(raw_eeg, raw_et_new, sync_times, et_sync_times)

cals = read_eyelink_calibration(et_fpath)
print(f"number of calibrations: {len(cals)}")
first_cal = cals[0]

first_cal["screen_resolution"] = (1920, 1080)
first_cal["screen_size"] = (0.552, 0.307)
first_cal["screen_distance"] = 0.7
mne.preprocessing.eyetracking.convert_units(raw_et_new, calibration=first_cal, to="radians")
mne.preprocessing.eyetracking.get_screen_visual_angle(first_cal)

# Add ET data to EEG
# raw_eeg.add_channels([raw_et_new], force_update_info=True)
# raw_eeg._raw_extras.append(raw_et_new._raw_extras)

# Or: add EEG data to ET
raw_et_new.add_channels([raw_eeg], force_update_info=True)
raw_et_new._raw_extras.append(raw_eeg._raw_extras)

# plot just ET data
# raw_et_new.plot(start=60, duration=0.01, verbose='ERROR', decim=5, scalings='auto') # dict(pupil=1e3)


# inspect eyegaze data: descriptive statistics
data = raw_et.copy().pick('eyegaze')
eyepos_channels = ['xpos_left', 'ypos_left', 'xpos_right', 'ypos_right'] # picked using 'eyegaze'

mean = np.nanmean(data, axis=1)
median = np.nanmedian(data, axis=1)
std = np.nanstd(data, axis=1)
min_ = np.nanmin(data, axis=1)
max_ = np.nanmax(data, axis=1)


for i, ch in enumerate(eyepos_channels):
    print(f"--- {ch} ---")
    print(f"Mean:   {mean[i]:.2f}")
    print(f"Median: {median[i]:.2f}")
    print(f"Std:    {std[i]:.2f}")
    print(f"Min:    {min_[i]:.2f}")
    print(f"Max:    {max_[i]:.2f}")
    data1 = data[i, :]
    data1 = data1[~np.isnan(data1)]  # Remove NaNs
    plt.figure(figsize=(8, 4))
    plt.hist(data1, bins=100, color='skyblue', edgecolor='black')
    plt.title(f'Distribution of {ch}')
    plt.xlabel('Value')
    plt.ylabel('Frequency')
    plt.grid(True)
    plt.axvline(mean[i], color='red', linestyle='--', label=f'Mean: {mean[i]:.1f}')
    plt.axvline(median[i], color='green', linestyle=':', label=f'Median: {median[i]:.1f}')
    plt.legend()
    plt.tight_layout()
    plt.show()

# select channels of interest & plot 
# # chan_list = ["AF7","AF8", "Fpz", "F9", "F10", "HEOGL", "HEOGR", "VEOGU", "VEOGL"] 
# missing in the data:  "FFT10h", "FFT9h", "CPz",
# picks must be numeric (not string) when passed to `raw.plot(..., order=)`
picks_idx = mne.pick_channels(raw_eeg.ch_names, chan_list, ordered=True)
raw_eeg.plot(start=60, duration=1, verbose='ERROR', scalings=dict(pupil=1e3))# , picks=chan_list) #dict(pupil=1e3)

# saccade annotations -> create events
events_saccade, events_saccade_dict = mne.events_from_annotations(raw_et_new, regexp=".*sacc.*")

# extract epochs around saccades
epochs = mne.Epochs(
    raw_et_new, events=events_saccade, event_id=events_saccade_dict, tmin=-0.5, tmax=2, baseline=None
)
# epochs.plot(
#     events=events_saccade, event_id=event_dict, order=picks_idx, scalings=dict(pupil=1e3)
# )

mne.export.export_epochs("exported_epochs.set", epochs)
