
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;

 /*-------------------------------------------------------------------*
  *                                                                   *
  *  Bill Miller  <wem0@cdc.gov>                                      *
  *  April 2013   Last edited in November 2016                        *
  *                                                                   *
  *  DISCLAIMER:  The five POSSE macros are provided to SAS users     *
  *  who wish to perform global exploratory analyses near the         *
  *  beginning of a data analysis.  However, they assume a working    *
  *  knowledge of correspondence analysis and homogeneity analysis.   *
  *  In addition, CDC and NIOSH do not warrant the reliability or     *
  *  accuracy of the software, graphics or text.                      *
  *-------------------------------------------------------------------*
  *                                                                   *
  *  TABULATION.SAS  Creates tables using PROC TABULATE for either    *
  *                  two or three variables.                          *
  *                                                                   *
  *  This macro creates crosstabulations for either two or three      *
  *  variables.  The user provides the name of the dataset contain-   *
  *  ing the variables, the formatting for the outcomes (which is     *
  *  optional), the names for the second and the (optional) third     *
  *  variables, a possible by-variable, and the ID variable for the   *
  *  observations.  When there are no non-missing values for a var-   *
  *  iable, then entries for the 'range1=' thru 'range3=' insertions  *
  *  can be given which will then prevent the corresponding row or    *
  *  column from being deleted from the table.                        *
  *-------------------------------------------------------------------*/

%macro tabulation(		    /*--------------------------------------*/
         dataset=,			/* -- Dataset to be analyzed            */
         response=,         /* -- Outcome or response variable      */
         fmtresp=,		 	/* -- Formatting for outcome (optional) */
         secondvar=,        /* -- Second variable (required)        */
         thirdvar=,         /* -- Third variable (optional)         */
		 byvar=,            /* -- by-variable                       */
		 id=,               /* -- ID for observations               */ 
		 perc=,             /* -- Enter 'No' for no row percentages */ 
		 			  		/*--------------------------------------*/
		 			  		/*    -OPTIONAL-                        */
		 rowresp=,	        /* -- Enter 'Yes' to make the response  */
		                    /*    a row instead of column variable  */
		         		    /*                                      */
		 range1=,		    /* -- Range for outcome variable        */
		 					/*    (e.g., '1 to 5')                  */
		 range2=,		    /* -- Range for second variable         */
		 					/*    (e.g., '0 to 1')                  */
		 range3=);		    /* -- Range for third variable          */
		 					/*    (e.g., '0 to 2')                  */
                       		/*--------------------------------------*/
ods html;

%let perc=%upcase(&perc);
%let rowresp=%upcase(&rowresp);

proc format;
   picture pctfmt (round) low-high='009 %';
run;

data _zzz_;
  set &dataset ;
keep &id &response &secondvar &thirdvar &byvar ;
run;

%if %length(&byvar)  %then %do;
proc sort data=_zzz_;
by &byvar ;
run;
%end;


%if &rowresp=YES %then %do;
/*------------------------------------*
 | Crosstabulation of three variables |
 *------------------------------------*/
%if %length(&thirdvar)  %then %do;
%if %length(&range1)  %then %do;
data classes;
 do &response=&range1;
  do &secondvar=&range2;
   do &thirdvar=&range3;
	 output;
   end;
  end;
 end;
proc tabulate data=_zzz_ format=7.0 classdata=classes exclusive;
%end;
%else %do;
proc tabulate data=_zzz_ format=7.0;
%end;
%if %length(&byvar)  %then %do;
by &byvar ;
%end;
class &response &secondvar &thirdvar ;
%if &perc=NO %then %do;
tables (&thirdvar=''*&response='' all='Total'),
  (&secondvar='' all='Total')*(n=' '*f=7.0) / misstext=' ' rts=25;
%end;
%else %do;
tables (&thirdvar=''*&response='' all='Total'),
  (&secondvar='' all='Total')*(n=' '*f=7.0 rowpctn*f=pctfmt9.) / misstext=' ' rts=25;
%end;
title "cross-tabulation of &response. (IN ROWS) by &secondvar. and &thirdvar.";
%if %length(&fmtresp)  %then %do;
format &response &fmtresp.. &secondvar &secondvar.. &thirdvar &thirdvar.. ;
%end;
%else %do;
format &secondvar &secondvar.. &thirdvar &thirdvar.. ;
%end;
run;
quit;
%end;

/*----------------------------------*
 | Crosstabulation of two variables |
 *----------------------------------*/
%else %do;
%if %length(&range1)  %then %do;
data classes;
 do &response=&range1;
  do &secondvar=&range2;
	 output;
  end;
 end;

proc tabulate data=_zzz_ format=7.0 classdata=classes exclusive;
%end;
%else %do;
proc tabulate data=_zzz_ format=7.0;
%end;
class &response &secondvar ;
%if &perc=NO %then %do;
tables (&response='' all='Total'),
  (&secondvar='' all='Total')*(n=' '*f=7.0) / misstext=' ' rts=25;
%end;
%else %do;
tables (&response='' all='Total'),
  (&secondvar='' all='Total')*(n=' '*f=7.0 rowpctn*f=pctfmt9.) / misstext=' ' rts=25;
%end;
title "cross-tabulation of &response. (IN ROWS) by &secondvar.";
%if %length(&fmtresp)  %then %do;
format &response &fmtresp.. &secondvar &secondvar.. ;
%end;
%else %do;
format &secondvar &secondvar.. ;
%end;
run;
quit;
%end;
%end;

%else %do;
/*------------------------------------*
 | Crosstabulation of three variables |
 *------------------------------------*/
%if %length(&thirdvar)  %then %do;
%if %length(&range1)  %then %do;
data classes;
 do &response=&range1;
  do &secondvar=&range2;
   do &thirdvar=&range3;
	 output;
   end;
  end;
 end;
proc tabulate data=_zzz_ format=7.0 classdata=classes exclusive;
%end;
%else %do;
proc tabulate data=_zzz_ format=7.0;
%end;
%if %length(&byvar)  %then %do;
by &byvar ;
%end;
class &response &secondvar &thirdvar ;
%if &perc=NO %then %do;
tables (&thirdvar=''*&secondvar='' all='Total'),
  (&response='' all='Total')*(n=' '*f=7.0) / misstext=' ' rts=25;
%end;
%else %do;
tables (&thirdvar=''*&secondvar='' all='Total'),
  (&response='' all='Total')*(n=' '*f=7.0 rowpctn*f=pctfmt9.) / misstext=' ' rts=25;
%end;
title "cross-tabulation of &response. (IN COLUMNS) by &secondvar. and &thirdvar.";
%if %length(&fmtresp)  %then %do;
format &response &fmtresp.. &secondvar &secondvar.. &thirdvar &thirdvar.. ;
%end;
%else %do;
format &secondvar &secondvar.. &thirdvar &thirdvar.. ;
%end;
run;
quit;
%end;

/*----------------------------------*
 | Crosstabulation of two variables |
 *----------------------------------*/
%else %do;
%if %length(&range1)  %then %do;
data classes;
 do &response=&range1;
  do &secondvar=&range2;
	 output;
  end;
 end;

proc tabulate data=_zzz_ format=7.0 classdata=classes exclusive;
%end;
%else %do;
proc tabulate data=_zzz_ format=7.0;
%end;
class &response &secondvar ;
%if &perc=NO %then %do;
tables (&secondvar='' all='Total'),
  (&response='' all='Total')*(n=' '*f=7.0) / misstext=' ' rts=25;
%end;
%else %do;
tables (&secondvar='' all='Total'),
  (&response='' all='Total')*(n=' '*f=7.0 rowpctn*f=pctfmt9.) / misstext=' ' rts=25;
%end;
title "cross-tabulation of &response. (IN COLUMNS) by &secondvar.";
%if %length(&fmtresp)  %then %do;
format &response &fmtresp.. &secondvar &secondvar.. ;
%end;
%else %do;
format &secondvar &secondvar.. ;
%end;
run;
quit;
%end;
%end;

proc format;
picture pctfmt (round);
run;

%mend tabulation;

