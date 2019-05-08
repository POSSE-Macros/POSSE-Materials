
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
/*------------------------------------------*
 | Include the files containing the macros  |
 *------------------------------------------*/
filename dataprep 'DIRECTORY_INFO...\data_prep.sas';
filename classify 'DIRECTORY_INFO...\classification.sas';
filename prelim 'DIRECTORY_INFO...\prelim_ca.sas';
filename corresp 'DIRECTORY_INFO...\correspondence.sas';
filename tabulate 'DIRECTORY_INFO...\tabulation.sas';
%include dataprep classify prelim corresp tabulate;

*==================================================================================================================

	'posse_templates_shortversion.sas'  Last edited March 2018

  Once the directory information is inserted, this program will include the POSSE macros in the SAS session.
  This program includes the macro code for the five POSSE macros.  See the _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_ for more detailed information and guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

===================================================================================================================;
*proc datasets memtype=catalog kill;  ** delete any previous formatting from the SAS session **;
*run;

%data_prep(
         rawdata=,
		 newdata=,
         contvar=,
		 plotdist=,
		 catname=,
		 firstlevel=,
		 ranklevs=,
		 numcutpts=,
		 cutpoint1=,
		 cutpoint2=,
		 cutpoint3=,
		 cutpoint4=,
		 cutpoint5=,
         cluster=,
         response=,
         predvar=,
		 outdata=,
		 id=,
		 savevars=);


%classification(
           data=,
           var=,
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


%prelim_ca(
         dataset=,
         response=,
         fmtresp=,
         explanvars=,
         covars=,
         fmtothr=,
		 id=,
		 onedim=);


%correspondence(
         dataset=,
         response=,
         fmtresp=,
         explanvars=,
         covars=,
         fmtothr=,
		 id=,
		 onedim=,
		 twodim=,
		 showobs=,
		 stratavar=,
         fmtstrata=,
		 highlightobs=,
		 circlelevel=,
		 noplot=);


%tabulation(
         dataset=,
         response=,
         fmtresp=,
         secondvar=,
         thirdvar=,
         byvar=,
		 id=,
		 perc=,
		 rowresp=,
		 range1=,
		 range2=,
		 range3=);

