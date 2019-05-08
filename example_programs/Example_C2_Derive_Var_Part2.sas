
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname in 'DIRECTORY_INFO...\posse_data';
/*-------------------------------------------*
 | Include the file that contains the macro  |
 *-------------------------------------------*/
filename dataprep 'DIRECTORY_INFO...\posse_macros\data_prep.sas';
%include dataprep;

*====================================================================================================================

	'Example_C2_Derive_Vars_Part2.sas'  June 2018

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
if (age < 25)            then agegrp=1;
else if (25 <= age < 35) then agegrp=2;
else if (35 <= age < 45) then agegrp=3;
else if (45 <= age < 55) then agegrp=4;
else if (55 <= age < 65) then agegrp=5;
else if (65 <= age < 75) then agegrp=6;
else if (75 <= age < 85) then agegrp=7;
                         else agegrp=8;
run;

proc format;
  value status 0='Survived' 1='Died';
  value agegrp 1='< 25' 2='25-34' 3='35-44' 4='45=54' 5='55-64' 6='65-74' 7='75-84' 8='> 84';
run;

/*--------------------------------------------*
 | This provides the frequencies of Table C.1 |
 | in Appendix C of the POSSE users' guide.   |
 *--------------------------------------------*/
proc tabulate data=icu format=8.;
class agegrp status;
tables (agegrp='Age Categories' all='Totals'),
       (status='' all='Totals')*(n='') / misstext=' ' rts=15;
format agegrp agegrp. status status. ;
title 'Frequencies for Table C.1';
run;
quit;

/*------------------------------------------*
 | This submission produces Figure C.1      |
 | in Appendix A of the POSSE users' guide. |
 *------------------------------------------*/
%data_prep(
         rawdata=icu,
		 cluster=yes,
         response=status,
         predvar=agegrp);

proc tree data=_tree_ horizontal pages=1;
id rows;
title "Ward's Cluster Tree";
format rows agegrp.;
run;
quit;

