
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname out 'DIRECTORY_INFO...\posse_data';


*====================================================================================================================

	'Example_C1_make_cancer_information.sas'  May 2018

  This program reproduces results found in Example C.1 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

=====================================================================================================================;
/*---------------------------------------------------------*
 | This submission converts Table B.5 in Appendix B to a   |
 | SAS data set which can analyzed using the POSSE macros. |
 *---------------------------------------------------------*/
data canc_info;		** Data from Lombard and Doering (1947) study **;
input radio papers lectures reading @;
  do knowledge = 0 to 1;
	input count @;
	output;
  end;
cards;
0 0 0 0 393  84
0 0 0 1  83  67
0 0 1 0  10   2
0 0 1 1   8   3
0 1 0 0 156  75
0 1 0 1 177 201
0 1 1 0   6   7
0 1 1 1  18  27
1 0 0 0  50  13
1 0 0 1  16  16
1 0 1 0   3   4
1 0 1 1   3   1
1 1 0 0  59  35
1 1 0 1  67 102
1 1 1 0   4   8
1 1 1 1   8  23
;

data canc_info;
  set canc_info;
do i=1 to count;
  output;
end;
drop count i;

data canc_info;
length id 8;
  set canc_info;
id = _n_;
run;

proc format;
value radio     0='No Radio' 1='Radio';
value reading   0='No Solid Reading' 1='Solid Reading';
value papers    0='No Newspaper' 1='Newspapers';
value lectures  0='No Lectures' 1='Lectures';
value knowledge 0='Poor' 1='Good';
run;

proc tabulate data=canc_info format=6.;
class radio reading papers lectures knowledge;
tables (papers=''*lectures=''),
       (radio=''*reading=''*knowledge='Knowledge')*(n=' ') / misstext=' ' rts=15;
format radio radio. reading reading. papers papers. lectures lectures. knowledge knowledge.;
title 'Table B.5';
run;

*data out.cancer_information;
*  set canc_info;
*run;

