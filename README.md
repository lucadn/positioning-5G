# Outdoor positioning by fingerprinting using Weighted k Nearest Neighbour in 5G and NB-IoT networks
This Matlab code performs positioning in NB-IoT and 5G networks by fingerprinting using the Weighted k Nearest Neighbour algorithm, with a similarity metric combining a 3GPP radio parameter (RSSI, SINR, RSRP, RSRQ) and the number of PCIs (5G) and NPCIs (NB-IoT) in common between points. Please refer to the papers listed at the bottom of this file for additional details.

For each technology, the code includes:

- a main script;
- a function called by the main script to extract raw experimental data from .xlsx files, process them and build the data file;
- supporting functions to load and process raw data;
- matlab workspaces containing processed data.



Please refer to the comments in the files for further information.

Please note that due to space limitations, the .xlsx files are not provided on GitHub. They are provided in the open source dataset available at the following link:

https://zenodo.org/record/8161173

The dataset contains data for six measurement campaigns carried out in 2021 in Rome, Italy (both NB-IoT an 5G) and seven campaigns carried out in 2019 in Oslo, Norway (NB-IoT only). The matlab workspaces provided in this repository include data from all the Rome campaigns, but the user can easily generate workspaces for a subset of the Rome campaigns; in the case of NB-IoT, data from a subset or all Oslo campaigns can be used as well.

When using this code in a scientific publication, please cite the following research papers:

K. Kousias, M. Rajiullah, G. Caso, U. Ali, Ö. Alay, A. Brunstrom, L. De Nardis, M. Neri, and M.-G. Di Benedetto, "A Large-Scale Dataset of 4G, NB-IoT, and 5G Non-Standalone Network Measurements," submitted to IEEE Communications Magazine, 2023

L. De Nardis, G. Caso, Ö. Alay, U. Ali, M. Neri, A. Brunstrom and M.-G. Di Benedetto, "Positioning by Multicell Fingerprinting in Urban NB-IoT networks," Sensors, Volume 23, Issue 9, Article ID 4266, April 2023. DOI: 10.3390/s23094266


Acknowledgments

The work of Luca De Nardis and Maria-Gabriella Di Benedetto in the creation of this dataset was partially supported by the European Union under the Italian National Recovery and Resilience Plan (NRRP) of NextGenerationEU, the partnership on "Telecommunications of the Future" (PE00000001-program "RESTART").
