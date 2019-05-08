
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname out 'DIRECTORY_INFO...\posse_data';
/*-------------------------------------------*
 | Include the file that contains the macro  |
 *-------------------------------------------*/
filename dataprep 'DIRECTORY_INFO...\posse_macros\data_prep.sas';
%include dataprep;

*====================================================================================================================

	'Example_C3_make_icucat.sas'  April 2018

  This program reproduces results found in Example C.3 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

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

/*-------------------------------------------------------------------------------------*
 | Include the original data set from Michael Friendly's site for data visualizations. |
 *-------------------------------------------------------------------------------------*/
filename icudata url "http://www.datavis.ca/sas/vcd/catdata/icu.sas";
%include icudata;

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
** New variable names are assigned **;
status = died;
uncons = (coma > 0);
gender = sex;
surgery = service;
race = (race=1);
emergency = admit;
bldoxy = po2;
bldph = ph;
bldco = pco;
bldbic = bic;
bldcret = creatin;
drop died sex admit service admit po2 ph pco bic creatin;
run;

** The cutpoints for the categorical age variable. **;
%data_prep(
         rawdata=icu,
         contvar=age,
		 catname=agecat,
		 firstlevel=1,
		 numcutpts=2,
		 cutpoint1=30,
		 cutpoint2=70);

** Create categorical variables:  bloodpress heartrate **;
** From the continuous variables: systolic hrtrate **;
%data_prep(
         rawdata=icu,
		 newdata=YES,
         contvar=systolic,
		 catname=bloodpress,
		 firstlevel=1,
		 numcutpts=2,
		 cutpoint1=90,
		 cutpoint2=140);

%data_prep(
         rawdata=icu,
		 newdata=YES,
         contvar=hrtrate,
		 catname=heartrate,
		 firstlevel=1,
		 numcutpts=2,
		 cutpoint1=60,
		 cutpoint2=100,
		 outdata=icucat,
		 id=id, 
		 savevars=status gender surgery cancer renal infect cpr previcu emergency fracture bldoxy bldph bldco bldbic bldcret uncons coma race agecat bloodpress heartrate);

proc contents data=icucat position;
run;

/*--------------------------------------------------------------------------------*
 | Remove the asterisks and run these lines to create the permanent SAS data set. |
 *--------------------------------------------------------------------------------*/
*data out.icucat;
*  set icucat;
*run;

/*
proc freq data=icucat;
tables status gender surgery cancer renal infect cpr previcu emergency fracture bldoxy bldph bldco bldbic bldcret uncons coma race
       agecat bloodpress heartrate;
run;
*/
