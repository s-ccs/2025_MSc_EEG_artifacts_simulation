// A central place where libraries are imported (or macros are defined)
// which are used within all the chapters:
#import "utils/global.typ": *


// Fill me with the Abstract
#let abstract = [#lorem(150)]

// Fill me with acknowledgments
#let acknowledgements = "

I would like to thank my supervisors, Dr. Benedikt Ehinger and Judith Schepers, for their guidance and support during my work on this thesis. 

I also thank Nils Harmening for the correspondence on the HArtMuT model and for the simulation of the new forward models based on our suggested modifications."

// Declaration regarding own work / AI use: adapted from the guidelines of the Computer Science Department, Faculty 5, Uni-Stuttgart 
#let declaration = [
  #include "declaration.typ"
]

// if you have appendices, add them here
#let appendix = [
  = Appendices
  #include "appendix.typ"
]

// Put your abbreviations/acronyms here.
// 'key' is what you will reference in the typst code
// 'short' is the abbreviation (what will be shown in the pdf on all references except the first)
// 'long' is the full acronym expansion (what will be shown in the first reference of the document)
//
// In the text, call @eeg or @uniS to reference  the shortcode
#let abbreviations = (
  (
    key: "eeg",
    short: "EEG",
    long: "Electroencephalography",
  ),
  (
    key: "uniS",
    short: "UoS",
    long: "University of Stuttgart",
  ),
  (
    key: "hartmut",
    short: "HArtMuT",
    long: "Head Artifact Model using Tripoles",
  ),
  (
    key: "crd",
    short: "CRD",
    long: "corneo-retinal dipole",
  ),
  (
    key: "eog",
    short: "EOG",
    long: "electrooculogram",
  ),
)

#show: thesis.with(
  author: "Maanik Marathe",
  title: "EEG Artifact Simulation: an open-source implementation for a selection of artifacts",
  degree: "M.Sc.",
  faculty: "Faculty of Electrical Engineering and Computer Science",
  department: "Computational Cognitive Science",
  major: "Information Technology",
  supervisors: (
    (
      title: "Main Supervisor",
      name: "Benedikt Ehinger",
      affiliation: [Computational Cognitive Science \
        Faculty of Electrical Engineering and Computer Science, \
        Department of Computer Science
      ],
    ),
    (
      title: "Second Supervisor",
      name: "Judith Schepers",
      affiliation: [Computational Cognitive Science \
        Faculty of Electrical Engineering and Computer Science, \
        Department of Computer Science
      ],
    ),
  ),
  epigraph: none,
  abstract: abstract,
  appendix: appendix,
  acknowledgements: acknowledgements,
  preface: none,
  figure-index: false,
  table-index: false,
  listing-index: false,
  abbreviations: abbreviations,
  date: datetime(year: 2025, month: 12, day: 4),
  bibliography: bibliography("refs.bib", title: "Bibliography", style: "american-psychological-association"),
  declaration: declaration
)

// Code blocks
#codly(
  languages: (
    rust: (
      name: "Rust",
      color: rgb("#CE412B"),
    ),
    // NOTE: Hacky, but 'fs' doesn't syntax highlight
    fsi: (
      name: "F#",
      color: rgb("#6a0dad"),
    ),
  ),
)

// If you wish to use lining figures rather than old-style figures, uncomment this line.

// #set text(number-type: "lining")

// import custom utilities
#import "utils/general-utils.typ": *

// Main Content starts here
= Introduction <chp:introduction>

#ilt[rephrase]

@eeg is a method of recording the electrical activity of the brain via a set of electrodes (or sensors), usually placed on the scalp and/or the facial skin of the participant. During the EEG recording, each of the electrodes measures the electrical potential at its respective location, with one electrode being designated as the reference electrode. The recorded value of the EEG at a given electrode is a measure of the potential difference between that electrode and the reference electrode @hari_meg-eeg_2017. 

The time-series data thus gathered is later analyzed in order to understand more about the inner working of the brain. Of interest to researchers are the electrical potentials arising from brain activity; however, the raw recorded data also contains unwanted components, called "artifacts". These artifact potentials partially or completely obscure the brain-related signals, since they often have a similar or much larger magnitude compared to the latter. 

Thus, the data must be cleaned of artifacts before it can be analyzed. For this preprocessing, a variety of techniques and tools have been developed. These are tested on real or synthetic data, and in the end used in order to process real data for the purpose of answering specific research questions.

The following subsections discuss EEG artifacts and their simulation in more detail, along with laying out the aim and scope of this thesis.

== EEG Artifacts

The artifact potentials in EEG data can be broadly divided into two categories: those originating from the subject's physiological processes, and those originating in the environment. The individual artifacts can vary in magnitude at different electrodes or over time as the recording progresses, and each artifact has certain characteristics that can help better distinguish it from the EEG and other artifacts. 

For example, the subject's eye movements and blinks cause large artifacts in the recording. The muscles of the head, face, and neck are electrically activated when in use, causing their own artifacts in the measured scalp potentials; the electrical activity during the heartbeat also generates a measurable change in the EEG; and when the subject sweats it causes a corresponding artifact as well. 

Non-physiological artifacts include power line noise (electrical noise caused by the interference from alternating-current electrical power supply), noise due to a bad connection with an electrode, sudden large changes in electrode potentials ('pop'), and artifacts due to swinging of the cable. 

To a certain extent, the experimental setup and procedure at the time of EEG recording can help avoid the artifacts being recorded at all. For example, subjects can be asked to stay as still as possible during the EEG recording to avoid artifacts due to their movements; the setup can be well isolated from AC power lines; and the experimental room can be kept at a controlled temperature and humidity level so that artifacts due to sweating are minimized @hari_meg-eeg_2017. 

However, some artifacts (like eye movement, blink artifacts, or drifts) cannot be easily avoided at the source. These must be then removed from the raw data via preprocessing, before the cleaned data is then ready for analysis. This is often done by means of special algorithms and processing tools implemented using computer code.

== Motivation for simulation in EEG data processing

#ilt[rephrase]

Modern EEG research often involves the use of software to process recorded data, for example to detect artifacts or to perform artifact correction on the detected artifacts. Popular software packages for EEG data processing include EEGLab @delorme_eeglab_2004, autoreject @jas:hal-01313458, and MNE @larson_mne-python_2024. Individual researchers usually also write their own code to help perform further analysis, either independently of such packages or by building on the functions provided therein.

Whether in the form of a standalone tool or a custom script, this code must be tested in order to make sure it satisfies the requirements. For this, a sample dataset can be processed using the code and then the researcher can inspect or evaluate the dataset before and after processing to determine whether the required effect was achieved. 
Specifically, in the case of preprocessing for artifact detection, the artifacts in the sample dataset should all be correctly detected, and for artifact rejection the dataset after applying the preprocessing must be free of the particular artifact.

Care must be taken in choosing the test dataset - it should contain instances of the target phenomenon (in this case, the artifact), these instances should be well labeled, and there should be enough data (both, with as well as without the artifact) in order to tell with high certainty that the analysis code has performed the required task. In addition, since no two instances of the artifact are the same, the selected test dataset should also capture this variation.
However, existing recorded EEG datasets do not necessarily fulfil these requirements. 

Firstly, the dataset might not be large enough to support the analysis.
Overall dataset size is limited due to constraints like the available storage space, and participant comfort considerations play a significant role during longer recordings. Low manpower or lack of access to suitable subjects can reduce the number of individual recordings that can be made. 
The modalities of data that can be recorded are limited by factors like available equipment, complexity of experimental setup, et cetera. 

Thus, for example, experimenters carrying out a particular study may have access to EEG equipment but no eye tracker, and thus the resulting dataset does not contain associated eye tracking data of the participants. This results in the dataset being less suitable for testing preprocessing methods that target eye artifacts. A different study may record data of fewer participants due to stricter exclusion criteria, or the experimental setup may be uncomfortable for the participant and limit how long the recordings are for each subject, leading to less data to work with overall. 

This can mean that a single recording does not have well-suited or sufficient data to train a model or validate the analysis code. Therefore, either multiple test datasets must be used, or time must be spent to find or record a large enough usable dataset. 

Next, there may not be sufficient instances of the artifact in the selected dataset, or the labeling may not be of good quality. The variety in the instances may also be low, such that it is difficult to get different test cases for the analysis code. #ilt[ talk about poor documentation?]

Finally, the ground truth, i.e. the sequence and details of the actual events that occurred during the recording, is not known to anyone except perhaps the original researchers. Later researchers often have to make assumptions and educated guesses when analyzing the data, and this can result in undiscovered errors. 

// It can be useful to have a degree of control over the ground truth in order to have a variety of different test cases for the current analysis. 

One solution to this problem could be to record a new dataset specifically for the purpose of testing a particular piece of analysis code. For example, to test code that identifies and removes blink artifacts, a recording could be carried out in which the participant is instructed to blink at specific times while looking in different specified directions. 
However, designing and carrying out such a study can be expensive and time-consuming, and not all researchers have the resources for this. 
Further, even in a purpose-built study, the participant may deviate from the instructions, or the instructions required in order to fulfil the experimenter's requirements may be too complex for subjects to follow.  


Simulating EEG data for this purpose then becomes a useful option. It provides the researcher with more control over the artifacts present in the test dataset, in terms of characteristics like variety, frequency of occurrence, distribution over time and space, and so on. 

Some researchers choose to themselves simulate datasets, with artifacts placed at known times or with known properties. This adds extra work and leads to a lack of standardization and replicability in synthetic data creation. Others prefer to use an off-the-shelf tool developed specifically for simulation, and tailor it to their needs. Most of the artifact simulation code currently available is primarily based in MATLAB, which is closed-source and therefore less accessible. 
Thus, there is a need for a single method for artifact simulation in a standardized and accessible way that is also flexible enough to be customized if so required. 

#ilt[rephrase the last paragraph]

// Although some work has been done in this area (see @prevwork-simulation), the methods are still not standardized and are dependent on the individual researcher's skills and judgement, making it difficult to exactly reproduce methods used by another researcher.  


#ilt[transition??]


// 


== Aim and scope of this thesis

As described in the previous section, there is a gap in the available software for EEG artifact simulation. The aim of this thesis is to take the first step towards filling this gap, in the form of an open-source, easy to use implementation that is compatible with an existing EEG simulation package.

The programming language chosen for the implementation is Julia, the existing simulation package that is extended is UnfoldSim.jl @Schepers2025 and the corresponding code supporting this written thesis is hosted in a repository on the Internet platform 'GitHub'. #ilt[link the repo here?]

For each artifact, there is first a discussion of its physical origin and how it manifests in EEG recordings. Then, a method to simulate it is presented, corresponding to the code in the thesis repository. While designing and implementing the simulation, care is taken to take into account different possible use cases or interfaces between sections of the code. Finally, limitations and possible future work are discussed.

For the scope of the thesis, a set of artifacts has been selected, namely eye movement artifacts, power line noise, and drifts. The simulation code starts from a simple, basic implementation and builds up to more complexity as required. 

The following research questions were formulated in order to better guide the work done on this thesis:
1. Given a set of chosen EEG artifacts (eye movement, power line noise and electrode drift), what is known about their origin and characteristics?
2. How are these artifacts usually simulated?
3. How can we simulate them in a way that is standardized and compatible with existing open-source EEG simulation packages?



#pagebreak()
= EEG Artifacts

== Eye Movement artifact

#ilt[references] 

Eye-related EEG artefacts arise mainly from eyeball movements, eye muscle activation, and eyelid movements. This section primarily deals with the artefact due to eyeball movement. 
 
The eye is made up of different kinds of tissue, some of which generate a standing electrical charge distribution due to their intrinsic properties. The cornea (at the front of the eye) and the retina (at the back) together constitute the entire surface of the eyeball. Each of these tissue types has an electrical potential difference between its inner and outer surfaces. Specifically, the cornea is positively charged on the outside of the eyeball and the retina is negatively charged on the outside of the eyeball @iwasaki_effects_2005. 

As the eye rotates in its socket, the corresponding charge distribution rotates along with it and changes the resulting electric field, manifesting as eye movement artifacts measured in the EEG at the scalp. This can be more clearly seen in the @eog, a special signal recorded during an EEG study by placing additional electrodes near the eyes in order to record the electrical activity resulting from eye movements. One pair of electrodes is placed above and below one eye, and one pair at the temples, outwards to the side from each eye. The vertical and horizontal @eog respectively are the values of the potential differences calculated between these electrodes in pairs, and the magnitude of this potential difference changes in accordance with the movement of the eye.

Previous studies like #pc[@mowrer_corneo-retinal_1935] and #pc[@matsuo_electrical_1975] found that an intact eyeball (i.e., having both cornea and retina) is required in order to observe the @eog effects due to eye movements, and concluded that the eye has an overall potential difference between the front and back of the eyeball. This potential difference was named the "corneo-retinal potential" @mowrer_corneo-retinal_1935 and has been used as a basis of the model of eye movements in existing studies @berg_dipole_1991 @plochl_combining_2012 @lins_ocular_1993. 


The resulting electrical potential distribution in the eye can thus be modelled in multiple ways. First, the charges of the cornea and retina can be combined and modelled as a single electrical current dipole with its positive end towards the cornea at the front, following the axis of gaze @plochl_combining_2012, and this is commonly known as the "@crd". It is also possible to model the potential differences on the retina and cornea tissues as a set (or "ensemble") of smaller electrical dipoles placed on the tissue surface and oriented in different directions, as in #pc[@harmening_hartmutmodeling_2022]. 

#ilt[diagram of eye charges - crd & ensemble models]

These models, known as "@crd" and "ensemble" models respectively, have been explored more in detail in a previous work @mmar-researchproject and the implemented models from that work have been used in this thesis in order to simulate eye movement artifacts.


// ; eye muscle artefacts are generated due to activation of the muscles used in order to move the eyes. Eyelid movement can contribute to multiple artefacts: according to @iwasaki_effects_2005, the eyelids move along with eye movements, and greatly influence the frontal EEG observed during vertical eye movements. #pc[@matsuo_electrical_1975] explain blink artefacts as resulting from the interaction between the eyelid and the charged surface of the cornea at the front of the eyeball, where the eyelid conducts the positive charges from the cornea towards the frontal electrodes (also known as the "sliding electrode" effect).


Along with the movement of the eyeball itself, other factors also affect the EEG artifacts arising from eye movements. According to #pc[@iwasaki_effects_2005], the eyelids move along with eye movements, and the effect is visible in the frontal EEG observed during vertical eye movements. #pc[@matsuo_electrical_1975] discuss a  possible explanation: when the eyelid makes contact with the charged surface of the cornea, it conducts the positive charges away towards the frontal electrodes. This is also known as the “sliding electrode” effect @hari_meg-eeg_2017 and has also been used to explain blink artifacts #ilt[references].

// . explain blink artefacts as resulting from the interaction between the eyelid and the charged surface of the cornea at the front of the eyeball, where the eyelid conducts the positive charges from the cornea towards the frontal electrodes

== Power Line Noise

The modern world is powered primarily by alternating current (AC) electrical power, delivered to devices via power cables and connectors. "Alternating current" means that the electrical current passing through the cables and circuits reverses direction at defined intervals i.e. at a particular frequency. There are two standard frequencies around the world, namely 50 Hz and 60 Hz.

A current carrying conductor creates an electric field around it, and when the direction of the current changes, so does the electric field. This means that the electric potential in a space is also affected by the alternating current carried by the power cables running through it. 

Since the EEG is a measure of electrical potential, it also measures the changes in electrical potential that occur as a result of the alternating direction of the current in the power supply. The alternating current may also induce effects in equipment around the subject, which in turn can affect the measured EEG. This means that in an EEG recording there is also an unwanted component that results from the power supply, and this component is known as power line noise. 

The exact mechanism(s) by which the power line noise enters the EEG system is not yet definitely known #ilt[ref]. The magnitude of the artifact can be reduced by measures like electrically shielding the experimental room or avoiding the use of AC power during the recording. However, it is not entirely possible to avoid recording this artifact. Thus, the presence of this noise is widely known and accepted in EEG studies  @de_cheveigne_zapline_2020 and efforts are concentrated rather on reducing the magnitude of this noise where possible in the recording setup, along with using post-processing methods to remove the artifact after the recording is complete.

#ilt("previous work: removing pln artifacts?")

== Drift artifact

In a given EEG recording, it is often observed that the reading measured on a particular electrode slowly tends to drift upwards or downwards over time, seemingly independent of the measured EEG itself. This phenomenon is known as the drift artifact and can likewise cause problems when interpreting recorded EEG data. 

Huigen et al. (2022) #ilt[ref] investigated the cause of this electrode noise and concluded that it originates from the contact between the electrodes and the skin. The drift artifact differs across channels, although it may be somewhat related in electrodes that are closer to each other #ilt[ref] (de cheveigne, arzounian).

Sweating during the experiment can affect the impedance at various electrodes. kappenman_luck #ilt[ref] describe two methods to reduce the drift: maintaining a cool environment to discourage sweating, and gently abrading the scalp surface before making contact with the electrode in order to create a low-impedance connection to the skin. 

#ilt[content]

== Other artifacts

=== Blinks

=== Muscle artifacts

...


== Characteristics of selected artifacts in EEG

=== Eye Movements

Eye movements can be seen as large deflections in the EEG, prominently visible in the electrodes at the front of the head and near the eyes, and to a lesser extent at electrodes further away from the eyes. @eog signals show the clearest picture of the artifact, as they are closest to the eyes and relatively far away from the brain. 

From a particular gaze direction, when the eye rotates horizontally to one side, the electrodes on that side read more positive after the rotation than they did before the rotation, and electrodes on the other side experience a negative deflection i.e. are more negative than they were before. Similarly, for upward eye movements, electrodes above the eyes are more positive after the movement and those lower on the face are more negative after the movement @hari_meg-eeg_2017. 

These observations correspond to the effect one would expect from the corneo-retinal potential described in the literature. 

#ilt[plots of EM]


=== Power line noise

The power line noise can be seen with the naked eye in the raw EEG as regular oscillations at much higher frequencies than is normally expected in an EEG recording. When observing the power spectral density of the data, sharp peaks can be seen at the power line frequency and its multiples. 
The artifact may not be uniformly distributed across the scalp electrodes @de_cheveigne_zapline_2020; this may be a result of different mechanisms of transmission of the power line noise into the EEG system and the relative positioning of different electrodes with respect to the power lines themselves.

#ilt[plots]

=== Drifts

Drifts manifest as a slow increase or decrease over time in the basic level around which the measured EEG signal appears. This can be extracted from the data and looks similar to the figure below.

#ilt[plot of drifts]


#pagebreak()
= Methods

== Artifact Simulation: previous work <prevwork-simulation>

== Design Description
- UnfoldSim design overview
- overview of changes in files
- AbstractContinuousSignal, controlsignal, ...
- Interfaces required / explain different 'levels' of abstraction
- new `simulate` - steps


== Eye Movement Simulation
At the lowest level of simulation, the eye movement can be controlled using the instantaneous *gaze direction vector*, a vector pointing from the center of the eye towards the current gaze point. This vector is described in three dimensions in the same coordinate frame as the head model.

The next possible interface would be to allow the user to specify the eye position in *HREF* coordinates #ilt[explain href]. 

The eyeballs were modelled using the @hartmut model. 

#ilt[code example]

== Power Line Noise

#ilt[code example]

The properties of the power line noise can be specified as shown in the code snippet: base frequency, harmonics required, and the sampling rate of the power line noise. A `controlsignal` further specifies the weights to be applied to this noise type at each channel and time point.  

The noise is first simulated for a single channel using the given base frequency and harmonics, then weighted according to `controlsignal` and returned in order to be added to the remaining simulation results at the appropriate stage in the process. 

== Drift


== User-defined artifact

The simulation is designed to be as flexible as possible while still providing a unified structure and flow to simulate different artifacts. To this end, a special type is defined, called `UserDefinedContinuousSignal`. 

This type has a similar structure to the predefined artifacts provided, but is not bound to any one specific type of artifact. An advantage of this is that the user can choose to simulate their own artifacts separately or even reuse an artifact extracted from real data, similar to the workflows currently in use. However, the common simulation flow still remains and the addition of the user-defined artifact can be unified with the simulations provided in the package, resulting in a more standardized simulation overall.

#pagebreak()
= Simulation Examples



#pagebreak()
= Discussion



== Limitations

- Weightage/normalisation problem - where to apply weights and whether/how to expose these options to the user

=== Eye model
  - skin conductivity for entire eyeball - "closed-eyelid" state
  - eyelid movement accompanying  not simulated
  - 

=== Power line noise
- same noise is added to all electrodes 
- no inbuilt relative weighting for different electrodes or across time

== Outlook / Future Scope

=== Eye movements
- eyeball fluid conductivity
- simulating partially open eyelid -> different magnitudes for different parts of the cornea/retina points 
- simulating movement of eyelid along with  

=== Power line noise
- different effects on different channels depending on position: simulating the line noise source situated at a position in space relative to the head

=== Other artifacts

==== Blink
- eyelid movement
- bell's phenomenon - plus, different deflections depending on original gazedir?

==== Artifact sources placed outside the head
eg. heartbeat, pln, etc -> create a head model that includes sources outside the head, then we can modulate those sources the same as we just did with the brain and get the corresponding leadfield.

=== Simulation interfaces

(from excel sheet)

- saccade simulation by specifying fixation positions and/or onsets
- random saccade simulation (least-possible/no parameters provided by user)
- what to weight where in relation to which other things / at what level of calculation/abstraction


=== Evaluation

- try to simulate the artifacts from a known dataset and compare with the original dataset - e.g. apply same preprocessing steps to both of the above and compare the result
- PSD for power line noise
- try giving different weights for different channels
- topoplots - for eye movements; for test cases where the channels are weighted differently; to visualize drift artifacts happening only on particular electrodes

#pagebreak()
= Summary

As new tools and techniques are developed for preprocessing and processing EEG data, there will be a continued need for simulation tools that enable researchers to more easily and efficiently generate test data for their analyses. 

In this thesis, some basic simulations of EEG artifacts were provided as an extension on an existing EEG data simulation package. The implementation has certain limitations and there is scope for further development, as discussed in previous sections. In the future, more work can be done based on the starting point explored here, in the same way that this first artifact simulation built on the work on the EEG simulation package. 

#ilt[content]
