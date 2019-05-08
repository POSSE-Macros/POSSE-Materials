
options nodate nonumber ps=60 ls=90;

libname in 'DIRECTORY_INFO...\posse_data';
/*-------------------------------------------*
 | Include the file that contains the macro  |
 *-------------------------------------------*/
filename classify 'DIRECTORY_INFO...\posse_macros\classification.sas';
%include classify;

*============================================================================================================

	'Example_C13_Part5.sas' May 2018

  This program reproduces results found in Example C.13 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

===================================================================================================================;
*proc datasets memtype=catalog kill;  ** delete any previous formatting from the SAS session **;
*run;

data symptoms;
  set in.symptoms;
iid = _n_;
run;

data sympt;
  set symptoms;
array x[20] wheeze wheezecond clearcgh shortbreath normbetw afterexer chesttight freqsympts
           heavyexer coldair workdust exerbreath wokecgh cghmorn cghlater cghoften
           phlgmorn phlglater stuffnose blocknose;
array y[20] wh whc clcgh shbr norb exer chtgh frsymp hexer cair wdust
            exerb woke cghm cghl cgho phm phl stnos blnos;
do i=1 to 20;
  y[i]= x[i];
end;
keep iid wh whc clcgh shbr norb exer chtgh frsymp hexer cair wdust
         exerb woke cghm cghl cgho phm phl stnos blnos;
run;

/*------------------------------------------*
 | This submission produces Table C.19      |
 | in Appendix C of the POSSE users' guide. |
 *------------------------------------------*/
%classification(
           data=sympt,
           var=wh whc clcgh shbr norb exer chtgh frsymp hexer cair wdust
               exerb woke cghm cghl cgho phm phl stnos blnos,
           print=,
           ndim1=,
           ndim2=,
           ndim3=,
           sub=,
           noprint=,
		   haclust=cghl cgho chtgh frsymp hexer norb phl shbr stnos wh whc woke,
		   fitclust=,
		   nclust=5,
		   id=iid,
		   allbin=yes,
		   out=tempclust,
		   printfreqs=);

/*----------------------------------------------------------------------------*
 | The following can be used to assign labels to the categories to make them  |
 | more descriptive. RUN THIS ONLY ONCE BEFORE EXITING THE SAS SESSION.       |
 *----------------------------------------------------------------------------*/
proc format;
value $var_ 'cghl1'='Cough Later in Day' 'cgho1'='Cough Often' 'chtgh1'='Chest Tight' 'frsymp1'='Frequent Chest Symptoms'
		    'hexer1'='Symptoms with Heavy Exercise' 'norb1'='Normal Between Wheezing' 'phl1'='Phlegm Later in Day'
		    'shbr1'='Shortness of Breath' 'stnos1'='Stuffed Nose or Drainage' 'wh1'='Chest Wheezing'
		    'whc1'='Wheeze Without Cold' 'woke1'='Woken by Cough';

proc print data=_proportions_ split='_' double;
id condition;
format _numeric_ 5.2 condition $var_.;
label condition='Condition';
run;

/*-------------------------------------------------------------------------------------*
 | Before saving the cluster dataset, we reordered the clusters so that they have the  |
 | following labels:  1='Norm' 2='HvyExer' 3='ColdSympt' 4='AsthLike' 5='Other'        |
 *-------------------------------------------------------------------------------------*/
/*
data tempclust;
  set tempclust;
if (cluster=1)      then symptcluster=3;
else if (cluster=2) then symptcluster=1;
else if (cluster=3) then symptcluster=5;
else if (cluster=4) then symptcluster=4;
                    else symptcluster=2;
keep iid symptcluster;

** This retrieves the original ID variable and other variables for the subsequent analysis. **;
data saveclust;
  merge symptoms tempclust;
by iid;

proc print data=saveclust;
run;

*data in.symptclusters;
*  set saveclust;
*run;
*/

