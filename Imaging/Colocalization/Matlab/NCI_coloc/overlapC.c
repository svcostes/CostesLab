  /**********************************************/
  /*   AUTHOR: Sylvain Costes                   */
  /*     DATE: 12/08/2000                       */
  /*      ADD: 01/16/2000 Pearson's cor. coef.  */
  /* Corrected and adapted for Matlab: 05/14/01 */
  /*--------------------------------------------*/
  /* FUNCTION:  overlap                         */
  /*                                            */
  /* Load 2 images and computes the overlap     */
  /* coefficient and Pearson's coef:            */
  /*    Sum(Ri.Gi)/Sqrt[Sum(Ri^2).Sum(Gi^2)]    */
  /*    where Ri & Gi are the intensities for   */
  /*    the 1st and 2nd image respectively for  */
  /*    pixel i.                                */
  /*                                            */
  /*                                            */
  /* input  : GREY     Images (img1, img2)      */
  /* input  : GREY Mask image (mimg)            */
  /* return : float overlap_coef                */
  /* return : float rp                          */
  /**********************************************/
 
#include "mex.h"
#include "matrix.h"
#include <stdio.h>
#include <math.h>

void overlapC(double *p1,double *p2,double *p3,double *overlap_coef,double *rp, double size[3])
{
 int    i,j,k,w1,h1,d1;
 long cont;
 double *pin1,*pin2,*pmin;
 double sumrigi,sumrisq,sumgisq;       /* Sum variables                  */
 double ravg,gavg;                     /* Variables for Pearson's coef.  */

 /************************************/
 /* Compute the overlap coefficient. */
 /************************************/
 w1 = (int) size[0];
 h1 = (int) size[1];
 d1 = (int) size[2];
 if (d1 == 0) d1 =1;
 
 pin1 = p1;
 pin2 = p2;
 pmin = p3;
 sumrigi = 0.;
 sumrisq = 0.;
 sumgisq = 0.;
 ravg    = 0.;
 gavg    = 0.;
 cont   = 0 ;

 for (k=0; k<d1; k++) {
  for (j=0; j<h1; j++) {
   for (i=0; i<w1; i++) {
    if (*pmin>0) {                /* compute coeffient only for overlap  */
      sumrigi += *pin1 * *pin2;   /* regions of both masks.              */
      sumrisq += *pin1 * *pin1; 
      sumgisq += *pin2 * *pin2;
      ravg    += *pin1;
      gavg    += *pin2;
      cont++;
    }
    pin1++;
    pin2++;
    pmin++;
   }
  }
 }
 ravg = ravg / cont;
 gavg = gavg / cont;

 *overlap_coef = sumrigi / sqrt(sumrisq * sumgisq);

 /**************************************************/
 /* Compute the Pearson's correlation coefficient. */
 /**************************************************/

 pin1 = p1;
 pin2 = p2;
 pmin = p3;
 sumrigi = 0.;
 sumrisq = 0.;
 sumgisq = 0.;

 for (k=0; k<d1; k++) {
  for (j=0; j<h1; j++) {
   for (i=0; i<w1; i++) {
    if (*pmin>0) {                            /* compute coeffient only for */
      sumrigi += (*pin1-ravg) * (*pin2-gavg); /* overlap regions            */
      sumrisq += (*pin1-ravg) * (*pin1-ravg);
      sumgisq += (*pin2-gavg) * (*pin2-gavg);
    }
    pin1++;
    pin2++;
    pmin++;
   }
  }
 }

 if (sumrigi == 0)
   *rp = 0;
 else
   *rp = sumrigi / sqrt(sumrisq * sumgisq);

}                                /* The End */


