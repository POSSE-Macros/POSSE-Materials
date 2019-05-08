
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber ps=60 ls=90;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname in 'DIRECTORY_INFO...\posse_data';
/*-------------------------------------------*
 | Include the file that contains the macro  |
 *-------------------------------------------*/
filename classify 'DIRECTORY_INFO...\posse_macros\classification.sas';
%include classify;


*==================================================================================================================

	'Example_C5_Scaling_Part2.sas'  April 2018

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

/*----------------------------------------------------------------------*
 | The data set 'icucat' is derived from the data found in Appendix 2   |
 | of Hosmer and Lemeshow, Applied Logistic Regression, Wiley, (1989).  |
 *----------------------------------------------------------------------*/
data icudat;
  set in.icucat;
emerg = emergency;
run;

/*---------------------------------------------*
 | This submission produces Tables C.4 and C.5 |
 | in Appendix C of the POSSE users' guide.    |
 *---------------------------------------------*/
%classification(
           data=icudat,
           var=,
           print=,
           ndim1=,
           ndim2=,
           ndim3=,
           sub=,
           noprint=,
		   haclust=cpr uncons emerg surgery cancer,
		   fitclust=,
		   nclust=2,
		   id=id,
		   allbin=yes,
		   out=tempclust,
		   printfreqs=yes);

proc sort data=icudat;
by id;

proc sort data=tempclust;
by id;

data alldat;
  merge tempclust icudat;
by id;

proc sort data=alldat;
by descending dim1;
run;

data ids;
  set alldat;
if _n_ in (12,18,144,147);

proc format;
value cpr 0='No CPR' 1='CPR'; value uncons 0='Conscious' 1='Unconscious'; value emerg 0='Non-Emergency' 1='Emergency';
value surgery 0='No Surgery' 1='Surgery'; value cancer 0='No Cancer' 1='Cancer'; value status 0='Survived' 1='Died';
run;

proc print data=ids;
var id cpr uncons emerg surgery cancer status;
format cpr cpr. uncons uncons. emerg emerg. surgery surgery. cancer cancer. status status.;
title 'Singleton Profiles';
run;

data subfreqs;
   set profile_freqs;
if (count > 2);
drop cum_freq;

proc print data=subfreqs split='*';
title 'Table C.5 with 192 Subjects';
run;

