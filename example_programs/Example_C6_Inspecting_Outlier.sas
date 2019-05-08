
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber ps=60 ls=90;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname in 'DIRECTORY_INFO...\posse_data';
/*-------------------------------------------*
 | Include the file that contains the macro  |
 *-------------------------------------------*/
filename corresp 'DIRECTORY_INFO...\posse_macros\correspondence.sas';
%include corresp;

*==================================================================================================================

	'Example_C6_Inspecting_Outlier.sas'  April 2018

  This program reproduces results found in Example C.6 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

===================================================================================================================;
proc datasets memtype=catalog kill;  ** delete any previous formatting from the SAS session **;
run;

proc format cntlout=othrfmt1;			*** required formats ***;
value status 0='Surv' 1='Died';
value bloodpress 1='LoBP' 2='MedBP' 3='HiBP';
value heartrate 1='LoHR' 2='MedHR' 3='HiHR';
value bldoxy 0='HiOxy' 1='LoOxy';
value bldph 0='HiPH' 1='LoPH';
value bldco 0='LoCO' 1='HiCO2';
value bldbic 0='HiBic' 1='LoBIC';
value bldcret 0='LoCr' 1='HiCreat';
run;

proc format;
value condition 1='NoEmerg' 2='EmergCons' 3='EmergUncons' 4='Subj208';
run;

/*----------------------------------------------------------------------*
 | The data set 'icucat' is derived from the data found in Appendix 2   |
 | of Hosmer and Lemeshow, Applied Logistic Regression, Wiley, (1989).  |
 *----------------------------------------------------------------------*/
data icudat;
  set in.icucat;
** new var **;
if (emergency=0 and uncons=0)      then condition=1;
else if (emergency=1 and uncons=0) then condition=2;
else if (emergency=1 and uncons=1) then condition=3;
								   else condition=4;
run;

/*-----------------------------------------------*
 | This submission produces Figures C.7(a)-(b)   |
 | in Appendix C of the POSSE users' guide.      |
 *-----------------------------------------------*/
%correspondence(
         dataset=icudat,
         response=condition,
         fmtresp=condition,
         explanvars=bloodpress heartrate bldph bldco bldbic bldcret,
         covars=bldoxy,
         fmtothr=othrfmt1,
		 id=id,
		 onedim=,
		 twodim=,
		 showobs=YES,
		 stratavar=,
         fmtstrata=,
		 highlightobs=LoOxy,
		 circlelevel=1,  /* Insert '2' here and resubmit the macro to produce Figures A.7(c)-(d) */
		 noplot=);

