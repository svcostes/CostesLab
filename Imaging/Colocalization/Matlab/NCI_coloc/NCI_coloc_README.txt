This is the Matlab program corresponding to the paper: 
Costes, S. V. et al. Automatic and quantitative measurement of protein-protein colocalization in live cells. Biophys J 86, 3993-4003 (2004). 

In order to execute this program you will need the following:
- A copy of Matlab 6.5 or above (version 7.0 recommended)
- A corresponding version of imaging package, DIPimage from Delft University: http://www.ph.tn.tudelft.nl/DIPlib/request.html
_ A copy of this folder: NCIColoc

NCI_coloc is the routine you should be using to compute co-localization. Load the images of interest via readim command from DIPimage inside Matlab. Each channel should be in a separate variable (a and b for example). Then, to compute the amount of co-localization, you can simply type NCI_coloc(a,b):

- This will display on the screen important co-localization information.
- It will also generate a tab delimited text file summarizing these results, named colocalization_summary.txt
- It will display automatically different important resulting images from analysis.

See help file of routine for more details

NOTE: You need to compile the overlap routine for NCI_coloc to work. To do so, type under the NCIcoloc directory the following:
mex overlap.c overlapC.c. This will create a dll or a mex file under pc or linux. This executable will be called by NCI_coloc and other routines in the directory.



You can always contact me if you need further assistance. I may answer.


Have fun...


Sylvain Costes, Ph.D., Lawrence Berkeley National Laboratory
svcostes@lbl.gov

PS: This program is also available in a much easier form by:
FREEWARE
ImageJ: http://www.uhnres.utoronto.ca/facilities/wcif/imagej/colour_analysis.htm (You need the pluggin)
MIPAV: http://mipav.cit.nih.gov/

COMMERCIAL PACKAGES
Bitplane: http://www.imaris.com/products/imariscoloc/imariscolocal_features.shtml
Volocity: http://www.improvision.com/pdfs/guides/VolocityUserGuide.pdf