import mne
# from mne.datasets.eyelink import data_path
from mne.preprocessing.eyetracking import read_eyelink_calibration
from mne.viz.eyetracking import plot_gaze
import re
import numpy as np
import matplotlib.pyplot as plt

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

regex_saccade = ".*sacc.*"
for idx, desc in enumerate(raw_et_loaded.annotations.description):
    if re.search(regex_saccade, desc):
        raw_et_loaded.annotations.description[idx] =  "ET_" + desc
raw_et_new = raw_et_loaded.copy()


regex_sync = '.*trigger=02.*' # pick stimulus presentation (trigger id 02) events
et_sync_times = [annotation["onset"] for annotation in raw_et_new.annotations if re.search(regex_sync,annotation["description"])]
sync_times    = [annotation["onset"] for annotation in raw_eeg.annotations    if re.search(regex_sync,   annotation["description"])]
assert len(et_sync_times) == len(sync_times),f"Detected eyetracking and EEG sync events were not of equal size ({len(et_sync_times)} vs {len(sync_times)}). Adjust your regular expressions via 'sync_eventtype_regex_et' and 'sync_eventtype_regex' accordingly"

# # finding trigger events: stimulus event shown
# ev_trigger, event_dict2 = mne.events_from_annotations(raw_eeg, regexp="1-trigger=02")

# RuntimeWarning: Channel(s) xpos_left, ypos_left, pupil_left, xpos_right, ypos_right, pupil_right, DIN in `other` contain NaN values. Resampling these channels will result in the whole channel being NaN. (If realigning eye-tracking data, consider using interpolate_blinks and passing interpolate_gaze=True)
# so, NOTE: try interpolating if we want to resample.

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
raw_eeg.annotations.crop(0,0)
raw_et_new.add_channels([raw_eeg], force_update_info=True)
raw_et_new._raw_extras.append(raw_eeg._raw_extras)

# plot just ET data
# raw_et_new.plot(start=60, duration=0.01, verbose='ERROR', decim=5, scalings='auto') # dict(pupil=1e3)

# select channels of interest & plot 
# missing in the data:  "FFT10h", "FFT9h", "CPz",
# picks must be numeric (not string) when passed to `raw.plot(..., order=)`
picks_idx = mne.pick_channels(raw_eeg.ch_names, chan_list, ordered=True)
raw_eeg.plot(start=60, duration=1, verbose='ERROR', scalings=dict(pupil=1e3))# , picks=chan_list) #dict(pupil=1e3)

# saccade annotations -> create events
events_saccade, events_saccade_dict = mne.events_from_annotations(raw_et_new, regexp=regex_saccade)

# extract epochs around saccades
epochs = mne.Epochs(raw_et_new, events=events_saccade, event_id=events_saccade_dict, tmin=-0.5, tmax=2, baseline=None, event_repeated='merge')
# epochs.plot(
#     events=events_saccade, event_id=event_dict, order=picks_idx, scalings=dict(pupil=1e3)
# )

mne.export.export_epochs("exported_epochs.set", epochs)
