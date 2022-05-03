# qccodar

This python code applies several quality control (QC) functions based
on CODAR SeaSonde (COS) Radialmetric data currently output in COS
RadialSuite version 7.x (and version 8.x upon request). There are two 
modes to this code: an auto-and manual-mode.  Auto-mode is for realtime
processing. Manual-mode is for processing all RadialMetric files in a
specified folder in post-processing. qccodar is intended to run beside 
(in parallel) to SeaSonde Analysis and not supplant any processing.  
In fact, qccodar uses the LLUVMerger.app provided by SeaSonde to merge 
the data back into standard SeaSonde processing methodology.

## Quickstart


## Installation

qccodar is a python package and runs under Python 3. Eventhough Mac
OS X comes with Python 3 installed or you can install Python
directly from
[python.org](https://wiki.python.org/moin/BeginnersGuide/Download), it
is recommended to use the lightweight option from
[Conda](https://conda.io/docs/index.html) called
[miniconda](https://conda.io/miniconda.html).  Miniconda contains only
Python and other libraries needed to run Conda itself; other packages
will be downloaded and installed as requested.  Conda has a package
manager which makes this installation easy.  Conda also supports
virtual environments where qccodar can run independently from the
system-installed Python. 

The following instructions show how to install and configure Miniconda3
and qccodar to provide QC'd Radial data based on RadialMetric output.  

While logged on as user `codar`, open a terminal to download (curl) and run the installer script. 

```bash

   $ cd ~/Downloads
   $ curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -o "miniconda3.sh"
   $ bash ~/Downloads/miniconda3.sh -b -p $HOME/miniconda3
   $ export PATH="$HOME/miniconda3/bin:$PATH"
```

As, user `codar`, edit `~/.bash_profile`, add the `export
PATH="$HOME/miniconda3/bin:$PATH"`, and then source your profile.

```bash
   $ source ~/.bash_profile
```

Refer to the [Conda Installation
Guide](https://conda.io/docs/user-guide/install/index.html) for more
details on installing Conda, making the appropriate adjustments for Miniconda3. 


Download the qccodar3 code from github.com/teresaupdyke/qccodar3

Create a conda environment allows the qccodar module and its
dependencies to run isolated from the installed Python avoiding
potential module version conflicts.  

```bash

   $ conda env create -f environment.yml
```

Activate the environment:
```bash

   $ source activate qccodar3
   (qccodar3) $ which python
   /Users/codar/miniconda3/envs/qccodar3/bin/python
```



## Configuration and Crontab Entry for Realtime QC

First, enable RadialMetric output:

1. Edit line 21 of `AnalysisOptions.txt` in /Codar/SeaSonde/Configs/RadialConfigs.
1. Restart AnalyzeSpectra

```
   1           !21 Enable Radial Metric Output: 0(Off), 1(Enable), 2(Enable MaxVel.)
```


Next, set up a customized configuration file. 

1. Navigate to the qccodar3 directory and copy the configuration file
```
   cp src/qccodar3/config/qccodar.plist /Users/codar/qccodar_files/qccodar.plist
```
 2 . Edit this copy of qccodar.plist to specify a customized configuration for the radar site.  The default configuration is for a long range SeaSonde system and parameter for the 


Finally, set crontab entry to run qccodar:

1. Make a place to log data, e.g. `$ mkdir ~/logs`
1. Place entry in crontab to run every 15 minutes and log the output

```
$ crontab -l
1,11,21,31,41,51 * * * * /Codar/SeaSonde/Users/Scripts/collect/collect.pl
00,15,30,45 * * * * PATH=$PATH:/sbin /Users/codar/miniconda/envs/qccodar/bin/qccodar auto >> /Users/codar/logs/qccodar-auto.log 2>&1
```

If you get `sh: sysctl: command cannot be found` in output or log,
sysctl might be in another path.  qccodar still runs even when this
cannot be found.  In MacOS -- sysctl is sometimes located in /usr/bin
(or /sbin) and may not be in the path under cron.  Placing
`PATH=$PATH:/usr/sbin` in the task entry, adds the path.

## Background

### Notes

| QC Function        | Description |
| -----------        | ----------- |
| Threshold Tests    | badflag any values that fall below or above a single threshold |
| Weighted Averaging | average several values with weights based on signal quality parameters |

#### QC Threshold Tests:
1. DOA peak power (MSR1, MDR1, MDR2) < 5 dB default 
1. DOA 1/2 power width (3dB down) (MSW1, MDW1, MDW2) > 50 deg default
1. SNR on monopole (MA3S) < 5 dB default
1. SNR on both loops (MA1S and MA2S) < 5 dB

#### Weighted Averaging:
1. Weighting based on Music Power (MSP1, MDP1, MDP2)
1. Weighting based on SNR on monopole (MA3S)
1. No weight function (None) 
 
### System Requirements
Python 3 is required. However, earlier versions of some of the other packages may be okay.

- Python 3.x
- numpy 1.20.0
    - https://pypi.python.org/pypi/numpy
    - Data read into memory are stored in the N-dimensional array datatype (ndarray) for indexing and computation.
- geopy 2.0.0
    - https://pypi.python.org/pypi/geopy
    - geopy.distance.geodesic()
    - Used to compute (LAT, LON) based on range and bearing from site origin in generating RadialShorts file
- watchdog 2.1.6
    - Used to monitor a directory for new files and trigger qc and merge process when new RadialMetric file is created (NOT YET IMPLEMENTED)
- docopt 0.6.2
- hfradarpy 0.1.4.7
- CODAR SeaSonde RadialSuite 7.x (version 8 does not support RadialMetric output unless requested from CODAR)
    - /Codar/SeaSonde/Apps/Bin/LLUVMerger.app
    - Used to merge spatial and temporal RadialShorts data to final Radial
