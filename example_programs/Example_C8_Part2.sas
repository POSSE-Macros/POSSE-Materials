
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname in 'DIRECTORY_INFO...\posse_data';
/*-------------------------------------------*
 | Include the file that contains the macro  |
 *-------------------------------------------*/
filename classify 'DIRECTORY_INFO...\posse_macros\classification.sas';
%include classify;

*====================================================================================================================

	'Example_C8_Part2.sas'  May 2018

  This program reproduces results found in Example C.8 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

=====================================================================================================================;
data cancer_information;
  set in.cancer_information; ** Data from Lombard and Doering (1947) study **;
run;

data cancer_info;
  set cancer_information;
array x[5] knowledge lectures papers radio reading;
array y[5] know lec pap rad read;
do i=1 to 5;
  y[i]= x[i];
end;
keep id know lec pap rad read;
run;

/*------------------------------------------*
 | This submission produces Figure C.12     |
 | in Appendix C of the POSSE users' guide. |
 *------------------------------------------*/
%classification(
           data=cancer_info,
           var=know lec pap rad read,
           print=,
           ndim1=,
           ndim2=,
           ndim3=,
           sub=,
           noprint=,
		   haclust=know lec pap rad read,
		   fitclust=yes,
		   nclust=,
		   id=id,
		   allbin=,
		   out=,
		   printfreqs=);

