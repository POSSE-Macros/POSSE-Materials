
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname out 'DIRECORY INFO...\posse_data';
/*-------------------------------------------------------------------------------------*
 | Include the original data set from Michael Friendly's site for data visualizations. |
 *-------------------------------------------------------------------------------------*/
filename icudata url "http://www.datavis.ca/sas/vcd/catdata/icu.sas";
%include icudata;

*====================================================================================================================

	'Example_C2_Derive_Vars_Part1.sas'  June 2018

  This program creates the initial data set which is used in Examples C.2 and C.3 of Appendix C of
  _POSSE Macros Users’ Guide for the Exploration of Observational Health Care Data_.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

=====================================================================================================================;
/*
Name:      icu.sas
Title:     The ICU data
KEYWORDS:  Logistic Regression
SIZE:  200 observations, 21 variables

NOTE:
	These data come from Appendix 2 of Hosmer and Lemeshow (1989).
These data are copyrighted and must be acknowledged and used accordingly.

DESCRIPTIVE ABSTRACT:
	The ICU data set consists of a sample of 200 subjects who were part of
a much larger study on survival of patients following admission to an adult
intensive care unit (ICU).  The major goal of this study was to develop a
logistic regression model to predict the probability of survival to hospital
discharge of these patients and to study the risk factors associated with 
ICU mortality.  A number of publications have appeared which have focused on
various facets of the problem.  The reader wishing to learn more about the
clinical aspects of this study should start with Lemeshow, Teres, Avrunin,
and Pastides (1988).

SOURCE:  Data were collected at Baystate Medical Center in Springfield,
Massachusetts.

REFERENCES:

1.  Hosmer and Lemeshow, Applied Logistic Regression, Wiley, (1989).

2.  Lemeshow, S., Teres, D., Avrunin, J. S., Pastides, H. (1988). Predicting
    the Outcome of Intensive Care Unit Patients. Journal of the American
    Statistical Association, 83, 348-356.
*/

proc sort data=icu;
by died id;

proc datasets memtype=data;
modify icu;
attrib _all_ label=' ';
attrib _all_ format= ;
run;

data icu;
length id status 8;
  set icu;
status = died;
drop died;
run;

proc print data=icu;
run;

/*--------------------------------------------------------------------------------*
 | Remove the asterisks and run these lines to create the permanent SAS data set. |
 *--------------------------------------------------------------------------------*/
*data out.icu;
*  set icu;
*run;

