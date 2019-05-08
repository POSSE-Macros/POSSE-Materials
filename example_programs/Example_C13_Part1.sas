
options nodate nonumber ps=60 ls=90;
libname in 'DIRECTORY_INFO...\posse_data';
/*-------------------------------------------*
 | Include the file that contains the macro  |
 *-------------------------------------------*/
filename classify 'DIRECTORY_INFO...\posse_macros\classification.sas';
%include classify;

*============================================================================================================

	'Example_C13_Part1.sas' May 2018

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
  set in.symptoms;  ** data for both surveys **;
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

/*----------------------------------------------*
 | This submission produces Figures C.18(a)-(c) |
 | in Appendix C of the POSSE users' guide.     |
 *----------------------------------------------*/
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
		   haclust=,
		   fitclust=,
		   nclust=,
		   id=,
		   allbin=,
		   out=,
		   printfreqs=);

