
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;

 /*-------------------------------------------------------------------*
  *                                                                   *
  *  Bill Miller  <wem0@cdc.gov>                                      *
  *  October 2012  / Last edited in September 2017                    *
  *                                                                   *
  *  DISCLAIMER:  The five POSSE macros are provided to SAS users     *
  *  who wish to perform global exploratory analyses near the         *
  *  beginning of a data analysis.  However, they assume a working    *
  *  knowledge of correspondence analysis and homogeneity analysis.   *
  *  In addition, CDC and NIOSH do not warrant the reliability or     *
  *  accuracy of the software, graphics or text.                      *
  *-------------------------------------------------------------------*
  *                                                                   *
  *  CORRESPONDENCE.SAS  Performs correspondence analysis for both    *
  *                      stratified and stacked contingency tables.   *
  *                                                                   *
  *  NOTE: If m is the number of levels for the outcome and n is      *
  *  the total number of levels for all the other variables, then     *
  *  min(m,n) should generally be >= 4 to run this program.  If the   *
  *  response has three levels, the optional entry of 'twodim=YES'    *
  *  will allow the program to run by producing results only for the  *
  *  first two dimensions, and if the outcome is binary, you can use  *
  *  the optional entry of 'onedim=YES'.  However, if a stratifica-   *
  *  tion variable is specified, the dimension will then be >= 3.     *
  *  Note that the formats are required for the other variables and   *
  *  the format names must match the names for the other variables.   *
  *  In addition, the coding for the outcome variable must begin      *
  *  with the number '1'.                                             *
  *                                                                   *
  *  Note that the formats are required for the other variables       *
  *  (which are the explanatory variables and the covariates), while  *
  *  the format names must be the same as the other variable names,   *
  *  and the number of format labels must match the number of non-    *
  *  missing levels for the variables.  However, the coding for these *
  *  variables can start with either numbers '0' or '1'.              *
  *                                                                   *
  *  This macro performs a correspondence analysis which can indicate *
  *  the associations among the outcomes, explanatory variables and   *
  *  covariates, as described in the POSSE manual.  The user provides *
  *  the name of the dataset containing all the variables, plus the   *
  *  name for the outcome variable, the formatting for the outcomes   *
  *  (which is optional), the names for the explanatory variables,    *
  *  the names for the covariates, the name of the format dataset     *
  *  for the explanatory variables and the covariates, and the ID     *
  *  variable for the observations.  The two main options for the     *
  *  macro are as follows:                                            *
  *                                                                   *
  *  Option 1 (No Stratification Variable):  The macro provides the   *
  *  tables of contributions to the inertias for the various types of *
  *  variables for the first three dimensions, and correspondence     *
  *  maps are given for the Dimension 1 versus Dimension 2 results    *
  *  and for the Dimension 2 versus Dimension 3 results.  The user    *
  *  can choose to either show or hide the individual observations    *
  *  for these maps, and the user also has the option of highlighting *
  *  one level of any of the explanatory variables or covariates,     *
  *  and also circling the observations for one level of the outcome. *
  *  Either plot can also be suppressed using the NOPLOT option.  A   *
  *  larger size for a label shown in a map indicates a better fit    *
  *  for that effect.  Note that, when there are no covariates, the   *
  *  macro can still be used.                                         *
  *                                                                   *
  *  Option 2 (Using a Stratification Variable):  After inserting     *
  *  a variable name after 'stratavar=', the macro provides tables    *
  *  of contributions for results which stratify the outcomes by this *
  *  variable.  Optional formatting for the stratification variables  *
  *  can also be provided.  The stratification variable can be either *
  *  an existing covariate or new variable which is created and saved *
  *  in the dataset with the other variables.  Other options, such    *
  *  as highlighting or circling the observations with respect to a   *
  *  level of a factor or the outcome, are also available.            *
  *-------------------------------------------------------------------*/

%macro correspondence(		/*--------------------------------------*/
         dataset=,			/* -- Dataset to be analyzed.           */
         response=,         /* -- Outcome or response variable      */
         fmtresp=,		 	/* -- Formatting for outcome (optional) */
         explanvars=,       /* -- Explanatory variables (required)  */
         covars=,           /* -- Covariates (optional)             */
         fmtothr=,		 	/* -- Formats for other vars (required) */
		 id=,               /* -- ID for observations               */ 
		 onedim=,			/* -- Enter YES for 1-dim. solution     */
		 twodim=,			/* -- Enter YES for 2-dim. solution     */
		 			   		/*--------------------------------------*/
		 showobs=NO,        /* -- Display observations in plots     */ 
		 			  		/*--------------------------------------*/
		 stratavar=,		/* -- Insert a stratification variable. */
		 					/*    All types of variables must be    */
		 			   		/*    specified for this operation.     */
         fmtstrata=,  		/* -- Format for strata (optional)      */
	 			   			/*--------------------------------------*/
		 highlightobs=,     /* - Color obs. for level of other vars */ 
		 circlelevel=,      /* - Circle obs. for level of outcome   */ 
		 noplot=);          /* - Insert 'ONE' or 'TWO' to suppress  */ 
		 			   	    /*   either the first or second plots.  */
                       		/*--------------------------------------*/


data _outcomes_;
  set &dataset ;
keep &id &response ;
run;

data _other1_;
  set &dataset ;
drop &response ;
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
length color $15;
  merge _fmt1_ _chekdat_;
by name2;
if (name ne '');
color='RED';
keep label varnum start color;

proc sort data=_fmt1_;
by varnum;
run;

%if (%length(&covars))  %then %do;
data _subother2_;
length &covars 8;
  set _other1_;
keep &covars;

proc contents data=_subother2_ out=_chekdat2_ noprint;

data _chekdat2_;
  set _chekdat2_;
name2 = upcase(name);
keep name name2 varnum;

proc sort data=_chekdat2_;
by name2;

data _fmt2_;
  set _fmtout1_;
name2 = upcase(fmtname);

proc sort data=_fmt2_;
by name2;

data _fmt2_;
length color $15;
  merge _fmt2_ _chekdat2_;
by name2;
if (name ne '');
color='GREEN';
keep label varnum start color;

proc sort data=_fmt2_;
by varnum;

data _allfmt_;
  set _fmt1_ _fmt2_;
run;
%end;

%if (%length(&covars)=0)  %then %do;
data _allfmt_;
  set _fmt1_;
run;
%end;

proc sort data=_outcomes_;
by &id ;

proc sort data=_other1_;
by &id ;

data _all1_;
length &response &explanvars &covars 8;
  merge _outcomes_ _other1_;
by &id ;
run;


 /*---------------------------------*
  | 1-D vs. 2-D vs. 3-D solutions.  |
  *---------------------------------*/
%let onedim=%upcase(&onedim);
%let twodim=%upcase(&twodim);

%if &onedim=YES %then %do;
%if %length(&stratavar)=0 %then
%str(proc corresp data=_all1_ dim=1 outc=_coor_ observed;
     tables &response, &explanvars &covars;);
%if %length(&stratavar) %then
%str(proc corresp data=_all1_ dim=1 cross=row outc=_coor_ observed;
     tables &response &stratavar, &explanvars &covars;);
%end;
%else %if &twodim=YES %then %do;
%if %length(&stratavar)=0 %then
%str(proc corresp data=_all1_ dim=2 outc=_coor_ observed;
     tables &response, &explanvars &covars;);
%if %length(&stratavar) %then
%str(proc corresp data=_all1_ dim=2 cross=row outc=_coor_ observed;
     tables &response &stratavar, &explanvars &covars;);
%end;
%else %do;
%if %length(&stratavar)=0 %then
%str(proc corresp data=_all1_ dim=3 outc=_coor_ observed;
     tables &response, &explanvars &covars;);
%if %length(&stratavar) %then
%str(proc corresp data=_all1_ dim=3 cross=row outc=_coor_ observed;
     tables &response &stratavar, &explanvars &covars;);
%end;

%if %length(&fmtresp) %then %str(format &response &fmtresp..;);
%if %length(&fmtstrata) %then %str(format &stratavar &fmtstrata..;);
ods output Observed=_observed_;
run;

ods _all_ close;
ods html;
run;

data _null_;
  set _coor_;
if _type_ = 'INERTIA';
%if &onedim=YES %then %do;
perc1 = 100;
perc2 = 0;
p1 = put(left(perc1),4.1);
p2 = put(left(perc2),4.1);
call symput('p1',p1);
call symput('p2',p2);
%end;
%else %if &twodim=YES %then %do;
perc1 = 100 * contr1 / inertia;
perc2 = 100 * contr2 / inertia;
p1 = put(left(perc1),4.1);
p2 = put(left(perc2),4.1);
call symput('p1',p1);
call symput('p2',p2);
%end;
%else %do;
perc1 = 100 * contr1 / inertia;
perc2 = 100 * contr2 / inertia;
perc3 = 100 * contr3 / inertia;
p1 = put(left(perc1),4.1);
p2 = put(left(perc2),4.1);
p3 = put(left(perc3),4.1);
call symput('p1',p1);
call symput('p2',p2);
call symput('p3',p3);
%end;

data _coor_vars_;
  set _coor_;
if _type_='VAR';

data _maketable1_;
  set _observed_;
if (label='Sum') then delete;
drop sum label;

data _null_;
  set _maketable1_;
array x[*] _numeric_ ;
nvar = left(trim(put(dim(x),3.)));
call symput('nvar',nvar);

data _maketable1_;
  set _maketable1_;
array x[*] _numeric_ ;
array save[*] save1-save&nvar ;
do i=1 to dim(x);
  save[i] = x[i];
end;
w=1;
keep w save1-save&nvar ;

proc sort data=_other1_;
by &id ;

data _subother3_;
length &explanvars &covars 8;
  set _other1_;
keep &explanvars &covars;

proc transreg data=_subother3_ design noprint;
model class(&explanvars &covars / zero=none);
output out=_design1_(drop=_type_ _name_ intercept &explanvars &covars);

data _subjectdat1_;
  set _design1_;
array x[*] _numeric_ ;
array save[*] save1-save&nvar ;
do i=1 to dim(x);
  save[i] = x[i];
end;
w=-1;
keep w save1-save&nvar ;

data _wholedat1_;
  set _maketable1_ _subjectdat1_;

%if &onedim=YES %then %do;
proc corresp data=_wholedat1_ dim=1 outc=_newcoor_ noprint;
var save1-save&nvar ;
weight w;
%end;
%else %if &twodim=YES %then %do;
proc corresp data=_wholedat1_ dim=2 outc=_newcoor_ noprint;
var save1-save&nvar ;
weight w;
%end;
%else %do;
proc corresp data=_wholedat1_ dim=3 outc=_newcoor_ noprint;
var save1-save&nvar ;
weight w;
%end;

data _coor_supobs_;
  set _newcoor_;
if _type_='SUPOBS';

proc iml;
use _design1_;
read all into newdat1;
use _allfmt_;
read all var{label} into lab1;
varnames = lab1`;
create _addlabel1_ from newdat1 [colname=varnames];
append from newdat1;
quit;

proc transreg data=_outcomes_ design noprint;
model class(&response / zero=none);
id &id ;
output out=_design9_(drop=_type_ _name_ intercept &response);

data _save_vars1_;
length text $15;
  merge _coor_vars_ _allfmt_;
text=label;
%if (&onedim=YES) %then %str(keep text contr1;);
%else %if (&twodim=YES) %then %str(keep text contr1-contr2;);
%else %str(keep text contr1-contr3;);

data _save_outcomes1_;
length text $15;
  set _coor_;
if _type_='OBS';
text=compress(_name_,' ');
%if (&onedim=YES) %then %str(keep text contr1;);
%else %if (&twodim=YES) %then %str(keep text contr1-contr2;);
%else %str(keep text contr1-contr3;);
run;

data _attrmap_;
length id $4 value $9 markersymbol $12 markercolor $5;
id='anno'; value='Oval';      markersymbol='circle';       markercolor='black'; output;
id='anno'; value='Rectangle'; markersymbol='squarefilled'; markercolor='cyan';  output;
run;

ods html;
ods graphics / antialias=off width=11in;

 /*--------------------------*
  | Make plot for dims 1-2.  |
  *--------------------------*/
%let noplot=%upcase(&noplot);
%if &noplot ^=ONE %then %do;

%if (&onedim=YES) %then %do;
data _coor_vars1_;
length label color $15;
  merge _coor_vars_ _allfmt_;
x=dim1;
y = (ranuni(0) - .5) / 10;
textsize = 4 + 16 * sqcos1;
output;
keep x y label textsize color;

data _coor_obs1_;
length label color $15;
  set _coor_;
if _type_='OBS';
x=dim1;
y = (ranuni(0) - .5) / 10;
label=compress(_name_,' ');
textsize = 4 + 16 * sqcos1;
color='BLACK';
output;
keep x y label textsize color;
run;
%end;

%else %do;
data _coor_vars1_;
length label color $15;
  merge _coor_vars_ _allfmt_;
x=dim1;
y=dim2;
textsize = 4 + 16 * (sqcos1 + sqcos2);
output;
keep x y label textsize color;

data _coor_obs1_;
length label color $15;
  set _coor_;
if _type_='OBS';
x=dim1;
y=dim2;
label=compress(_name_,' ');
textsize = 4 + 16 * (sqcos1 + sqcos2);
color='BLACK';
output;
keep x y label textsize color;
run;

data _coor_supobs1_;
%if %length(&highlightobs)=0 %then %str(length color $15;);
%if %length(&highlightobs) %then %str(length label color $15;);
  merge _coor_supobs_ _addlabel1_;
x = dim1 + (ranuni(1236547) - .5) / 15;
y = dim2 + (ranuni(9936547) - .5) / 15;
textsize = 8;
color='LIGGR';
  %if %length(&highlightobs) %then %do;
     if (&highlightobs = 1) then do;
       color='CYAN'; label='K'; size = 16;
	 end;
  %end;
output;
%if %length(&highlightobs)=0 %then %str(keep x y textsize color;);
%if %length(&highlightobs) %then %str(keep x y label textsize color;);

data _addsupobs1_;
  merge _coor_supobs1_ _design9_;
  %if %length(&circlelevel) %then %do;
     if (&response&circlelevel = 1) then do;
       color='BLACK'; label='H'; textsize = 18; output;
	 end;
  %end;
run;

%if %length(&circlelevel) %then %do;
data _coor_supobs1_;
  set _coor_supobs1_ _addsupobs1_;
run;
%end;
%end;

 /*------------------------------*
  | Display observations or not. |
  *------------------------------*/
%let showobs=%upcase(&showobs);
%if (&showobs=YES and %length(&onedim)=0) %then %do;
data _coor1_;
  set _coor_vars1_ _coor_obs1_ _coor_supobs1_;
%end;
%if (&showobs ne YES or &onedim=YES) %then %do;
data _coor1_;
  set _coor_vars1_ _coor_obs1_;
%end;

 /*-------------------------------------*
  | Conversion to SGPLOT / January 2015 |
  *-------------------------------------*/
data _newobs12_;
  set _coor1_;
if (color in ('LIGGR','CYAN'));
keep x y;
run;

data _newcoors1_;
length function $9 linecolor $10;
   set _coor1_;
if (color='CYAN');
retain widthunit 'pixel' heightunit 'pixel' x1space 'datavalue' y1space 'datavalue';
function='Rectangle'; x1=x; y1=y; linecolor='CYAN'; width=4; height=4; linethickness=3.5;
keep function linecolor x1 y1 widthunit heightunit x1space y1space width height linethickness;
run;

data _newcoors2_;
length function $9 linecolor $10;
   set _coor1_;
if (color='BLACK' and label='H');
retain widthunit 'pixel' heightunit 'pixel' x1space 'datavalue' y1space 'datavalue';
function='Oval'; x1=x; y1=y; linecolor='BLACK'; width=6; height=6; linethickness=2.5;
keep function linecolor x1 y1 widthunit heightunit x1space y1space width height linethickness;
run;

data _newcoors3_;
length function $9 label $15 textcolor $15;
   set _coor1_;
if (label ne 'H' and color in ('RED','GREEN','BLACK'));
retain x1space 'datavalue' y1space 'datavalue';
function='text'; x1=x; y1=y; textcolor=color; width=40;
keep function textcolor textsize label x1 y1 x1space y1space width;
run;

data _newcoors12_;
  set _newcoors1_ _newcoors2_ _newcoors3_;
run;

data _textanno_;
  retain x1space "datavalue" y1space "datavalue";
  set _newcoors12_ (keep=function x1 y1 label textcolor textsize width);
  if (function eq "text");
run;

data _scatter_anno_;
  set _newcoors12_;
if (function ne 'text');
keep function x1 y1;
run;

data _merged_;
merge _newobs12_ _scatter_anno_;
run;

%let showobs=%upcase(&showobs);
%if &showobs=YES %then %do;
%if (%length(&highlightobs)=0 and %length(&circlelevel)=0) %then
%str(title box=1 h=1.5 'Correspondence Map for Dimensions 1 and 2';);
%if (%length(&highlightobs) and %length(&circlelevel)) %then
%str(title box=1 h=1.5 "Dimensions 1-2:  Circles=Level &circlelevel /" color=cyan "/ Rectangles= &highlightobs" color=black;);
%if (%length(&highlightobs)=0 and %length(&circlelevel)) %then
%str(title box=1 h=1.5 "Dimensions 1-2:  Circles=Level &circlelevel ";);
%if (%length(&highlightobs) and %length(&circlelevel)=0) %then
%str(title box=1 h=1.5 "Dimensions 1-2:" color=cyan " Rectangles= &highlightobs" color=black;);
proc sgplot data=_merged_ dattrmap=_attrmap_ sganno=_textanno_ pad=(top=5% bottom=5% left=10% right=15%) noautolegend;
scatter x=x y=y / markerattrs=(symbol=CircleFilled size=4 color='LIGGR');
%if (%length(&highlightobs) or %length(&circlelevel)) %then
%str(scatter x=x1 y=y1 / markerattrs=(size=10) group=function attrid=anno;);
xaxis label="Dimension 1 (&p1.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
yaxis label="Dimension 2 (&p2.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
refline 0 / axis=x;
refline 0 / axis=y;
run;
quit;
%end;

%if &showobs ne YES %then %do;
proc sgplot data=_newcoors12_ sganno=_newcoors12_ pad=(top=5% bottom=5% left=15% right=15%);
scatter x=x1 y=y1 / markerattrs=(symbol=plus size=0);
xaxis label="Dimension 1 (&p1.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
yaxis label="Dimension 2 (&p2.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
refline 0 / axis=x;
refline 0 / axis=y;
%if &onedim=YES %then %str(title box=1 h=1.5 'Correspondence Map for Dimension 1';);
%if %length(&onedim)=0 %then %str(title box=1 h=1.5 'Correspondence Map for Dimensions 1 and 2';);
run;
quit;
%end;

%end;

 /*--------------------------*
  | Make plot for dims 2-3.  |
  *--------------------------*/
%if (&twodim ^=YES and &onedim ^=YES) %then %do;
%if &noplot ^=TWO %then %do;

data _coor_vars2_;
length label color $15;
  merge _coor_vars_ _allfmt_;
x=dim2;
y=dim3;
textsize = 4 + 16 * (sqcos2 + sqcos3);
output;
keep x y label textsize color;

data _coor_obs2_;
length label color $15;
  set _coor_;
if _type_='OBS';
x=dim2;
y=dim3;
label=compress(_name_,' ');
textsize = 4 + 16 * (sqcos2 + sqcos3);
color='BLACK';
output;
keep x y label textsize color;

data _coor_supobs2_;
length label color $15;
  merge _coor_supobs_ _addlabel1_;
x = dim2 + (ranuni(1236547) - .5) / 15;
y = dim3 + (ranuni(9936547) - .5) / 15;
textsize = 8;
color='LIGGR';
  %if %length(&highlightobs) %then %do;
     if (&highlightobs = 1) then do;
       color='CYAN'; label='K'; textsize = 16;
	 end;
  %end;
  output;
keep x y label textsize color;

data _addsupobs2_;
  merge _coor_supobs2_ _design9_;
  %if %length(&circlelevel) %then %do;
     if (&response&circlelevel = 1) then do;
       color='BLACK'; label='H'; textsize = 18; output;
	 end;
  %end;
run;

%if %length(&circlelevel) %then %do;
data _coor_supobs2_;
  set _coor_supobs2_ _addsupobs2_;
run;
%end;

 /*------------------------------*
  | Display observations or not. |
  *------------------------------*/
%let showobs=%upcase(&showobs);
%if &showobs=YES %then %do;
data _coor2_;
  set _coor_vars2_ _coor_obs2_ _coor_supobs2_;
%end;
%if &showobs ne YES %then %do;
data _coor2_;
  set _coor_vars2_ _coor_obs2_;
%end;

 /*-------------------------------------*
  | Conversion to SGPLOT / January 2015 |
  *-------------------------------------*/
data _newobs23_;
  set _coor2_;
if (color in ('LIGGR','CYAN'));
keep x y;
run;

data _newcoors1b_;
length function $9 linecolor $10;
   set _coor2_;
if (color='CYAN');
retain widthunit 'pixel' heightunit 'pixel' x1space 'datavalue' y1space 'datavalue';
function='Rectangle'; x1=x; y1=y; linecolor='CYAN'; width=4; height=4; linethickness=3.5;
keep function linecolor x1 y1 widthunit heightunit x1space y1space width height linethickness;
run;

data _newcoors2b_;
length function $9 linecolor $10;
   set _coor2_;
if (color='BLACK' and label='H');
retain widthunit 'pixel' heightunit 'pixel' x1space 'datavalue' y1space 'datavalue';
function='Oval'; x1=x; y1=y; linecolor='BLACK'; width=6; height=6; linethickness=2.5;
keep function linecolor x1 y1 widthunit heightunit x1space y1space width height linethickness;
run;

data _newcoors3b_;
length function $9 label $15 textcolor $15;
   set _coor2_;
if (label ne 'H' and color in ('RED','GREEN','BLACK'));
retain x1space 'datavalue' y1space 'datavalue';
function='text'; x1=x; y1=y; textcolor=color; width=40;
keep function textcolor textsize label x1 y1 x1space y1space width;
run;

data _newcoors23_;
  set _newcoors1b_ _newcoors2b_ _newcoors3b_;
run;

data _textanno2_;
  retain x1space "datavalue" y1space "datavalue";
  set _newcoors23_ (keep=function x1 y1 label textcolor textsize width);
  if (function eq "text");
run;

data _scatter_anno2_;
  set _newcoors23_;
if (function ne 'text');
keep function x1 y1;
run;

data _merged2_;
merge _newobs23_ _scatter_anno2_;
run;

%let showobs=%upcase(&showobs);
%if &showobs=YES %then %do;
%if (%length(&highlightobs)=0 and %length(&circlelevel)=0) %then
%str(title box=1 h=1.5 'Correspondence Map for Dimensions 2 and 3';);
%if (%length(&highlightobs) and %length(&circlelevel)) %then
%str(title box=1 h=1.5 "Dimensions 2-3:  Circles=Level &circlelevel /" color=cyan "/ Rectangles= &highlightobs" color=black;);
%if (%length(&highlightobs)=0 and %length(&circlelevel)) %then
%str(title box=1 h=1.5 "Dimensions 2-3:  Circles=Level &circlelevel ";);
%if (%length(&highlightobs) and %length(&circlelevel)=0) %then
%str(title box=1 h=1.5 "Dimensions 2-3:" color=cyan " Rectangles= &highlightobs" color=black;);
proc sgplot data=_merged2_ dattrmap=_attrmap_ sganno=_textanno2_ pad=(top=5% bottom=5% left=15% right=15%) noautolegend;
scatter x=x y=y / markerattrs=(symbol=CircleFilled size=4 color='LIGGR');
%if (%length(&highlightobs) or %length(&circlelevel)) %then
%str(scatter x=x1 y=y1 / markerattrs=(size=10) group=function attrid=anno;);
xaxis label="Dimension 2 (&p2.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
yaxis label="Dimension 3 (&p3.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
refline 0 / axis=x;
refline 0 / axis=y;
run;
quit;
%end;

%if &showobs ne YES %then %do;
proc sgplot data=_newcoors23_ sganno=_newcoors23_ pad=(top=5% bottom=5% left=15% right=15%);
scatter x=x1 y=y1 / markerattrs=(symbol=plus size=0);
xaxis label="Dimension 2 (&p2.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
yaxis label="Dimension 3 (&p3.%)" labelattrs=(size=12 color=blue) offsetmin=0.1;
refline 0 / axis=x;
refline 0 / axis=y;
title box=1 h=1.5 'Correspondence Map for Dimensions 2 and 3';
run;
quit;
%end;

%end;
%end;

 /*---------------------------------------------------------*
  | Display the contributions to inertia for the variables. |
  *---------------------------------------------------------*/
%if &onedim=YES %then %do;
proc print data=_save_outcomes1_ double split='*';
id text;
label text='Variable*Levels'
      contr1='Contrib. to*1st Dim.'
;
title 'Contributions of Outcomes to Inertia';
format contr1 6.3;

proc print data=_save_vars1_ double split='*';
id text;
label text='Variable*Levels'
      contr1='Contrib. to*1st Dim.'
;
title 'Contributions of Other Variables to Inertia';
format contr1 6.3;
run;
%end;

%else %if &twodim=YES %then %do;
proc print data=_save_outcomes1_ double split='*';
id text;
label text='Variable*Levels'
      contr1='Contrib. to*1st Dim.'
      contr2='Contrib. to*2nd Dim.'
;
title 'Contributions of Outcomes to Inertia';
format contr1-contr2 6.3;

proc print data=_save_vars1_ double split='*';
id text;
label text='Variable*Levels'
      contr1='Contrib. to*1st Dim.'
      contr2='Contrib. to*2nd Dim.'
;
title 'Contributions of Other Variables to Inertia';
format contr1-contr2 6.3;
run;
%end;

%else %do;
proc print data=_save_outcomes1_ double split='*';
id text;
label text='Variable*Levels'
      contr1='Contrib. to*1st Dim.'
      contr2='Contrib. to*2nd Dim.'
      contr3='Contrib. to*3rd Dim.'
;
title 'Contributions of Outcomes to Inertia';
format contr1-contr3 6.3;

proc print data=_save_vars1_ double split='*';
id text;
label text='Variable*Levels'
      contr1='Contrib. to*1st Dim.'
      contr2='Contrib. to*2nd Dim.'
      contr3='Contrib. to*3rd Dim.'
;
title 'Contributions of Other Variables to Inertia';
format contr1-contr3 6.3;
run;
%end;

%if &noplot ^=ONE %then %do;
 /*----------------------------*
  | Print circled observations |
  *----------------------------*/
%if (%length(&circlelevel) and (&noplot ^=ONE)) %then %do;
data _addsupobs1_;
  set _addsupobs1_;
numobs1 = _n_;

proc print data=_addsupobs1_ split='*';
where numobs1 <= 50;
id &id ;
var x y;
label x='Dim 1' y='Dim 2';
format x y 6.2;
title 'Approximate Dims. 1-2 Coordinates for First 50 Circled Observations';
run;
%end;

 /*--------------------------------*
  | Print highlighted observations |
  *--------------------------------*/
%if (%length(&highlightobs) and (&noplot ^=ONE)) %then %do;
data _hilite1_;
  merge _coor_supobs1_ _design9_;
if (color = 'CYAN');

data _hilite1_;
  set _hilite1_;
numobs2 = _n_;

proc print data=_hilite1_ split='*';
where numobs2 <= 50;
id &id ;
var x y;
label x='Dim 1' y='Dim 2';
format x y 6.2;
title 'Approximate Dims. 1-2 Coordinates for First 50 Highlighted Oservations';
run;
%end;
%end;


%end;

%done:
title; run;

%mend correspondence;

