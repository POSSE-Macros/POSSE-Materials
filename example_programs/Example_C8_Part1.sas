
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname in 'DIRECTORY_INFO...\posse_data';
/*-------------------------------------------*
 | Include the file that contains the macro  |
 *-------------------------------------------*/
filename corresp 'DIRECTORY_INFO...\posse_macros\correspondence.sas';
%include corresp;

*====================================================================================================================

	'Example_C8_Part1.sas'  May 2018

  This program reproduces results found in Example C.8 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

=====================================================================================================================;
proc datasets memtype=catalog kill;  ** delete any previous formatting from the SAS session **;
run;

data cancer_information;
  set in.cancer_information; ** Data from Lombard and Doering (1947) study **;
run;

proc format cntlout=othrfmt1;
  value radio     0='NoRad' 1='Radio';
  value reading   0='NoRead' 1='SldRead';
  value papers    0='NoPap' 1='Papers';
  value lectures  0='NoLec' 1='Lecture';
  value knowledge 0='PoorKnow' 1='GoodKnow';
run;

/*----------------------------------------------------------------------------------------------------------*
 | This submission approximates Figure C.11 in Appendix C of the POSSE users' guide.  Because the solution  |
 | is one-dimensional, the y-coordinates are randomly assigned to avoid the overplotting of labels.         |
 *----------------------------------------------------------------------------------------------------------*/
%correspondence(
         dataset=cancer_information,
         response=knowledge,
         fmtresp=knowledge,
         explanvars=radio reading papers lectures,
         covars=,
         fmtothr=othrfmt1,
		 id=id,
		 onedim=yes,
		 twodim=,
		 showobs=,
		 stratavar=,
         fmtstrata=,
		 highlightobs=, 
		 circlelevel=, 
		 noplot=);

