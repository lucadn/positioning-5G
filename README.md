# positioning-5G
This Matlab code performs positioning in NB-IoT and 5G networks by fingerprinting using the Weighted k Nearest Neighbour algorithm, with a similarity metric combining a 3GPP radio parameter (RSSI, SINR, RSRP, RSRQ) and the number of PCIs (5G) and NPCIs (NB-IoT) in common between points. Please refer to the papers listed at the bottom of this file for additional details.

For each technology, the code includes:

- a main script;
- a function called by the main script to extract raw data from the .xls files for the six campaigns considered in the analysis, process them and build the data file;
- supporting functions to load and process raw data.

Please refer to the comments in the files for further information.

When using this code in a scientific publication, please cite the following research papers:

K. Kousias, M. Rajiullah, G. Caso, U. Ali, Ö. Alay, A. Brunstrom, L. De Nardis, M. Neri, and M.-G. Di Benedetto, "A Large-Scale Dataset of 4G, NB-IoT, and 5G Non-Standalone Network Measurements," submitted to IEEE Communications Magazine, 2023

L. De Nardis, G. Caso, Ö. Alay, U. Ali, M. Neri, A. Brunstrom and M.-G. Di Benedetto, "Positioning by Multicell Fingerprinting in Urban NB-IoT networks," Sensors, Volume 23, Issue 9, Article ID 4266, April 2023. DOI: 10.3390/s23094266
