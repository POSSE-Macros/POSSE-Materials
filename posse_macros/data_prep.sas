
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;

 /*-------------------------------------------------------------------*
  *                                                                   *
  *  Bill Miller  <wem0@cdc.gov>                                      *
  *  October 2014   Revised January 2018                              *
  *                                                                   *
  *  DISCLAIMER:  The five POSSE macros are provided to SAS users     *
  *  who wish to perform global exploratory analyses near the         *
  *  beginning of a data analysis.  However, they assume a working    *
  *  knowledge of correspondence analysis and homogeneity analysis.   *
  *  In addition, CDC and NIOSH do not warrant the reliability or     *
  *  accuracy of the software, graphics or text.                      *
  *-------------------------------------------------------------------*
  *                                                                   *
  *  DATA_PREP.SAS   Creates dataset with categorical variables for   *
  *                  use by the POSSE methods.                        *
  *                                                                   *
  *  This macro creates a dataset for use by the POSSE method by      *
  *  converting the continuous variables to categorical variables.    *
  *  Descriptive statistics can be produced to assist in the choice   *
  *  of cutpoints, and a method of cluster analysis developed by      *
  *  Greenacre (1988, 2007) can be used to assist in the choice for   *
  *  the number of levels for a categorical variable.                 *
  *                                                                   *
  *  The user must enter the name of the original dataset and the     *
  *  ID variable for the observations.  However, when the new dataset *
  *  will contain more than one variable, then 'YES' must be inserted *
  *  at the 'newdata=' entry after the first run of the macro.        *
  *                                                                   *
  *  In order to convert a continous variable to a categorical one,   *
  *  the user may first enter the name of the continous variable at   *
  *  'contvar=' and then 'YES' at 'plotdist=' to obtain information   *
  *  about the distribution of the continuous variable.  After        *
  *  examining this information, the user can transform the variable  *
  *  to a categorical variable in one of two ways.  The first is to   *
  *  insert the number of levels for the categorical variable at      *
  *  'ranklevs=' to use PROC RANK to automatically create the new     *
  *  variable.  This will usually result in each level have the same  *
  *  or nearly the same number of observations.                       *
  *                                                                   *
  *  The second way to create the new categorical variable is to      *
  *  insert the number of cutpoints at 'numcutpts=' and then to       *
  *  insert up to five cutpoints at the macro entries that are        *
  *  provided.  Note that the number of levels for the new variable   *
  *  will be one more than the number of cutpoints.  In addition,     *
  *  if there are any missing outcomes, then another level will be    *
  *  created for these outcomes.  For example, if there are three     *
  *  cutpoints and some missing values, then there will be five       *
  *  levels for the categorical variable.                             *
  *                                                                   *
  *  By inserting 'YES' at 'cluster=', the user is able to perform    *
  *  a cluster analysis on the rows of a two-way table, as shown in   *
  *  the papers by Greenacre (1988, 2007).  The rows of the table     *
  *  represent the levels of the 'predvar=' variable and the columns  *
  *  represent the levels of the 'response=' variable.  The results   *
  *  include a cluster tree (also called a dendogram) which indicates *
  *  the stages at which the rows are combined.  The rows with the    *
  *  most similar profiles are combined first and near the left of    *
  *  the cluster tree.  The printout also shows the R-Square for the  *
  *  number of clusters.  For example, if the 'predvar' variable has  *
  *  four levels and the R-square equals .90 for three clusters, then *
  *  this means that only about 10% of the information would be lost  *
  *  when combining two of the four levels into one combined level.   *
  *                                                                   *
  *  Although the methods are otherwise identical, Greenacre (2007)   *
  *  expresses the results in terms of a chi-square scale, but the    *
  *  results here are expressed in terms of the between sums-of-      *
  *  squares which are calculated from Ward's method of clustering.   *
  *  Ward's method is known to be sensitive to outliers.  In the      *
  *  context of these methods, an example of an outlier would be a    *
  *  row with a very small number of counts and where the profile of  *
  *  the counts differs dramatically from the other row profiles.     *
  *                                                                   *
  *  Finally, once the data creation is completed (and not before),   *
  *  the new dataset can be named and saved using the 'outdata='      *
  *  entry, and the variables to be saved can be inserted into the    *
  *  'savevars=' entry.  The ID variable is automatically included    *
  *  in the new dataset.                                              *
  *                                                                   *
  *  REFERENCES                                                       *
  *  --Greenacre, M. (1988), "Clustering the Rows and Columns of a    *
  *  Contingency Table," Journal of Classification, 5: 39-51.         *
  *  --Greenacre, M. (2007), Correspondence Analysis in Practice      *
  *  (Second Edition), Chapman & Hall, New York.                      *
  *-------------------------------------------------------------------*/

%macro data_prep( 		    /*--------------------------------------*/
         rawdata=,			/* -- Original dataset                  */
         newdata=,			/* -- Set to YES after creating the     */
		 			  		/*    first new categorical variable.   */
         contvar=,		 	/* -- Continuous variable               */
		 plotdist=,         /* -- YES gives distribution plots      */
		 			  		/*    for the continuous variable.      */
		 			  		/*--------------------------------------*/
		 catname=,          /* -- Name for new categorical variable */
		 			  		/*    created from continuous variable. */
		 firstlevel=,       /* -- 1st level equals '1' (default=0)  */
		 			  		/*--------------------------------------*/
		 			  		/*  USE PROC RANK FOR NEW CAT. VARIABLE */
		 ranklevs=,         /* -- Number of levels for continuous   */
		                    /*       variable using PROC RANK       */
		 			  		/*--------------------------------------*/
		 			  		/*  USE CUTPOINTS FOR NEW CAT. VARIABLE */
		 numcutpts=,        /* -- Number of cutpoint for continuous */
		                    /*    variable (= number of levels - 1) */
		 cutpoint1=,        /* -- 1st cutpoint                      */
		 cutpoint2=,        /* -- 2nd cutpoint                      */
		 cutpoint3=,        /* -- 3rd cutpoint                      */
		 cutpoint4=,        /* -- 4th cutpoint                      */
		 cutpoint5=,        /* -- 5th cutpoint                      */
		 	  		  		/*--------------------------------------*/
         cluster=,          /* -- YES to perform cluster analysis   */
		 			  		/*    for RESPONSE and PREDVAR vars     */
         response=,         /* -- Categorical response variable     */
         predvar=,          /* -- Categorical predictor variable    */
		 			  		/*--------------------------------------*/
		 outdata=,          /* -- Name for output dataset (USE THIS */
		 			  		/*    ENTRY AFTER ALL DATA IS CREATED)  */
		 id=,               /* -- ID for observations (required     */
		 			  		/*    when outputting the dataset)      */
		 savevars=);        /* -- Variables saved to the outputted  */
		 			  		/*  dataset (ID is automatically saved) */
		 			  		/*--------------------------------------*/


ods html;
ods graphics on;

%if (%length(&outdata) and %length(&id)=0) %then %do;
  %put ERROR: ID Entry Is Required When Saving Data ;
  %goto done;
%end;

%let newdata=%upcase(&newdata);
%if &newdata=YES %then %do;
data _alldata_;
  set _newalldata_;
run;
%end;
%else %do;
data _alldata_;
  set &rawdata ;
run;
%end;

/*--------------------------------------------*
 | Distribution plots for continuous variable |
 *--------------------------------------------*/
%let plotdist=%upcase(&plotdist);
%if &plotdist=YES %then %do;
proc univariate data=_alldata_ plot normal;
var &contvar ;
title;
run;
%end;

/*---------------------------------------------*
 | Create categorical variable using PROC RANK |
 *---------------------------------------------*/
%if %length(&ranklevs)  %then %do;
proc rank data=_alldata_ groups=&ranklevs out=_alldata_;
ranks &catname ;
var &contvar;
title;
run;
data _alldata_;
  set _alldata_;
if (&contvar = .) then &catname = &ranklevs ;
run;

/*----------------------------------------*
 | Set 1st level equal to '1' (default=0) |
 *----------------------------------------*/
%if &firstlevel=1 %then %do;
data _alldata_;
  set _alldata_;
&catname = &catname + 1;
run;
%end;
proc freq data=_alldata_;
tables &catname ;
run;
%end;

/*----------------------------------------------*
 | Create categorical variable using cutpoints. |
 *----------------------------------------------*/
%if %length(&numcutpts) %then %do;
%if &numcutpts=5  %then %do;
proc format;
  value tempfmt low - < &cutpoint1 ='0'
                &cutpoint1 - < &cutpoint2 ='1'
				&cutpoint2 - < &cutpoint3 ='2'
				&cutpoint3 - < &cutpoint4 ='3'
				&cutpoint4 - < &cutpoint5 ='4'
				&cutpoint5 - high ='5'
				other ='6'
;
run;
%end;
%if &numcutpts=4  %then %do;
proc format;
  value tempfmt low - < &cutpoint1 ='0'
                &cutpoint1 - < &cutpoint2 ='1'
				&cutpoint2 - < &cutpoint3 ='2'
				&cutpoint3 - < &cutpoint4 ='3'
				&cutpoint4 - high ='4'
				other ='5'
;
run;
%end;
%if &numcutpts=3  %then %do;
proc format;
  value tempfmt low - < &cutpoint1 ='0'
                &cutpoint1 - < &cutpoint2 ='1'
				&cutpoint2 - < &cutpoint3 ='2'
				&cutpoint3 - high ='3'
				other ='4'
;
run;
%end;
%if &numcutpts=2  %then %do;
proc format;
  value tempfmt low - < &cutpoint1 ='0'
                &cutpoint1 - < &cutpoint2 ='1'
				&cutpoint2 - high ='2'
				other ='3'
;
run;
%end;
%if &numcutpts=1  %then %do;
proc format;
  value tempfmt low - < &cutpoint1 ='0'
				&cutpoint1 - high ='1'
				other ='2'
;
run;
%end;

data _alldata_;
  set _alldata_;
&catname = input(put(&contvar,tempfmt.),1.);
run;
/*----------------------------------------*
 | Set 1st level equal to '1' (default=0) |
 *----------------------------------------*/
%if &firstlevel=1 %then %do;
data _alldata_;
  set _alldata_;
&catname = &catname + 1;
run;
%end;
proc freq data=_alldata_;
tables &catname ;
run;
%end;

/*---------------------------*
 | Performs cluster analysis |
 *---------------------------*/
%let cluster=%upcase(&cluster);
%if &cluster=YES %then %do;

data _clustdata_;
  set _alldata_;
run;

/*------------------------------------------------------*
 | Remove observations with missing continuous outcomes |
 *------------------------------------------------------*/
%if %length(&contvar)  %then %do;
proc univariate data=_clustdata_ noprint;
var &predvar;
output out=_temp99_ max=max;

data _temp99_;
  set _temp99_;
call symput('maxcat',left(max));
run;

data _clustdata_;
  set _clustdata_;
if (&contvar=. and &predvar=&maxcat) then delete;
run;
%end;

ods graphics off;
proc corresp data=_clustdata_ dim=1 cross=row rp print=both observed;
tables &predvar, &response;
ods output Observed=_observed_ RowProfiles=_rowprofiles_ ColQualMassIn=_colmass_(keep=mass);
run;
ods graphics on;

proc print data=_observed_;
title 'Contingency Table for Cluster Analysis of the Row Levels';
run;

data _allfmt_;
  set _rowprofiles_;
keep label;

data _profiles_;
  set _rowprofiles_;
drop label;
run;

proc iml;
use _profiles_;
read all into profiles;
use _colmass_;
read all into masses;
use _allfmt_;
read all var{label} into lab1;
computed = profiles / sqrt(masses`);
create _newdata1_ from computed[rowname=lab1];
append from computed[rowname=lab1];
quit;

data _newdata1_;
  set _newdata1_;
rows = input(compress(lab1,' '),8.);
drop lab1;
run;

data _temp1_;
  set _newdata1_;
drop rows;

proc sql noprint;                               
   select nvar                         
   into :nvar              
   from dictionary.tables                      
   where libname='WORK' and memname='_TEMP1_';
quit;

%let colnum=%left(&nvar);

ods graphics off;
proc cluster data=_newdata1_ outtree=_tree_ method=ward nonorm;
id rows;
var col1-col&colnum;
run;
ods graphics on;

proc tree data=_tree_ horizontal pages=1;
id rows;
title "Ward's Cluster Tree";
run;
quit;

%end;

 /*------------------------------------*
  | Output the variables to dataset.   |
  *------------------------------------*/
%if %length(&outdata) %then %do;
proc datasets memtype=data;
modify _alldata_;
attrib _all_ label=' ';
run;

data &outdata ;
  set _alldata_;
keep &id &savevars;
run;
proc print data=&outdata;
title 'New Dataset';
run;
%end;

data _newalldata_;
  set _alldata_;
run;

%done:
title; run;

%mend data_prep;


