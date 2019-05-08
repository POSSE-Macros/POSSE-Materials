
options nodate nonumber ps=60 ls=90;
libname in 'DIRECTORY_INFO...\posse_data';
/*--------------------------------------------*
 | Include the files that contain the macros  |
 *--------------------------------------------*/
filename corresp 'DIRECTORY_INFO...\posse_macros\correspondence.sas';
filename tabulate 'DIRECTORY_INFO...\posse_macros\tabulation.sas';
%include corresp tabulate;

*============================================================================================================

	'Example_C12_Part3.sas' June 2018

  This program reproduces results found in Example C.12 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

===================================================================================================================;
*proc datasets memtype=catalog kill;  ** delete any previous formatting from the SAS session **;
*run;

data allratings;
  set in.allratings;  ** x-ray classifications from both rounds from nine doctors **;

data subset_ratings;
  set allratings;
if (ratingone=ratingtwo) then delete;
run;

/*--------------------------------------------*
 | NOTE THAT THE NUMBER OF NON-MISSING LEVELS |
 | MUST MATCH THE NUMBER OF FORMAT LABELS.    |
 *--------------------------------------------*/
proc format cntlout=othrfmt1;					*required formats for other variables;
value ratingone 1='1' 2='2' 3='3' 4='4' 5='5' 6='6' 7='7' 8='8' 9='9' 10='10';
value ratingtwo 1='1' 2='2' 3='3' 4='4' 5='5' 6='6' 7='7' 8='8' 9='9' 10='10';
value rater 1='R1' 2='R2' 3='R3' 4='R4' 5='R5' 6='R6' 7='R7' 8='R8' 9='R9';
run;

/*-------------------------------------------------------*
 | These submissions produce results for Figure C.16 and |
 | Table C.17 in Appendix C of the POSSE users' guide.   |
 *-------------------------------------------------------*/
%correspondence(
         dataset=subset_ratings,
         response=ratingone,
         fmtresp=ratingone,
         explanvars=rater,
         covars=,
         fmtothr=othrfmt1,
		 id=id,
		 onedim=,
		 twodim=yes,
		 showobs=,
		 stratavar=ratingtwo,
         fmtstrata=ratingtwo,
		 highlightobs=, 
		 circlelevel=, 
		 noplot=);

proc format cntlout=othrfmt1;					*required formats for other variables;
value ratingone 1='0/0' 2='0/1' 3='1/0' 4='1/1' 5='1/2' 6='2/1' 7='2/2' 8='2/3' 9='3/2' 10='3/3';
value ratingtwo 1='0/0' 2='0/1' 3='1/0' 4='1/1' 5='1/2' 6='2/1' 7='2/2' 8='2/3' 9='3/2' 10='3/3';
value rater 1='R1' 2='R2' 3='R3' 4='R4' 5='R5' 6='R6' 7='R7' 8='R8' 9='R9';
run;

%tabulation(
         dataset=allratings,
         response=ratingone,
         fmtresp=ratingone,
         secondvar=ratingtwo,
         thirdvar=rater,
         byvar=,
		 id=id,
		 perc=no,
		 rowresp=yes,
		 range1=,
		 range2=,
		 range3=);

