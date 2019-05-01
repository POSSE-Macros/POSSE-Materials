
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;

 /*-------------------------------------------------------------------*
  *                                                                   *
  *  Bill Miller  <wem0@cdc.gov>                                      *
  *  October 2012 / Last edited in March 2018                         *
  *                                                                   *
  *  DISCLAIMER:  The five POSSE macros are provided to SAS users     *
  *  who wish to perform global exploratory analyses near the         *
  *  beginning of a data analysis.  However, they assume a working    *
  *  knowledge of correspondence analysis and homogeneity analysis.   *
  *  In addition, CDC and NIOSH do not warrant the reliability or     *
  *  accuracy of the software, graphics or text.                      *
  *-------------------------------------------------------------------*
  *                                                                   *
  *  CLASSIFICATION.SAS   Screening/Clustering Variables/Observations *
  *                                                                   *
  *  This macro performs the screening of the outcome variables for   *
  *  the POSSE method.  The user must provide the name of the         *
  *  dataset and the variables to be analyzed.  The variable names    *
  *  must not contain any numbers.  There are three parts to this     *
  *  macro, as described in the following:                            *
  *                                                                   *
  *  Part 1.  This finds and plots the discrimination measures for    *
  *  for the given set of variables.                                  *
  *                                                                   *
  *  Part 2.  After changing it to read PRINT=YES and entering the    *
  *  number of variables in the next three lines, the macro then      *
  *  prints out the names for the variables with the best discrim-    *
  *  ination measures for the three dimensions.                       *
  *                                                                   *
  *  Part 3.  After inserting some variable names from among all      *
  *  those found in VAR=, the macro performs subset correspondence    *
  *  analysis.  If you wish to use all the variables found in VAR=,   *
  *  then insert 'ALL' here.  Also, when the zero levels are not      *
  *  relevant, their results can be excluded from the printed output. *
  *                                                                   *
  *  Part 4. Once the final subset of variables is chosen using the   *
  *  subset correspondence analysis, this subset can be inserted      *
  *  into the 'haclust=' entry to perform a cluster analysis on the   *
  *  the subjects or observations.  The 'id=' entry is required for   *
  *  all cluster analyses.  To determine the number of clusters, the  *
  *  'fitclust=' entry can be set to 'YES' to fit a series of         *
  *  two to seven clusters.  This will then display and the plot the  *
  *  CCC statistics.  A positive CCC statistic > 2 indicates well-    *
  *  defined clusters, but CCC statistics between 0 and 2 should be   *
  *  interpreted cautiously.  Once the number of clusters is chosen,  *
  *  the 'nclust=' entry will produce additional information and      *
  *  graphs for that choice, and the 'out=' entry will save the       *
  *  cluster variable along with the variables used in the clustering.*
  *  The entry of 'printfreqs=YES' will print the frequencies for the *
  *  profiles of zeros and ones for a series of binary variables in   *
  *  order to investigate the scaling of variables.  Whenever this    *
  *  option is used, the variables in the 'haclust' entry must be     *
  *  ordered by the positive outcomes found for the variables along   *
  *  the first dimension, as indicated by the first map produced for  *
  *  the subset correspondence analysis.                              *
  *-------------------------------------------------------------------*/

%macro classification( /*--------------------------------------*/
         data=_last_,  /* -- Dataset to analyze                */
         var=,         /* -- Variable names.                   */
         print=NO,     /* -- YES prints subset of variables.   */
         ndim1=0,      /* -- Number from 1st dimension.        */
         ndim2=0,      /* -- Number from 2nd dimension.        */
         ndim3=0,      /* -- Number from 3rd dimension.        */
		 			   /*--------------------------------------*/
         sub=,         /* -- Variables for Subset CA.          */
		 			   /*   (Insert ALL when using all VAR=)   */
		 noprint=,	   /* -- YES excludes the zero levels      */
                       /*    from the printed output.          */
		 			   /*--------------------------------------*/
		 haclust=,     /* -- Perform cluster analysis using    */
                       /*    the variables in the 'sub=' line. */
		 fitclust=,    /* -- Calculate the CCC statistic for   */
                       /*    a series of 2-7 clusters.         */
		 nclust=,      /* -- Maximum number of clusters.       */
		 id=,          /* -- Required ID for cluster analysis. */
 		 allbin=NO,    /* -- All variables are binary          */
         out=,         /* -- Output cluster information.       */
 	     printfreqs=); /* -- YES prints the frequencies for    */
                       /*    the profiles ordered by the       */
                       /*    first dimension.                  */
                       /*--------------------------------------*/

ods html;

%if (%length(&haclust) and %length(&id)=0) %then %do;
  %put ERROR: ID Entry Is Required for Cluster Analysis ;
  %goto done;
%end;

%if %length(&var) %then %do;

data _dat1_;
  set &data ;
keep &var ;

proc sql noprint;                               
   select nvar                         
   into :nvar              
   from dictionary.tables                      
   where libname='WORK' and memname='_DAT1_';
quit;

data _newdat1_;
length &var 8 ;
  set _dat1_;
keep &var ;

proc transreg data=_newdat1_ design noprint;
model class(&var / zero=none);
output out=_design1_(drop=_type_ _name_ intercept &var);

proc corresp data=_design1_ dim=3 outc=_coor_;
var _all_ ;
ods output ColContr=_contribs_;
run;

ods _all_ close;
ods html;
ods graphics off;
run;

proc corresp data=_design1_ dim=3 short nocolumn=print norow=print;
var _all_ ;
title1 'Analysis Using Indicator Matrix';
title2 "&nvar. Variables        ";

data _inertia1_;
  set _coor_;
if _type_ = 'INERTIA';
s=1;
keep s contr1 contr2 contr3;

data _contribs_;
  set _contribs_;
fmtname = compress(label,' 0 1 2 3 4 5 6 7 8 9');

proc sort data=_contribs_;
by fmtname;

proc univariate data=_contribs_ noprint;
by fmtname;
var dim1 dim2 dim3;
output out=_trans1_ sum=sum1 sum2 sum3;

data _trans1_;
  set _trans1_;
s=1;

data _trans1_;
  merge _trans1_ _inertia1_;
by s;
discmeas1 = sum1 * contr1 * &nvar ;
discmeas2 = sum2 * contr2 * &nvar ;
discmeas3 = sum3 * contr3 * &nvar ;
keep fmtname discmeas1 discmeas2 discmeas3;

proc univariate data=_trans1_ noprint;
var discmeas1 discmeas2 discmeas3;
output out=_means1_ mean=inertia1 inertia2 inertia3;

proc print data=_means1_;
title 'Means for the Discrimination Measures';
format inertia1 inertia2 inertia3 6.3;

proc sort data=_trans1_;
by descending discmeas1;

data _plot1_;
  set _trans1_;
numvar1 = _n_;
variable = lowcase(fmtname);
keep numvar1 discmeas1 variable;
run;

ods graphics / reset antialias=off width=8in ;

proc sgplot data=_plot1_ pad=(top=5% bottom=5% right=10% left=5%);
loess x=numvar1 y=discmeas1 / markerattrs=(symbol=Circle size=10 color='BLUE') smooth=0.6 interpolation=cubic nolegfit;
xaxis grid label="Number of Variables" labelattrs=(size=12);
yaxis grid label="Disc. Measure" labelattrs=(size=12);
title 'Scree Plot for First Dimension';
run;
quit;

proc print data=_plot1_;
var variable discmeas1;
title 'Discrimination Measures for First Dimension';
format discmeas1 6.3;

proc sort data=_trans1_;
by descending discmeas2;

data _plot2_;
  set _trans1_;
numvar2 = _n_;
variable = lowcase(fmtname);
keep numvar2 discmeas2 variable;
run;

proc sgplot data=_plot2_ pad=(top=5% bottom=5% right=10% left=5%);
loess x=numvar2 y=discmeas2 / markerattrs=(symbol=Circle size=10 color='BLUE') smooth=0.6 interpolation=cubic nolegfit;
xaxis grid label="Number of Variables" labelattrs=(size=12);
yaxis grid label="Disc. Measure" labelattrs=(size=12);
title 'Scree Plot for Second Dimension';
run;
quit;

proc print data=_plot2_;
var variable discmeas2;
title 'Discrimination Measures for Second Dimension';
format discmeas2 6.3;

proc sort data=_trans1_;
by descending discmeas3;

data _plot3_;
  set _trans1_;
numvar3 = _n_;
variable = lowcase(fmtname);
keep numvar3 discmeas3 variable;
run;

proc sgplot data=_plot3_ pad=(top=5% bottom=5% right=10% left=5%);
loess x=numvar3 y=discmeas3 / markerattrs=(symbol=Circle size=10 color='BLUE') smooth=0.6 interpolation=cubic nolegfit;
xaxis grid label="Number of Variables" labelattrs=(size=12);
yaxis grid label="Disc. Measure" labelattrs=(size=12);
title 'Scree Plot for Third Dimension';
run;
quit;

proc print data=_plot3_;
var variable discmeas3;
title 'Discrimination Measures for Third Dimension';
format discmeas3 6.3;
run;

*========================================================================================
   This adds a label to each observation
========================================================================================;
data _label_;
  set _trans1_;
retain xsys '2' ysys '2';
length position $1 text $8;
y=discmeas2;
x=discmeas1;
function='LABEL';
position = '5';
text=lowcase(fmtname);
output;
run;

data _newcoors1_;
length function $9 label $8;
  set _label_;
retain x1space 'datavalue' y1space 'datavalue';
function='text'; label=text; x1=x; y1=y; textsize=12; width=20;
keep function textsize label x1 y1 x1space y1space width;
run;

proc sgplot data=_newcoors1_ sganno=_newcoors1_ pad=(top=5% bottom=5% right=10% left=5%);
scatter x=x1 y=y1 / markerattrs=(symbol=plus size=0);
xaxis grid label="First Disc. Measure" labelattrs=(size=12 color=blue);
yaxis grid label="Second Disc. Measure" labelattrs=(size=12 color=blue);
title 'Scatterplot #1 for Disc. Measures';
run;
quit;

*========================================================================================
   This adds a label to each observation
========================================================================================;
data _label_;
  set _trans1_;
retain xsys '2' ysys '2';
length position $1 text $8;
y=discmeas3;
x=discmeas2;
function='LABEL';
position = '5';
text=lowcase(fmtname);
output;
run;

data _newcoors2_;
length function $9 label $8;
  set _label_;
retain x1space 'datavalue' y1space 'datavalue';
function='text'; label=text; x1=x; y1=y; textsize=12; width=20;
keep function textsize label x1 y1 x1space y1space width;
run;

proc sgplot data=_newcoors2_ sganno=_newcoors2_ pad=(top=5% bottom=5% right=10% left=5%);
scatter x=x1 y=y1 / markerattrs=(symbol=plus size=0);
xaxis grid label="Second Disc. Measure" labelattrs=(size=12 color=blue);
yaxis grid label="Third Disc. Measure" labelattrs=(size=12 color=blue);
title 'Scatterplot #2 for Disc. Measures';
run;
quit;

%end;

 /*----------------------------*
  | Print subset of variables. |
  *----------------------------*/
%let print=%upcase(&print);
%if &print=YES %then %do;

proc sort data=_plot1_; by variable;
proc sort data=_plot2_; by variable;
proc sort data=_plot3_; by variable;

data _threedims_;
  merge _plot1_ _plot2_ _plot3_;
by variable;
if (numvar1 <= &ndim1 or numvar2 <= &ndim2 or numvar3 <= &ndim3 );
keep variable numvar1 numvar2 numvar3;

proc print data=_threedims_ split='*';
var variable numvar1 numvar2 numvar3;
title 'Printing Subset of Variables';
label variable='Variable'
      numvar1='Rank*Dim. 1' numvar2='Rank*Dim. 2' numvar3='Rank*Dim. 3'
;
run;

%end;

 /*----------------------------*
  | if all variables are used  |
  *----------------------------*/
%let allvars=%upcase(&sub);
 /*----------------------------------------*
  | Perform subset correspondence analysis |
  *----------------------------------------*/
%if %length(&sub)  %then %do;

ods _all_ close;
ods html;
run;

title 'Subset Correspondence Analysis';

data _subdat1_;
%if (&allvars ne ALL) %then 
%str(length &sub 8; set _dat1_ ; keep &sub ;);
%if (&allvars=ALL) %then 
%str(length &var 8; set _dat1_ ; keep &var ;);

proc sql noprint;                               
   select distinct name                         
   into : varlist1 separated by ' '              
   from dictionary.columns                      
   where libname='WORK' and memname='_SUBDAT1_';
quit;

data _subdat1_;
retain &varlist1;
  set _subdat1_;

proc transreg data=_subdat1_ design noprint;
model class(&varlist1 / zero=none);
output out=_subdesign1_(drop=_type_ _name_ intercept &varlist1);

proc contents data=_subdesign1_ out=_chekdat_(keep=name) noprint;

proc sql noprint;                               
   select nvar                         
   into :nvar2              
   from dictionary.tables                      
   where libname='WORK' and memname='_SUBDESIGN1_';
quit;


%if (&allvars ne ALL) %then %do;

data _subdat2_;
  set _dat1_;
drop &sub ;

proc sql noprint;                               
   select distinct name                         
   into : varlist2 separated by ' '              
   from dictionary.columns                      
   where libname='WORK' and memname='_SUBDAT2_';
quit;

data _subdat2_;
retain &varlist2;
  set _subdat2_;

proc transreg data=_subdat2_ design noprint;
model class(&varlist2 / zero=none);
output out=_subdesign2_(drop=_type_ _name_ intercept &varlist2);
run;

%end;

data _alldesign_;
%if (&allvars ne ALL) %then 
%str(merge _subdesign1_ _subdesign2_;);
%if (&allvars=ALL) %then 
%str(set _subdesign1_;);
run;  

 /*------------------------------------------------------------*
  | This IML code was adapted from the CORRESP macro from _SAS |
  | System for Statistical Graphics_ by M. Friendly (1991).    |
  *------------------------------------------------------------*/
proc iml;
use _chekdat_;
read all var{name} into L;
use _alldesign_;
read all into F;
N = F[+];
P = F / N;
r1 = p[,+];
c1 = p[+,];
Dr = diag(r1);
Dc = diag(c1);
S = inv(sqrt(Dr))*(P - r1*c1)*inv(sqrt(Dc));
subS = S(|,1:&nvar2|);
subDc = Dc(|1:&nvar2,1:&nvar2|);
call svd(u,d,v,subS);
princcol = inv(sqrt(subDc)) * v * diag(d);
standrow = inv(sqrt(Dr)) * u;
d2 = d # d;
print "singular values" d [format=7.4] "inertias" d2 [format=7.4];
sumsq = ssq(d);
print "sum of squares" sumsq [format=7.4];
create _princcol1_ from princcol;
append from princcol;
create _lab1_ from L;
append from L;
quit;

data _lab1_;
  set _lab1_;
label = col1;
keep label;

data _princcol1_;
  merge _princcol1_ (rename=(col1=dim1 col2=dim2 col3=dim3)) _lab1_;
type='VAR';
keep type label dim1-dim3;

data _coor2_;
  set _princcol1_;
length text $8 position $1 color $5;
retain function 'LABEL' xsys ysys '2' hsys '3';
x=dim1;
y=dim2;
if type='VAR' then do;
  function='LABEL';
  style='TRIPLEX';
  text=label;
  size = 2;
  position='5';
  color='RED';
  output;
end;
keep type x y text xsys ysys size function style position color;
run;

data _newcoor1_;
length function $9 label $8 textcolor $5;
  set _coor2_;
retain x1space 'datavalue' y1space 'datavalue';
function='text'; label=text; x1=x; y1=y; textsize=12; textcolor='red'; width=20;
keep function textcolor textsize label x1 y1 x1space y1space width;
run;

ods graphics / reset antialias=off width=11in ;

proc sgplot data=_newcoor1_ sganno=_newcoor1_ pad=(top=5% bottom=5% right=10% left=5%);
scatter x=x1 y=y1 / markerattrs=(symbol=plus size=0);
xaxis grid label="Dimension 1" labelattrs=(size=12 color=blue);
yaxis grid label="Dimension 2" labelattrs=(size=12 color=blue);
refline 0 / axis=x;
refline 0 / axis=y;
title "Subset Map for %left(&nvar2.) Categories (DIMS 1/2)";
run;
quit;

data _coor3_;
  set _princcol1_;
length text $8 position $1 color $5;
retain function 'LABEL' xsys ysys '2' hsys '3';
x=dim2;
y=dim3;
if type='VAR' then do;
  function='LABEL';
  style='TRIPLEX';
  text=label;
  size = 2;
  position='5';
  color='RED';
  output;
end;
keep type x y text xsys ysys size function style position color;
run;

data _newcoor2_;
length function $9 label $8 textcolor $5;
  set _coor3_;
retain x1space 'datavalue' y1space 'datavalue';
function='text'; label=text; x1=x; y1=y; textsize=12; textcolor='red'; width=20;
keep function textcolor textsize label x1 y1 x1space y1space width;
run;

proc sgplot data=_newcoor2_ sganno=_newcoor2_ pad=(top=5% bottom=5% right=10% left=5%);
scatter x=x1 y=y1 / markerattrs=(symbol=plus size=0);
xaxis grid label="Dimension 2" labelattrs=(size=12 color=blue);
yaxis grid label="Dimension 3" labelattrs=(size=12 color=blue);
refline 0 / axis=x;
refline 0 / axis=y;
title "Subset Map for %left(&nvar2.) Categories (DIMS 2/3)";
run;
quit;

data _princcol1_;
  set _princcol1_;
fmtname = compress(label,' 0 1 2 3 4 5 6 7 8 9');

proc sort data=_princcol1_;
by fmtname;

proc sort data=_trans1_;
by fmtname;

data _allstats_;
  merge _princcol1_ _trans1_;
by fmtname;
if type='VAR';
variable = label;
drop fmtname label;

proc sort data=_allstats_;
by dim1 dim2;
run;

 /*--------------------------*
  | Don't print zero levels. |
  *--------------------------*/
%let noprint=%upcase(&noprint);
%if &noprint=YES %then %do;
data _allstats_;
  set _allstats_;
leng1 = length(variable);
if (substr(variable,leng1,1)=0) then delete;
drop leng1;

proc print data=_allstats_ split='*' double;
id variable;
var dim1 dim2 discmeas1 discmeas2;
format dim1 dim2 discmeas1 discmeas2 7.3;
label discmeas1='DIM1:*Disc. Measure'
      discmeas2='DIM2:*Disc. Measure'
	  dim1='DIM1:*Coordinate'
	  dim2='DIM2:*Coordinate'
	  variable='Variable'
;
title1 'DIM 1/2 Statistics for Subset of Non-Zero Levels';
title2 'With Results Ordered by the Coordinates';

proc sort data=_allstats_;
by dim2 dim3;

proc print data=_allstats_ split='*' double;
id variable;
var dim2 dim3 discmeas2 discmeas3;
format dim2 dim3 discmeas2 discmeas3 7.3;
label discmeas2='DIM2:*Disc. Measure'
      discmeas3='DIM3:*Disc. Measure'
	  dim2='DIM2:*Coordinate'
	  dim3='DIM3:*Coordinate'
	  variable='Variable'
;
title1 'DIM 2/3 Statistics for Subset of Non-Zero Levels';
title2 'With Results Ordered by the Coordinates';
run;
%end;

%else %do;
proc print data=_allstats_ split='*' double;
id variable;
var dim1 dim2 discmeas1 discmeas2;
format dim1 dim2 discmeas1 discmeas2 7.3;
label discmeas1='DIM1:*Disc. Measure'
      discmeas2='DIM2:*Disc. Measure'
	  dim1='DIM1:*Coordinate'
	  dim2='DIM2:*Coordinate'
	  variable='Variable'
;
title1 'DIM 1/2 Statistics for Subset of Variables';
title2 'With Results Ordered by the Coordinates';

proc sort data=_allstats_;
by dim2 dim3;

proc print data=_allstats_ split='*' double;
id variable;
var dim2 dim3 discmeas2 discmeas3;
format dim2 dim3 discmeas2 discmeas3 7.3;
label discmeas2='DIM2:*Disc. Measure'
      discmeas3='DIM3:*Disc. Measure'
	  dim2='DIM2:*Coordinate'
	  dim3='DIM3:*Coordinate'
	  variable='Variable'
;
title1 'DIM 2/3 Statistics for Subset of Variables';
title2 'With Results Ordered by the Coordinates';
run;
%end;

%end;

 /*------------------------------------------------------------------*
  | Calculate the CCC statistic for series of two to seven clusters. |
  *------------------------------------------------------------------*/
%let fitclust=%upcase(&fitclust);
%if (&fitclust=YES) %then %do;

ods _all_ close;
ods html;
run;

title;

data _clustdat1_;
   set &data ;
keep &haclust &id ;

proc sort data=_clustdat1_;
by &id ;
run;

proc transreg data=_clustdat1_ design noprint;
model class(&haclust / zero=none);
output out=_clustdesign1_(drop=_type_ _name_ intercept &haclust);
id &id ;

data _subclust1_;
  set _clustdesign1_;
drop &id ;
run;

proc sql noprint;                               
   select distinct name                         
   into : varlist separated by ' '              
   from dictionary.columns                      
   where libname='WORK' and memname='_SUBCLUST1_';
quit;

proc corresp data=_clustdesign1_ dim=3 profile=row outc=_clustcoor_ noprint;
var &varlist ;
id &id ;
run;

data _scores_;
  set _clustcoor_;
if (_type_='OBS');
keep &id dim1-dim3;
run;

%macro buildfits(msize);
proc fastclus data=_scores_ maxclusters=&msize ;
var dim1 dim2 dim3;
id &id ;
ods output CCC=_cccstat_ ;
run;

data _onestat_;
  set _cccstat_;
nclust = input(symget('msize'),1.0);

proc append data=_onestat_ base=_tempstats_;
run;
%mend buildfits;

%macro fits;
%do m=2 %to 7;
  %buildfits(&m);
%end;
%mend fits;
%fits;

data _modstats_;
  set _tempstats_;
label nclust='Number of Clusters' value='CCC Criterion';
run;

proc datasets nolist;
delete _tempstats_;

proc print data=_modstats_ split='*';
id nclust;
var value;
run;

proc sgplot data=_modstats_;
series x=nclust y=value / datalabel=value;
xaxis grid;
yaxis grid;
title;
run;
quit;

%end;

 /*------------------*
  | cluster analysis |
  *------------------*/
%if (%length(&haclust) and %length(&nclust)) %then %do;

ods _all_ close;
ods html;
run;

title 'Clustering Using Homogeneity Analysis';

data _clustdat1_;
   set &data ;
keep &haclust &id ;

proc sort data=_clustdat1_;
by &id ;
run;

proc transreg data=_clustdat1_ design noprint;
model class(&haclust / zero=none);
output out=_clustdesign1_(drop=_type_ _name_ intercept &haclust);
id &id ;

data _subclust1_;
  set _clustdesign1_;
drop &id ;
run;

proc sql noprint;                               
   select distinct name                         
   into : varlist separated by ' '              
   from dictionary.columns                      
   where libname='WORK' and memname='_SUBCLUST1_';
quit;

proc corresp data=_clustdesign1_ dim=3 profile=row outc=_clustcoor_ noprint;
var &varlist ;
id &id ;
run;

data _scores_;
  set _clustcoor_;
if (_type_='OBS');
keep &id dim1-dim3;
run;

proc fastclus data=_scores_ out=_clust9_ maxclusters=&nclust ;
var dim1 dim2 dim3;
id &id ;
run;

data _clust9_;
  set _clust9_;
_s_ = 1;

proc univariate data=_clust9_ noprint;
var distance;
output out=_z1_ qrange=hspread q3=q3;

data _z1_;
  set _z1_;
upplim = q3 + 1.5 * hspread;
_s_ = 1;
keep _s_ upplim;
run;

data _clust9_;
length outlier $4;
  merge _clust9_ _z1_;
by _s_;
if (distance > upplim) then outlier=put(&id,5.);
                       else outlier=' ';
drop _s_ upplim;
run;

proc template;
define style styles.MyDefault;
parent=styles.default;
   style GraphData1 from GraphData1 / MarkerSymbol='CircleFilled';
   style GraphData2 from GraphData2 / MarkerSymbol='TriangleFilled';
   style GraphData3 from GraphData3 / MarkerSymbol='StarFilled';
   style GraphData4 from GraphData4 / MarkerSymbol='SquareFilled';
   style GraphData5 from GraphData5 / MarkerSymbol='DiamondFilled';
   style GraphData6 from GraphData6 / MarkerSymbol='HomeDownFilled';
   style GraphData7 from GraphData7 / MarkerSymbol='Asterisk';
   style GraphData8 from GraphData8 / MarkerSymbol='Hash';
   style GraphData9 from GraphData9 / MarkerSymbol='Plus';
end;
run;

ods html style=MyDefault ;
ods graphics / reset antialias=off width=8in;

proc sgplot data=_clust9_;
scatter x=dim1 y=dim2 / group=cluster grouporder=ascending markerattrs=(size=12);
run;

proc sgplot data=_clust9_;
scatter x=dim2 y=dim3 / group=cluster grouporder=ascending markerattrs=(size=12);
run;

proc sgplot data=_clust9_;
scatter x=cluster y=distance / group=cluster grouporder=ascending groupdisplay=cluster markerattrs=(size=10)
        datalabel=outlier datalabelattrs=(color=Red size=10 weight=Bold);
xaxis display=(nolabel);
yaxis grid;
title 'Distances for Each Cluster';
run;
quit;

data _save1_;
  set _clust9_;
keep &id cluster distance dim1 dim2 dim3;

proc sort data=_save1_;
by &id;

proc univariate data=_save1_ noprint;
var cluster;
output out=_max1_ max=maxclust;

data _max1_;
  set _max1_;
call symput('nclust',left(maxclust));
run;

data _clusters_;
  set _save1_;
array clust[&nclust];
do k = 1 to &nclust;
  clust[k] = (cluster=k);
end;
keep &id cluster clust1-clust&nclust ;
run;

data _newone_;
length &varlist 8;
  set _clustdesign1_;
keep &varlist;

proc contents data=_newone_ out=_chekdat_ noprint;

proc sort data=_chekdat_;
by varnum;

data _chekdat_;
  set _chekdat_;
keep name;

data _newtwo_;
length clust1-clust&nclust 8;
  set _clusters_;
keep clust1-clust&nclust;

proc contents data=_newtwo_ out=_cnames_(keep=name) noprint;
run;

 /*------------------------------------------*
  | Calculate the profiles for the clusters. |
  *------------------------------------------*/
proc iml;
use _newone_;
read all into F;
use _newtwo_;
read all into G;
use _chekdat_;
read all var{name} into L;
use _cnames_;
read all var{name} into L2;
H = G`*F;
c1 = G[+,];
char1 = t(char(c1,4,0));
char2 = concat(left(trim(L2)),'*');
char3 = t(concat(char2,left(trim(char1))));
char4 = compress(char3,' ');
prop = H` / c1;
create _prop1_ from prop[colname=char4];
append from prop;
create _label1_ from L;
append from L;
quit;

data _proportions_;
  merge _prop1_ _label1_ (rename=(col1=condition));

proc print data=_proportions_ split='_' double;
id condition;
format _numeric_ 5.2;
label condition='Condition';
title 'Profiles for Clusters';
run;

 /*----------------------------------------------------*
  | Print only even lines if all variables are binary. |
  *----------------------------------------------------*/
%let allbin=%upcase(&allbin);
%if &allbin=YES %then %do;

data _proportions_;
  set _proportions_;
if mod(_n_,2)=0;

proc print data=_proportions_ split='_' double;
id condition;
format _numeric_ 5.2;
label condition='Condition';
title 'Profiles for Clusters with Binary Outcomes';
run;

%end;

 /*--------------------------------------------*
  | Output the outcomes and cluster numbers.   |
  *--------------------------------------------*/
%if %length(&out)  %then %do;

data _save1_;
  set _save1_;
tempid = &id + 0;
drop &id ;

data _save1_ ;
  set _save1_;
&id = tempid;
keep &id cluster distance dim1 dim2 dim3;
run;

proc sort data=_save1_;
by &id ;

data _save1_;
  merge _save1_ _clustdat1_;
by &id ;

data &out ;
  set _save1_;
keep &id cluster distance dim1 dim2 dim3 &haclust ;
run;

 /*----------------------------*
  | Print subset of variables. |
  *----------------------------*/
%let printfreqs=%upcase(&printfreqs);
%if &printfreqs=YES %then %do;
proc sort data=_save1_;
by descending dim1;

data _subsave1_;
  set _save1_;
keep &haclust;
run;

proc iml;
use _subsave1_;
read all into L;
m = nrow(L);
n = ncol(L);
temp = j(m,1,0);
newL = L || temp;
do i=1 to m;
do j=1 to n;
 newL[i,n+1] = newL[i,n+1] + newL[i,n-j+1] # 10##(j);
end;
end;
submat = newL[,n+1];
create _concat_ from submat;
append from submat;
quit;

proc freq data=_concat_ order=data noprint;
tables col1 / outcum out=_freq1_(keep=count cum_freq);
run;

data _subclust_;
  merge _subsave1_ _concat_ ;
lagvar = lag(col1);
if (col1=lagvar) then delete;
run;

proc format;
value bin 0=' ' 1='1';
run;

data profile_freqs;
length &haclust count 8;
  merge _subclust_ _freq1_ ;
label count='Frequency';
format &haclust bin.;
drop col1 lagvar;
run;

proc print data=profile_freqs split='*';
var &haclust count cum_freq;
title 'Printout for PROFILE_FREQS';
run;
%end;

%end;

%end;

%done:
title; run;

%mend classification;


