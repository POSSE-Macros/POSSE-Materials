
options nodate nonumber ps=60 ls=90;
libname in 'DIRECTORY_INFO...\posse_data';
/*--------------------------------------------*
 | Include the files that contain the macros  |
 *--------------------------------------------*/
filename corresp 'DIRECTORY_INFO...\posse_macros\correspondence.sas';
filename tabulate 'DIRECTORY_INFO...\posse_macros\tabulation.sas';
%include corresp tabulate;

*============================================================================================================

	'Example_C12_Part1.sas' June 2018

  This program reproduces results found in Example C.12 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

===================================================================================================================;
*proc datasets memtype=catalog kill;  ** delete any previous formatting from the SAS session **;
*run;

data allratings;
  set in.allratings;  ** x-ray classifications from both rounds from nine doctors **;

data subset_ratings;
  set allratings;
if (ratingone=ratingtwo) then delete;
if (ratingtwo > ratingone) then do;
  matchedcells=100*ratingone + ratingtwo; direction=1;
end;
else do;
  matchedcells=100*ratingtwo + ratingone; direction=2;
end;
run;

data subset_ratings;
  set subset_ratings;
iid = _n_;  ** ID variable for the matched cells **;
run;

/*--------------------------------------------*
 | NOTE THAT THE NUMBER OF NON-MISSING LEVELS |
 | MUST MATCH THE NUMBER OF FORMAT LABELS.    |
 *--------------------------------------------*/
proc format cntlout=othrfmt1;						*required formats for other variables;
value ratingone 1='0/0' 2='0/1' 3='1/0' 4='1/1' 5='1/2' 6='2/1' 7='2/2' 8='2/3' 9='3/2' 10='3/3';
value ratingtwo 1='0/0' 2='0/1' 3='1/0' 4='1/1' 5='1/2' 6='2/1' 7='2/2' 8='2/3' 9='3/2' 10='3/3';
value matchedcells 102='1*2' 103='1*3' 104='1*4' 105='1*5' 106='1*6' 107='1*7' 109='1*9' 203='2*3'
                   204='2*4' 209='2*9' 304='3*4' 305='3*5' 306='3*6' 307='3*7' 308='3*8' 405='4*5'
                   406='4*6' 407='4*7' 408='4*8' 506='5*6' 507='5*7' 508='5*8' 607='6*7' 608='6*8'
                   609='6*9' 610='6*10' 708='7*8' 709='7*9' 710='7*10' 809='8*9' 810='8*10' 910='9*10'; 
value direction 1='+' 2='-';
run;

/*----------------------------------------------------------*
 | These submissions produce results for Tables C.16(a)-(b) |
 | in Appendix C of the POSSE users' guide.                 |
 *----------------------------------------------------------*/
%tabulation(
         dataset=allratings,
         response=ratingone,
         fmtresp=ratingone,
         secondvar=ratingtwo,
         thirdvar=,
         byvar=,
		 id=id,
		 perc=no,
		 rowresp=yes,
		 range1=,
		 range2=,
		 range3=);

%tabulation(
         dataset=subset_ratings,
         response=matchedcells,
         fmtresp=matchedcells,
         secondvar=direction,
         thirdvar=,
         byvar=,
		 perc=no,
		 rowresp=,
		 id=iid,
		 range1=,
		 range2=,
		 range3=);

