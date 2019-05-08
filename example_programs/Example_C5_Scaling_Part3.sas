
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber ps=60 ls=90;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname in 'DIRECTORY_INFO...\posse_data';

*==================================================================================================================

	'Example_C5_Scaling_Part3.sas'  April 2018

  This program reproduces results found in Example C.5 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

===================================================================================================================;
*proc datasets memtype=catalog kill;  ** delete any previous formatting from the SAS session **;
*run;

proc format;
value status 0='Survived' 1='Died';
value cpr 0='No CPR' 1='CPR';
value uncons 0='Conscious' 1='Unconscious';
value emergency 0='Non-Emergency' 1='Emergency';
value omnibus 1='Non-Emergency' 2='Emergency' 3='Emergency/CPR' 4='Emergency/Unconscious'
                5='Emergency/Unconscious/CPR' 6='Subject #208 (Non-Emergency/Unconscious)';
run;

/*----------------------------------------------------------------------*
 | The data set 'icucat' is derived from the data found in Appendix 2   |
 | of Hosmer and Lemeshow, Applied Logistic Regression, Wiley, (1989).  |
 *----------------------------------------------------------------------*/
data one;
  set in.icucat;
run;

ods html;
/*-------------------------------------------*
 | The following produces Tables C.6 and C.7 |
 | in Appendix C of the POSSE users' guide.  |
 *-------------------------------------------*/
proc tabulate data=one format=8.;
class emergency status uncons cpr;
tables (cpr=''*uncons='' all='Totals'),
       (emergency=''*status='' all='Totals')*(n='') / misstext=' ' rts=15;
format emergency emergency. status status. uncons uncons. cpr cpr. ;
title 'Table C.6';
run;

data two;
  set one;
if (emergency=0 and uncons=0 and cpr=0)      then omnibus=1;
else if (emergency=1 and uncons=0 and cpr=0) then omnibus=2;
else if (emergency=1 and uncons=0 and cpr=1) then omnibus=3;
else if (emergency=1 and uncons=1 and cpr=0) then omnibus=4;
else if (emergency=1 and uncons=1 and cpr=1) then omnibus=5;
                                             else omnibus=6;
run;

proc tabulate data=two format=8.;
class omnibus status;
tables (omnibus='Omnibus Variable' all='Totals'),
       (status='' all='Totals')*(n='') / misstext=' ' rts=15;
format omnibus omnibus. status status. ;
title 'Table C.7';
run;

