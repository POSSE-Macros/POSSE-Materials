
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber ps=60 ls=90;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname in 'DIRECTORY_INFO...\posse_data';
/*-------------------------------------------*
 | Include the file that contains the macro  |
 *-------------------------------------------*/
filename classify 'DIRECTORY_INFO...\posse_macros\classification.sas';
%include classify;

*==================================================================================================================

	'Example_C7_Cluster_Variable_Part3.sas'  April 2018

  This program reproduces results found in Example C.7 of Appendix C of _POSSE Macros Users’ Guide for the
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
array x[7] bldoxy bldph bldco bldbic bldcret bloodpress heartrate;
array y[7] oxy ph co bic creat bp hr;
do i=1 to 7;
  y[i]= x[i];
end;
keep id oxy ph co bic creat bp hr;
run;

/*------------------------------------------*
 | This submission produces Table C.8       |
 | in Appendix C of the POSSE users' guide. |
 *------------------------------------------*/
%classification(
           data=icudat,
           var=oxy ph co bic creat bp hr,
           print=,
           ndim1=,
           ndim2=,
           ndim3=,
           sub=,
           noprint=,
		   haclust=oxy ph co bic creat,
		   fitclust=,
		   nclust=4,
		   id=id,
		   allbin=yes,
		   out=,
		   printfreqs=);

proc format;
value $var_ 'oxy1'='Low Blood Oxygen' 'ph1'='Low Blood PH' 'co1'='High Blood CO2'
            'bic1'='Low Blood BIC' 'creat1'='High Blood Creatinine'
;

proc print data=_proportions_ split='_' double;
id condition;
format _numeric_ 5.2 condition $var_.;
label condition='Condition';
title 'Table C.8';
run;

