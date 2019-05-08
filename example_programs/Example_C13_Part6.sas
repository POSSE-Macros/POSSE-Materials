options nodate nonumber ps=60 ls=90;

libname in 'DIRECTORY_INFO...\posse_data';
/*--------------------------------------------*
 | Include the files that contain the macros  |
 *--------------------------------------------*/
filename corresp 'DIRECTORY_INFO...\posse_macros\correspondence.sas';
%include corresp;
filename tabulate 'DIRECTORY_INFO...\posse_macros\tabulation.sas';
%include tabulate;

*============================================================================================================

	'Example_C13_Part6.sas' May 2018

  This program duplicates some results found in Example C.13 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

===================================================================================================================;
proc datasets memtype=catalog kill;  ** delete any previous formatting from the SAS session **;
run;

data one;
  set in.symptclusters;

data survey1;
  set one;
if (survey=1);
clustone = symptcluster;
keep id clustone agecat exposure;

data survey2;
  set one;
if (survey=2);
clusttwo = symptcluster;
keep id clusttwo;

data all;
  merge survey1 survey2;
by id;

data suball;
  set all;
if (clustone=clusttwo) then delete;
if (clustone=5 or clusttwo=5) then delete;  ** Remove fifth cluster from the analysis. **;
run;

/*--------------------------------------------*
 | NOTE THAT THE NUMBER OF NON-MISSING LEVELS |
 | MUST MATCH THE NUMBER OF FORMAT LABELS.    |
 *--------------------------------------------*/
proc format cntlout=othrfmt1;						*required formats for other variables;
value clustone 1='Norm' 2='HvyEx' 3='Cold' 4='Asth' 5='Other';
value clusttwo 1='Norm' 2='HvyEx' 3='Cold' 4='Asth' 5='Other';
value agecat 1='Younger' 2='Older';
value exposure 1='LoExp' 2='HiExp';
run;

/*------------------------------------------*
 | This submission produces Figure C.21     |
 | in Appendix C of the POSSE users' guide. |
 *------------------------------------------*/
%correspondence(
         dataset=suball,
         response=clustone,
         fmtresp=clustone,
         explanvars=exposure,
         covars=agecat,
         fmtothr=othrfmt1,
		 id=id,
		 onedim=,
		 twodim=yes,
		 showobs=,
		 stratavar=clusttwo,
         fmtstrata=clusttwo,
		 highlightobs=, 
		 circlelevel=, 
		 noplot=);

/*--------------------------------------------------------*
 | The following submissions produce Tables C.20(a), C.21 |
 | and C.22 in Appendix C of the POSSE users' guide.      |
 *--------------------------------------------------------*/
%tabulation(
         dataset=all,
         response=clustone,
         fmtresp=clustone,
         secondvar=clusttwo,
         thirdvar=,
         byvar=,
		 perc=no,
		 id=id,
		 rowresp=yes,
		 range1=1 to 5,
		 range2=1 to 5);

%tabulation(
         dataset=all,
         response=clustone,
         fmtresp=clustone,
         secondvar=clusttwo,
         thirdvar=agecat,
         byvar=,
		 perc=no,
		 id=id,
		 rowresp=yes,
		 range1=1 to 5,
		 range2=1 to 5,
		 range3=1 to 2);

%tabulation(
         dataset=all,
         response=clustone,
         fmtresp=clustone,
         secondvar=clusttwo,
         thirdvar=exposure,
         byvar=,
		 perc=no,
		 id=id,
		 rowresp=yes,
		 range1=1 to 5,
		 range2=1 to 5,
		 range3=1 to 2);

