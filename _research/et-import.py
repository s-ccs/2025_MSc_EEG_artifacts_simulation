import mne
from mne.datasets.eyelink import data_path
from mne.preprocessing.eyetracking import read_eyelink_calibration
from mne.viz.eyetracking import plot_gaze

et_fpath = data_path(path="/store/users/marathe", update_path=True) / "eeg-et" / "sub-01_task-plr_eyetrack.asc"
eeg_fpath = data_path(path="/store/users/marathe", update_path=True) / "eeg-et" / "sub-01_task-plr_eeg.mff"

raw_et = mne.io.read_raw_eyelink(et_fpath, create_annotations=["saccades","blinks"])
raw_eeg = mne.io.read_raw_egi(eeg_fpath, events_as_annotations=True).load_data()
raw_eeg.filter(1, 30)

print(raw_et.annotations[0]["ch_names"]) # channel names will give an idea of which eye this event occurred in
# then they look at the first calibration (which is okay)
# but then when converting the units to dva, they use first_cali object. why? where is that method defined (on what kind of object)? and does it count then only for that object (i.e. event)? Or do you do it on the calibration from when on you want the units to be converted?
# turns out for some reason there's only one calibration

cals = read_eyelink_calibration(et_fpath)
print(f"number of calibrations: {len(cals)}")
first_cal = cals[0]  # let's access the first (and only in this case) calibration
print(first_cal)

first_cal["screen_resolution"] = (1920, 1080)
first_cal["screen_size"] = (0.53, 0.3)
first_cal["screen_distance"] = 0.9
mne.preprocessing.eyetracking.convert_units(raw_et, calibration=first_cal, to="radians")
mne.preprocessing.eyetracking.get_screen_visual_angle(first_cal)

# make the pupil size traces legible when plotting raw data
ps_scalings = dict(pupil=1e3)
raw_et.plot(scalings=ps_scalings)

# extract events and sync the eeg and et data
et_events = mne.find_events(raw_et, min_duration=0.01, shortest_event=1, uint_cast=True)
eeg_events = mne.find_events(raw_eeg, stim_channel="DIN3")

events_from_annot, event_dict = mne.events_from_annotations(raw_et)

# Convert event onsets from samples to seconds
et_flash_times = et_events[:, 0] / raw_et.info["sfreq"]
eeg_flash_times = eeg_events[:, 0] / raw_eeg.info["sfreq"]
# Align the data
mne.preprocessing.realign_raw(
    raw_et, raw_eeg, et_flash_times, eeg_flash_times, verbose="error"
)
# Add EEG channels to the eye-tracking raw object
raw_et.add_channels([raw_eeg], force_update_info=True)

# events_from_annot, event_dict = mne.events_from_annotations(raw_et)
# del raw_eeg  # free up some memory

# Define a few channel groups of interest and plot the data
frontal = ["E19", "E11", "E4", "E12", "E5"]
occipital = ["E61", "E62", "E78", "E67", "E72", "E77"]
pupil = ["pupil_right"]

eye_chan = ["E1","E33", "E8", "E26"]
# picks must be numeric (not string) when passed to `raw.plot(..., order=)`
picks_idx = mne.pick_channels(
    raw_et.ch_names, eye_chan + pupil, ordered=True
)
raw_et.plot(
    events=et_events,
    event_id=event_dict,
    event_color="g",
    order=picks_idx,
    scalings=ps_scalings,
)

# extract epochs around saccades
epochs = mne.Epochs(
    raw_et, events=events_from_annot, event_id=event_dict, tmin=-0.3, tmax=3, baseline=None
)
epochs.plot(
    events=events_from_annot, event_id=event_dict, order=picks_idx, scalings=ps_scalings
)

mne.export.export_epochs("mne-sampledata-saccades-epochs-test.set", epochs)

# ---------------------------------------------

