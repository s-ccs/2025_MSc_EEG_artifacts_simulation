# **MSc-Thesis:** Simulation of a selection of  EEG artifacts, including eye movements and power line noise

**Author:** *Maanik Marathe*

**Supervisors:** *Jun.-Prof. Dr. rer. nat. Benedikt Ehinger*, *Judith Schepers, M.Sc.*

**Year:** *2025*

## Project Description
Given a set of chosen EEG artifacts (eye movement, power line noise and electrode drift), we try to first understand their characteristics and then simulate them. The simulation should be implemented in a way that is standardized and compatible with UnfoldSim.jl, an existing open-source EEG simulation package. It should also provide a format for specifying the higher-level properties of the artifact simulation (e.g. onset, frequency of occurrence, correlation with other artifacts, etc).

The thesis report in PDF format is located in the folder `report/thesis`. The typst source files used to build the PDF are in the `report/typst-template` folder, with the main thesis content contained in `main.typ`. 

Along with the current repository, a fork of the UnfoldSim.jl repository is also relevant to the thesis: the artifact simulation code developed for this thesis has been directly integrated into this fork in order to ensure compatibility of the new code with the existing UnfoldSim.jl package and it is planned to eventually integrate this code into UnfoldSim.jl itself. The fork can be found at https://github.com/maanikmarathe/UnfoldSim.jl/tree/report-submission .

## Bibliography
See `report/typst-template/refs.bib`.

## Instruction for a new student

You will need to install Revise.jl and add UnfoldSim as a development package, if you want to make changes in the UnfoldSim code and have the updated code available immediately to use in the julia REPL. For more details on this, see the [UnfoldSim.jl developer documentation](https://unfoldtoolbox.github.io/UnfoldSim.jl/stable/developer_docs/). Note that Revise.jl does not take into account changes made to types; if you update a type definition, you will need to close your current julia session and start a new one.

### Setting up the thesis repository
- Clone this thesis git repository into a folder, say `2025_MSc_EEG_artifacts_simulation`. Run `julia` from this folder.  

- Activate the environment: `] activate .`

- The very first time, add UnfoldSim as a development package. Check that the package has been successfully added by running `] st` and making sure that the path for UnfoldSim points to the appropriate `dev/UnfoldSim` folder.

- To run one of the Pluto notebooks, you can start Pluto: `julia> using Pluto; Pluto.run(host="0.0.0.0", port=1234, launch_browser=false)` to run it on localhost:1234 without launching the browser (for example).

- To run a ready-made simulation, call `UnfoldSim.az_simulation()`. Similarly, to get an example snippet of data including eye movements, call `UnfoldSim.example_data_eyemovements()` or to import the HArtMuT-based forward model of the eye, you can call `UnfoldSim.import_eyemodel()`.

### Developing UnfoldSim artifact simulation code

- Clone the UnfoldSim fork containing the artifact simulation code: `git clone https://github.com/maanikmarathe/UnfoldSim.jl.git`  
- Start Julia, activate the environment, and add UnfoldSim as a development package. For the latter, provide the folder path into which the UnfoldSim fork was cloned. 
- `julia> using UnfoldSim` will give you access to UnfoldSim.


## Overview of Folder Structure 

```
│projectdir          <- Project's main folder. It is initialized as a Git
│                       repository with a reasonable .gitignore file.
│
├── report           <- **Immutable and add-only!**
│   ├── proposal     <- Proposal PDF
│   ├── thesis       <- Final Thesis PDF
│   ├── talks        <- PDFs (and optionally pptx etc) of the Intro,
|   |                   Midterm & Final-Talk
|
├── _research        <- WIP scripts, code, notes, comments,
│   |                   to-dos and anything in an alpha state.
│
├── plots            <- All exported plots go here, best in date folders.
|   |                   Note that to ensure reproducibility it is required that all plots can be
|   |                   recreated using the plotting scripts in the scripts folder.
|
├── notebooks        <- Pluto, Jupyter, Weave or any other mixed media notebooks.*
│
├── scripts          <- Various scripts, e.g. simulations, plotting, analysis,
│   │                   The scripts use the `src` folder for their base code.
│
├── src              <- Source code for use in this project. Contains functions,
│                       structures and modules that are used throughout
│                       the project and in multiple scripts.
│
├── test             <- Folder containing tests for `src`.
│   └── runtests.jl  <- Main test file
│   └── setup.jl     <- Setup test environment
│
├── README.md        <- Top-level README.
|   |                   
|
├── .gitignore       <- focused on Julia, but some Matlab things as well
│
├── (Manifest.toml)  <- Contains full list of exact package versions used currently.
|── (Project.toml)   <- Main project file, allows activation and installation.
└── (Requirements.txt)<- in case of python project - can also be an anaconda file, MakeFile etc.
                        
```
