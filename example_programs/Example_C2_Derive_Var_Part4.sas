
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname in 'DIRECTORY_INFO...\posse_data';
/*-------------------------------------------*
 | Include the file that contains the macro  |
 *-------------------------------------------*/
filename dataprep 'DIRECTORY_INFO...\posse_macros\data_prep.sas';
%include dataprep;

*====================================================================================================================

	'Example_C2_Derive_Vars_Part4.sas'  June 2018

  This program reproduces results found in Example C.2 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

=====================================================================================================================;
/*----------------------------------------------------------------------------------------------------------*
 | Include the original ICU data which was downloaded from Michael Friendly's site for data visualizations. |
 *----------------------------------------------------------------------------------------------------------*/
data icu;
  set in.icu;
run;

proc format;
  value status 0='Survived' 1='Died';
  value agetwo 1='< 35' 2='35-74' 3='75-84' 4='> 84';
  value agethree 1='< 30' 2='30-69' 3='> 69';
run;

/*------------------------------------------*
 | This submission produces Figure C.3      |
 | in Appendix C of the POSSE users' guide. |
 *------------------------------------------*/
%data_prep(
         rawdata=icu,
		 contvar=age,
		 catname=agecat,
		 firstlevel=1,
		 numcutpts=2,
		 cutpoint1=30,
		 cutpoint2=70,
		 cluster=yes,
         response=status,
         predvar=agecat);

proc tree data=_tree_ horizontal pages=1;
id rows;
title "Ward's Cluster Tree";
format rows agethree.;
run;
quit;

