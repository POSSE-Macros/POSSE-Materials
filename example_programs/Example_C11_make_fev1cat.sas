
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname in 'DIRECTORY_INFO...\posse_data';
/*--------------------------------------------*
 | Include the files that contain the macros  |
 *--------------------------------------------*/
filename dataprep 'DIRECTORY_INFO...\posse_macros\data_prep.sas';
filename tabulate 'DIRECTORY_INFO...\posse_macros\tabulation.sas';
%include dataprep tabulate;

*====================================================================================================================

	'Example_C11_make_fev1cat.sas'  June 2018

  This program reproduces results found in Example C.11 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

=====================================================================================================================;
data splitdata;
  set in.fev1;   ** must be sorted by ID variable **;
drop janfev marfev;
survey=1; score = janfev; output;
survey=2; score = marfev; output;
keep id score;
run;

%data_prep(
         rawdata=splitdata,
         contvar=score,
         id=id,
         catname=catscore,
         firstlevel=1,
         ranklevs=3,
         outdata=pooled,  
         savevars=catscore);

proc transpose data=pooled out=transpool prefix=survey;
by id;
var catscore;

data fev1cat;
  set transpool (rename=(survey1=firstfev survey2=secondfev));
drop _name_;
run;

proc format;
value firstfev 1='LoFEV1' 2='MidFEV1' 3='HiFEV1';
value secondfev 1='LoFEV1' 2='MidFEV1' 3='HiFEV1';
run;

/*------------------------------------------*
 | This submission produces Tables C.15     |
 | in Appendix C of the POSSE users' guide. |
 *------------------------------------------*/
%tabulation(
         dataset=fev1cat,
         response=firstfev,
         fmtresp=firstfev,
         secondvar=secondfev,
		 id=id,
		 perc=no,
		 rowresp=yes);


