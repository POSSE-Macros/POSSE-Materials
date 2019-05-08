
*options nodate nonumber mprint symbolgen mlogic source2 ps=60 ls=90 nofmterr;
options nodate nonumber ps=60 ls=90;  ** Add 'mprint' to options to see executed macro code in the LOG window. **;
libname in 'DIRECTORY_INFO...\posse_data';
/*--------------------------------------------*
 | Include the files that contain the macros  |
 *--------------------------------------------*/
filename prelim 'DIRECTORY_INFO...\posse_macros\prelim_ca.sas';
filename tabulate 'DIRECTORY_INFO...\posse_macros\tabulation.sas';
%include prelim tabulate;

*==================================================================================================================

	'Example_C4_Screening Vars.sas'  April 2018

  This program reproduces results found in Example C.4 of Appendix C of _POSSE Macros Users’ Guide for the
  Exploration of Observational Health Care Data_.  See the users' guide for more detailed information and
  guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

===================================================================================================================;
*proc datasets memtype=catalog kill;  ** delete any previous formatting from the SAS session **;
*run;

/*----------------------------------------------------------------------*
 | The data set 'icucat' is derived from the data found in Appendix 2   |
 | of Hosmer and Lemeshow, Applied Logistic Regression, Wiley, (1989).  |
 *----------------------------------------------------------------------*/
data icudat;
  set in.icucat;
run;

proc format cntlout=othrfmt1;			*** required formats ***;
value status 0='Surv' 1='Died';
value gender 0='Male' 1='Female';
value previcu 0='NoPrev' 1='Prev';
value surgery 0='NoSurg' 1='Surg';
value emergency 0='NoEmer' 1='Emer';
value cpr 0='NoCPR' 1='CPR';
value uncons 0='Cons' 1='UnCons';
value cancer 0='NoCanc' 1='Canc';
value fracture 0='NoFr' 1='Fract';
value race 0='NonWh' 1='White';
value agecat 1='Age1' 2='Age2' 3='Age3';
value renal 0='NoRen' 1='Renal';
value infect 0='NoInf' 1='Infect';
value bloodpress 1='LoBP' 2='MedBP' 3='HiBP';
value heartrate 1='LoHR' 2='MedHR' 3='HiHR';
value bldoxy 0='HiOxy' 1='LoOxy';
value bldph 0='HiPH' 1='LoPH';
value bldco 0='LoCO' 1='HiCO2';
value bldbic 0='HiBIC' 1='LoBIC';
value bldcret 0='LoCr' 1='HiCreat';
run;

/*----------------------------------------------*
 | This submission produces Figures C.4 and C.5 |
 | in Appendix C of the POSSE users' guide.     |
 *----------------------------------------------*/
%prelim_ca(
         dataset=icudat,
         response=status,
         fmtresp=status,
         explanvars=surgery cancer renal infect cpr previcu emergency fracture bldoxy bldph bldco bldbic bldcret
                    uncons bloodpress heartrate,
         covars=gender agecat race,
         fmtothr=othrfmt1,
		 id=id,
		 onedim=YES);

%tabulation(
         dataset=icudat,
         response=status,
         fmtresp=status,
         secondvar=uncons,
         thirdvar=,
         byvar=,
		 id=id,
		 range1=,
		 range2=,
		 range3=);

%tabulation(
         dataset=icudat,
         response=status,
         fmtresp=status,
         secondvar=bloodpress,
         thirdvar=,
         byvar=,
		 id=id,
		 range1=,
		 range2=,
		 range3=);

%tabulation(
         dataset=icudat,
         response=fracture,
         fmtresp=fracture,
         secondvar=agecat,
         thirdvar=,
         byvar=,
		 id=id,
		 range1=,
		 range2=,
		 range3=);

