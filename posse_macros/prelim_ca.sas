
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;

 /*-------------------------------------------------------------------*
  *                                                                   *
  *  Bill Miller  <wem0@cdc.gov>                                      *
  *  October 2012   / Last edited in November 2016                    *
  *                                                                   *
  *  DISCLAIMER:  The five POSSE macros are provided to SAS users     *
  *  who wish to perform global exploratory analyses near the         *
  *  beginning of a data analysis.  However, they assume a working    *
  *  knowledge of correspondence analysis and homogeneity analysis.   *
  *  In addition, CDC and NIOSH do not warrant the reliability or     *
  *  accuracy of the software, graphics or text.                      *
  *-------------------------------------------------------------------*
  *                                                                   *
  *  PRELIM_CA.SAS  Performs preliminary correspondence analyses for  *
  *               the outcomes, explanatory variables and covariates. *
  *                                                                   *
  *  NOTE: If m is the number of levels for the outcome and n is the  *
  *  total number of levels for all the other variables, then min(m,n)*
  *  should generally be >= 3 to run this program.  If the outcome is *
  *  binary, you can use the optional entry of 'onedim=YES'.  Note    *
  *  that the formats are required for the other variables and the    *
  *  format names must match the names for the other variables.  In   *
  *  addition, the coding for the outcome variable must begin with    *
  *  the number '1'.                                                  *
  *                                                                   *
  *  This macro performs correpondence analyses which indicate the    *
  *  associations among the outcomes, explanatory variables and       *
  *  covariates, as described by the POSSE method.  The user provides *
  *  the name of the dataset containing the variables, the name for   *
  *  the outcome variable and its (optional) formatting, the names    *
  *  for the explanatory variables, the names for the covariates,     *
  *  the name of the required format dataset for the explanatory      *
  *  variables and the covariates, and the ID variable for the        *
  *  observations.                                                    *
  *                                                                   *
  *  Note that the results include the tables of inertias and the     *
  *  correspondence maps for the types of variables which have been   *
  *  provided by the user.  For example, if only the names for the    *
  *  outcomes and covariates are provided, then only these results    *
  *  will be shown (i.e., one table of inertias and one map).         *
  *-------------------------------------------------------------------*/

%macro prelim_ca(			/*--------------------------------------*/
         dataset=,			/* -- Dataset to be analyzed.           */
         response=,         /* -- Outcome variable (> 2 levels)     */
         fmtresp=,		 	/* -- Formatting for outcome (optional) */
         explanvars=,       /* -- Explanatory vars (> 2 levels)     */
         covars=,           /* -- Covariates (> 2 levels)           */
         fmtothr=,		 	/* -- Formats for other vars (required) */
		 id=,               /* -- ID for observations               */ 
		 onedim=);			/* -- Enter YES for 1-dim. solution     */
                       		/*--------------------------------------*/

%if %length(&response) %then %do;
data _outcomes_;
  set &dataset ;
keep &id &response ;
run;
%end;

data _other1_;
  set &dataset ;
%if %length(&response) %then %str(drop &response ;);
run;

proc format cntlin=&fmtothr cntlout=_fmtout1_;
run;

 /*-------------------------------------------------*
  | If a category is missing, its label is deleted. |
  | If a label is missing, the program stops.       |
  *-------------------------------------------------*/
proc freq data=_other1_;
tables &explanvars &covars ;
ods output OneWayFreqs=_allcounts1_;
run;

data _allcounts1_;
length temp1 $10;
  set _allcounts1_;
temp1 = scan(table,2,' ');
category = sum(of &explanvars &covars );
s = 1;
keep temp1 category s;

proc sort data=_allcounts1_;
by temp1 category;

data _fmtout1_;
length temp1 $10;
  set _fmtout1_;
temp1 = lowcase(fmtname);
category = start + 0;

data _fmtout1_;
  merge _fmtout1_ _allcounts1_;
by temp1 category;
if (s=1);
run;

data _nulltemp_;
  set _fmtout1_ end=last;
if (label='') then num+1;
if last then do;
  if (num=0) then q='';
             else q='quit';
  call symput('quest',q);
end;
run;

%if %length(&quest) %then %do;
  %put ERROR: Missing Label(s) ;
  proc print data=_fmtout1_;
  var fmtname category label;
  title 'ERROR: Missing Label(s)';
  run;
  %goto DONE;
%end;
 /*---------------------------*
  | End of edit / April 2015  |
  *---------------------------*/

 /*------------------------------------------------*
  | Display inertias for the contingency tables.   |
  *------------------------------------------------*/
%if (%length(&response) and %length(&explanvars))  %then %do;
data _subother1_;
length &explanvars 8;
  set _other1_;
keep &explanvars;

proc contents data=_subother1_ out=_chekdat_ noprint;

data _chekdat_;
  set _chekdat_;
name2 = upcase(name);
keep name name2 varnum;

proc sort data=_chekdat_;
by name2;

data _fmt1_;
  set _fmtout1_;
name2 = upcase(fmtname);

proc sort data=_fmt1_;
by name2;

data _fmt1_;
  merge _fmt1_ _chekdat_;
by name2;
if (name ne '');
keep label varnum start;

proc sort data=_fmt1_;
by varnum;

proc sort data=_outcomes_;
by &id ;

proc sort data=_other1_;
by &id ;

data _all1_;
length &response &explanvars 8;
  merge _outcomes_ _other1_;
by &id ;
keep &id &response &explanvars ;

proc freq data=_all1_;
tables (&response)*(&explanvars) / chisq noprint;
ods output ChiSq=_chisq_;

data _chisq_fig1_;
  set _chisq_;
if statistic='Phi Coefficient';
inertia = value**2;
pos1 = 1 + index(table,' ');
temp1 = substr(table,pos1,25);
pos2 = -2 + index(temp1,'*');
pos3 = 2 + index(temp1,'*');
outcome = substr(temp1,1,pos2);
expvars = substr(temp1,pos3,12);
keep outcome inertia expvars;
run;
%end;

%if (%length(&response) and %length(&covars))  %then %do;
data _subother1_;
length &covars 8;
  set _other1_;
keep &covars;

proc contents data=_subother1_ out=_chekdat_ noprint;

data _chekdat_;
  set _chekdat_;
name2 = upcase(name);
keep name name2 varnum;

proc sort data=_chekdat_;
by name2;

data _fmt2_;
  set _fmtout1_;
name2 = upcase(fmtname);

proc sort data=_fmt2_;
by name2;

data _fmt2_;
  merge _fmt2_ _chekdat_;
by name2;
if (name ne '');
keep label varnum start;

proc sort data=_fmt2_;
by varnum;

proc sort data=_outcomes_;
by &id ;

proc sort data=_other1_;
by &id ;

data _all2_;
length &response &covars 8;
  merge _outcomes_ _other1_;
by &id ;
keep &id &response &covars ;

proc freq data=_all2_;
tables (&response)*(&covars) / chisq noprint;
ods output ChiSq=_chisq_;

data _chisq_fig2_;
  set _chisq_;
if statistic='Phi Coefficient';
inertia = value**2;
pos1 = 1 + index(table,' ');
temp1 = substr(table,pos1,25);
pos2 = -2 + index(temp1,'*');
pos3 = 2 + index(temp1,'*');
outcome = substr(temp1,1,pos2);
expvars = substr(temp1,pos3,12);
keep outcome inertia expvars;
run;
%end;

%if (%length(&explanvars) and %length(&covars))  %then %do;
proc freq data=_other1_;
tables (&explanvars)*(&covars) / chisq noprint;
ods output ChiSq=_chisq_;

data _chisq_fig3_;
  set _chisq_;
if statistic='Phi Coefficient';
inertia = value**2;
pos1 = 1 + index(table,' ');
temp1 = substr(table,pos1,25);
pos2 = -2 + index(temp1,'*');
pos3 = 2 + index(temp1,'*');
outcome = substr(temp1,1,pos2);
expvars = substr(temp1,pos3,12);
keep outcome inertia expvars;
run;
%end;

ods _all_ close;
ods html;
run;

%if (%length(&response) and %length(&explanvars))  %then %do;
proc tabulate data=_chisq_fig1_ format=7.3;
class outcome expvars;
var inertia;
tables (expvars='EXPLANATORY VARIABLES' all='Ave'),
  (outcome='OUTCOMES')*(inertia=''*mean=' '*f=7.3) / misstext=' ' rts=24;
title 'Inertias for Contingency Tables Associated with Fig. A';
run;
%end;

%if (%length(&response) and %length(&covars))  %then %do;
proc tabulate data=_chisq_fig2_ format=7.3;
class outcome expvars;
var inertia;
tables (expvars='COVARIATES' all='Ave'),
  (outcome='OUTCOMES')*(inertia=''*mean=' '*f=7.3) / misstext=' ' rts=24;
title 'Inertias for Contingency Tables Associated with Fig. B';
run;
%end;

%if (%length(&explanvars) and %length(&covars))  %then %do;
proc tabulate data=_chisq_fig3_ format=10.3;
class outcome expvars;
var inertia;
tables (expvars='COVARIATES' all='Ave'),
  (outcome='EXPLANATORY VARIABLES' all='Ave')*(inertia=''*mean=' '*f=10.3) / misstext=' ' rts=18;
title 'Inertias for Contingency Tables Associated with Fig. C';
run;
%end;

ods html;
ods graphics / reset antialias=off width=11in;

 /*-----------------------------------*
  | Display the correspondence maps.  |
  *-----------------------------------*/
%let onedim=%upcase(&onedim);

%if (%length(&response) and %length(&explanvars))  %then %do;

%if &onedim=YES %then %do;
proc corresp data=_all1_ dim=1 outc=_coor_ noprint;
tables &response, &explanvars ;
%if %length(&fmtresp) %then %str(format &response &fmtresp..;);
run;

data _null_;
  set _coor_;
if _type_ = 'INERTIA';
perc1 = 100;
perc2 = 0;
p1 = put(left(perc1),4.1);
p2 = put(left(perc2),4.1);
call symput('p1',p1);
call symput('p2',p2);

data _coor_vars_;
  set _coor_;
if _type_='VAR';

data _coor_vars_;
length label color $15;
  merge _coor_vars_ _fmt1_;
x=dim1;
y = (ranuni(798449515) - .5) / 10;
textsize = 4 + 16 * sqcos1;
color='RED';
output;
keep x y label textsize color;

data _coor_obs_;
length label color $15;
  set _coor_;
if _type_='OBS';
x=dim1;
y = (ranuni(479895151) - .5) / 10;
label=_name_;
textsize = 4 + 16 * sqcos1;
color='BLACK';
output;
keep x y label textsize color;

data _coor1_;
  set _coor_vars_ _coor_obs_;
run;
%end;
%else %do;
proc corresp data=_all1_ dim=2 outc=_coor_ noprint;
tables &response, &explanvars ;
%if %length(&fmtresp) %then %str(format &response &fmtresp..;);
run;

data _null_;
  set _coor_;
if _type_ = 'INERTIA';
perc1 = 100 * contr1 / inertia;
perc2 = 100 * contr2 / inertia;
p1 = put(left(perc1),4.1);
p2 = put(left(perc2),4.1);
call symput('p1',p1);
call symput('p2',p2);

data _coor_vars_;
  set _coor_;
if _type_='VAR';

data _coor_vars_;
length label color $15;
  merge _coor_vars_ _fmt1_;
x=dim1;
y=dim2;
textsize = 4 + 16 * quality;
color='RED';
output;
keep x y label textsize color;

data _coor_obs_;
length label color $15;
  set _coor_;
if _type_='OBS';
x=dim1;
y=dim2;
label=_name_;
textsize = 4 + 16 * quality;
color='BLACK';
output;
keep x y label textsize color;

data _coor1_;
  set _coor_vars_ _coor_obs_;
run;
%end;

 /*-------------------------------------*
  | Conversion to SGPLOT / January 2015 |
  *-------------------------------------*/
data _newcoor1_;
length function $9 label $15 textcolor $15;
   set _coor1_;
if (color in ('RED','BLACK'));
retain x1space 'datavalue' y1space 'datavalue';
function='text'; x1=x; y1=y; textcolor=color; width=40;
keep function textcolor textsize label x1 y1 x1space y1space width;
run;

proc sgplot data=_newcoor1_ sganno=_newcoor1_ pad=(top=5% bottom=5% right=10% left=5%);
scatter x=x1 y=y1 / markerattrs=(symbol=plus size=0);
xaxis label="Dimension 1 (&p1.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
yaxis label="Dimension 2 (&p2.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
refline 0 / axis=x;
refline 0 / axis=y;
title box=1 h=1.5 'FIG. A:  Outcomes vs.' color=red ' Explanatory Variables';
run;
quit;

%end;

%if (%length(&response) and %length(&covars))  %then %do;

%if &onedim=YES %then %do;
proc corresp data=_all2_ dim=1 outc=_coor_ noprint;
tables &response, &covars ;
%if %length(&fmtresp) %then %str(format &response &fmtresp..;);
run;

data _null_;
  set _coor_;
if _type_ = 'INERTIA';
perc1 = 100;
perc2 = 0;
p1 = put(left(perc1),4.1);
p2 = put(left(perc2),4.1);
call symput('p1',p1);
call symput('p2',p2);

data _coor_vars_;
  set _coor_;
if _type_='VAR';

data _coor_vars_;
length label color $15;
  merge _coor_vars_ _fmt2_;
x=dim1;
y = (ranuni(798449515) - .5) / 10;
textsize = 4 + 16 * sqcos1;
color='GREEN';
output;
keep x y label textsize color;

data _coor_obs_;
length label color $15;
  set _coor_;
if _type_='OBS';
x=dim1;
y = (ranuni(479895151) - .5) / 10;
label=_name_;
textsize = 4 + 16 * sqcos1;
color='BLACK';
output;
keep x y label textsize color;

data _coor1_;
  set _coor_vars_ _coor_obs_;
run;
%end;
%else %do;
proc corresp data=_all2_ dim=2 outc=_coor_ noprint;
tables &response, &covars ;
%if %length(&fmtresp) %then %str(format &response &fmtresp..;);
run;

data _null_;
  set _coor_;
if _type_ = 'INERTIA';
perc1 = 100 * contr1 / inertia;
perc2 = 100 * contr2 / inertia;
p1 = put(left(perc1),4.1);
p2 = put(left(perc2),4.1);
call symput('p1',p1);
call symput('p2',p2);

data _coor_vars_;
  set _coor_;
if _type_='VAR';

data _coor_vars_;
length label color $15;
  merge _coor_vars_ _fmt2_;
x=dim1;
y=dim2;
textsize = 4 + 16 * quality;
color='GREEN';
output;
keep x y label textsize color;

data _coor_obs_;
length label color $15;
  set _coor_;
if _type_='OBS';
x=dim1;
y=dim2;
label=_name_;
textsize = 4 + 16 * quality;
color='BLACK';
output;
keep x y label textsize color;

data _coor1_;
  set _coor_vars_ _coor_obs_;
run;
%end;

 /*-------------------------------------*
  | Conversion to SGPLOT / January 2015 |
  *-------------------------------------*/
data _newcoor1_;
length function $9 label $15 textcolor $15;
   set _coor1_;
if (color in ('GREEN','BLACK'));
retain x1space 'datavalue' y1space 'datavalue';
function='text'; x1=x; y1=y; textcolor=color; width=40;
keep function textcolor textsize label x1 y1 x1space y1space width;
run;

proc sgplot data=_newcoor1_ sganno=_newcoor1_ pad=(top=5% bottom=5% right=10% left=5%);
scatter x=x1 y=y1 / markerattrs=(symbol=plus size=0);
xaxis label="Dimension 1 (&p1.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
yaxis label="Dimension 2 (&p2.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
refline 0 / axis=x;
refline 0 / axis=y;
title box=1 h=1.5 'FIG. B:  Outcomes vs.' color=green ' Covariates';
run;
quit;

%end;

%if (%length(&explanvars) and %length(&covars))  %then %do;

data _subother1_;
length &explanvars 8;
  set _other1_;
keep &explanvars;

proc contents data=_subother1_ out=_chekdat_ noprint;

data _chekdat_;
  set _chekdat_;
name2 = upcase(name);
keep name name2 varnum;

proc sort data=_chekdat_;
by name2;

data _fmt1_;
  set _fmtout1_;
name2 = upcase(fmtname);

proc sort data=_fmt1_;
by name2;

data _fmt1_;
  merge _fmt1_ _chekdat_;
by name2;
if (name ne '');
keep label varnum start;

proc sort data=_fmt1_;
by varnum;

data _subother1_;
length &covars 8;
  set _other1_;
keep &covars;

proc contents data=_subother1_ out=_chekdat_ noprint;

data _chekdat_;
  set _chekdat_;
name2 = upcase(name);
keep name name2 varnum;

proc sort data=_chekdat_;
by name2;

data _fmt2_;
  set _fmtout1_;
name2 = upcase(fmtname);

proc sort data=_fmt2_;
by name2;

data _fmt2_;
  merge _fmt2_ _chekdat_;
by name2;
if (name ne '');
keep label varnum start;

proc sort data=_fmt2_;
by varnum;

proc corresp data=_other1_ dim=2 outc=_coor_ noprint;
tables &explanvars, &covars ;
run;

data _null_;
  set _coor_;
if _type_ = 'INERTIA';
perc1 = 100 * contr1 / inertia;
perc2 = 100 * contr2 / inertia;
p1 = put(left(perc1),4.1);
p2 = put(left(perc2),4.1);
call symput('p1',p1);
call symput('p2',p2);

data _coor_obs_;
  set _coor_;
if _type_='OBS';

data _coor_obs_;
length label color $15;
  merge _coor_obs_ _fmt1_;
x=dim1;
y=dim2;
textsize = 4 + 16 * quality;
color='RED';
output;
keep x y label textsize color;

data _coor_vars_;
  set _coor_;
if _type_='VAR';

data _coor_vars_;
length label color $15;
  merge _coor_vars_ _fmt2_;
x=dim1;
y=dim2;
textsize = 4 + 16 * quality;
color='GREEN';
output;
keep x y label textsize color;

data _coor1_;
  set _coor_vars_ _coor_obs_;
run;

 /*-------------------------------------*
  | Conversion to SGPLOT / January 2015 |
  *-------------------------------------*/
data _newcoor1_;
length function $9 label $15 textcolor $15;
   set _coor1_;
if (color in ('RED','GREEN'));
retain x1space 'datavalue' y1space 'datavalue';
function='text'; x1=x; y1=y; textcolor=color; width=40;
keep function textcolor textsize label x1 y1 x1space y1space width;
run;

proc sgplot data=_newcoor1_ sganno=_newcoor1_ pad=(top=5% bottom=5% right=10% left=5%);
scatter x=x1 y=y1 / markerattrs=(symbol=plus size=0);
xaxis label="Dimension 1 (&p1.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
yaxis label="Dimension 2 (&p2.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
refline 0 / axis=x;
refline 0 / axis=y;
title box=1 h=1.5 'FIG. C: ' color=red 'Explanatory Variables' color=black ' vs.' color=green ' Covariates';
run;
quit;

%end;

%done:
title; run;

%mend prelim_ca;

