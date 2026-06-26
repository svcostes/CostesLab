
#include "mex.h"
#include "matrix.h"  
#include <stdio.h>
#include <math.h>

/* mexFunction is the gateway routine for the MEX-file. */
void
mexFunction( int nlhs, mxArray *plhs[],
             int nrhs, const mxArray *prhs[] )
{

 double *ro,*rp;
 mxArray *mxA,*mxB,*mxC,*mxsizeA,*mxsizeB,*mxsizeC;
 double  *sizeA;
 double *A,*B,*C;
 int wA,hA,dA,wB,hB,dB,wC,hC,dC;
 
/* Check for proper number of arguments */
    
 if (nrhs != 3) { 
   mexErrMsgTxt("Three input images are required."); 
 } else if (nlhs != 2) {
   mexErrMsgTxt("Two output are required."); 
 } 

/* Make sure all three images have same dimensions */

 mexCallMATLAB(1, &mxA, 1, &prhs[0], "double");
 mexCallMATLAB(1, &mxsizeA, 1, &prhs[0], "size");
 A = mxGetPr(mxA);
 sizeA = mxGetPr(mxsizeA);

 mexCallMATLAB(1, &mxB, 1, &prhs[1], "double");
 mexCallMATLAB(1, &mxsizeB, 1, &prhs[1], "size");
 B = mxGetPr(mxB);
 
 mexCallMATLAB(1, &mxC, 1, &prhs[2], "double");
 mexCallMATLAB(1, &mxsizeC, 1, &prhs[2], "size");
 C = mxGetPr(mxC);
 
 plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
 plhs[1] = mxCreateDoubleMatrix(1,1, mxREAL);
 
 ro = mxGetPr(plhs[0]);
 rp = mxGetPr(plhs[1]);

 overlapC(A,B,C,ro,rp,sizeA);
 
  
}

