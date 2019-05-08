
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

  Once the directory information is inserted, this program will include the POSSE macros within a SAS session.
  This program includes the macro code for the five POSSE macros along with notes to assist users.  See the
  _POSSE Macros Users’ Guide for the Exploration of Observational Health Care Data_ for more detailed information
  and guidance for using the macros.

     DISCLAIMER:  The five POSSE macros are provided to SAS users who wish to perform global exploratory analyses
     near the beginning of a data analysis.  However, they assume a working knowledge of correspondence analysis
     and homogeneity analysis.  In addition, CDC and NIOSH do not warrant the reliability or accuracy of the
     software, graphics or text.

===================================================================================================================;
*proc datasets memtype=catalog kill;  ** delete any previous formatting from the SAS session **;
*run;

/*----------------------------------------------*
 | SEE THE NOTES BELOW FOR USING THE MACRO.     |
 *----------------------------------------------*/
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

*=====================================================================================
	-- NOTES FOR DATA_PREP MACRO --

(See the _POSSE Macros Users’ Guide for the Exploration of Observational Health Care Data_
		 for more detailed information and guidance for using this macro.)

 The macro insertions include the following:
		                    /*--------------------------------------*/
         rawdata=,			/* -- Original dataset                  */
         newdata=,			/* -- Set to YES after creating the     */
		 			  		/*    first new categorical variable.   */
         contvar= 		 	/* -- Continuous variable               */
		 plotdist=          /* -- YES gives distribution plots      */
		 			  		/*    for the continuous variable(s).   */
		 			  		/*--------------------------------------*/
		 catname=,          /* -- Name for new categorical variable */
		 			  		/*    created from continuous variable. */
		 firstlevel=,       /* -- 1st level equals '1' (default='0')*/
		 			  		/*--------------------------------------*/
		 			  		/*  UNIFORM RANKING FOR NEW CAT. VAR.   */
         ranklevs=          /* -- Number of levels for new categor- */
		                    /*    cal variable using PROC RANK      */
		 			  		/*--------------------------------------*/
		 			  		/*  USE CUTPOINTS FOR NEW CAT. VARIABLE */
		 numctpts=,         /* -- Number of cutpoint for continuous */
		                    /*    variable (= number of levels - 1) */
		 cutpoint1=,        /* -- 1st cutpoint                      */
		 cutpoint2=,        /* -- 2nd cutpoint                      */
		 cutpoint3=,        /* -- 3rd cutpoint                      */
		 cutpoint4=,        /* -- 4th cutpoint                      */
		 cutpoint5=,        /* -- 5th cutpoint                      */
		 			  		/*--------------------------------------*/
         cluster=,          /* -- YES to perform cluster analysis   */
		 			  		/*    for RESPONSE and PREDVAR vars     */
         response=,         /* -- Categorical response variable     */
         predvar=,          /* -- Categorical predictor variable    */
		 			  		/*--------------------------------------*/
		 outdata=           /* -- Name for output dataset (USE THIS */
		 			  		/*    ENTRY AFTER ALL DATA IS CREATED)  */
         id=       	  		/* -- ID for observations               */
		 savevars=          /* -- Variables saved to the outputted  */
		 			  		/*    data (ID is automatically saved)  */
		 			  		/*--------------------------------------*/

  *  This macro creates a data set for use by the POSSE method by     *
  *  converting the continuous variables to categorical variables.    *
  *  Descriptive statistics can be produced to assist in the choice   *
  *  of cutpoints, and a method of cluster analysis developed by      *
  *  Greenacre (1988, 2007) can be used to choose the number of       *
  *  levels for a categorical variable.                               *
  *                                                                   *
  *  The user must enter the name of the original data set for the    *
  *  first submission of the macro.  However, after creating the      *
  *  first variable for the new dataset, then 'YES' must be inserted  *
  *  at the 'newdata=' entry to begin saving the new variables.       *
  *                                                                   *
  *  In order to convert a continous variable to a categorical one,   *
  *  the user can first enter the name of the continous variable at   *
  *  'contvar=' and then 'YES' at 'plotdist=' to obtain information   *
  *  about the distribution of the continuous variable.  After        *
  *  examining this information, the user can transform the variable  *
  *  to a categorical variable in one of two ways.  The first is to   *
  *  insert the number of levels for the categorical variable at      *
  *  'ranklevs=' to use PROC RANK to automatically create the new     *
  *  variable.  This will usually result in each level having the     *
  *  same or nearly the same number of observations.                  *
  *                                                                   *
  *  The second way to create the new categorical variable is to      *
  *  insert the number of cutpoints at 'numcutpts=' and then to       *
  *  insert up to five cutpoints at the macro entries that are        *
  *  provided.  Note that the number of levels for the new variable   *
  *  will be one more than the number of cutpoints.  In addition,     *
  *  if there are any missing outcomes, then another level will be    *
  *  created for these outcomes.  For example, if there are three     *
  *  cutpoints and some missing values, then there will be five       *
  *  levels for the new categorical variable.                         *
  *                                                                   *
  *  By inserting 'YES' at 'cluster=' entry, the user can perform     *
  *  a cluster analysis on the rows of a two-way table, as shown in   *
  *  the papers by Greenacre (1988, 2007).  The rows of the table     *
  *  represent the levels of the 'predvar=' variable and the columns  *
  *  represent the levels of the 'response=' variable.  The results   *
  *  include a cluster tree (also called a dendogram) which indicates *
  *  the stages at which the rows are combined.  The rows with the    *
  *  most similar profiles are combined first and near the left of    *
  *  the cluster tree.  The printout also shows the R-Square for the  *
  *  number of clusters.  For example, if the 'predvar' variable has  *
  *  four levels and the R-square equals .90 for three clusters, then *
  *  this means that only about 10% of the information would be lost  *
  *  when combining two of the four levels into one combined level.   *
  *                                                                   *
  *  Although the methods are otherwise identical, Greenacre (2007)   *
  *  expresses his results in terms of a chi-square scale, but the    *
  *  results here are expressed in terms of the between sums-of-      *
  *  squares which are calculated from Ward's method of clustering.   *
  *                                                                   *
  *  Finally, once the data creation is completed (and not before),   *
  *  the new data set can be named and saved using the 'outdata='     *
  *  entry, and the variables to be saved can be inserted into the    *
  *  'savevars=' entry.  The insertion for the ID variable is         *
  *  required and is automatically included in the new data set.      *
  *                                                                   *
  *  REFERENCES                                                       *
  *  --Greenacre, M. (1988), "Clustering the Rows and Columns of a    *
  *  Contingency Table," Journal of Classification, 5: 39-51.         *
  *  --Greenacre, M. (2007), Correspondence Analysis in Practice      *
  *  (Second Edition), Chapman & Hall, New York.                      *
  =====================================================================;


/*----------------------------------------------*
 | SEE THE NOTES BELOW FOR USING THE MACRO.     |
 *----------------------------------------------*/
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

*==================================================================================
	-- NOTES FOR THE CLASSIFICATION MACRO --

(See the _POSSE Macros Users’ Guide for the Exploration of Observational Health Care Data_
		 for more detailed information and guidance for using this macro.)

 The macro insertions include the following:
					/*--------------------------------------*/
		data=		/* -- Dataset to analyze                */
		var=		/* -- Variable names                    */
					/*--------------------------------------*/
		print=		/* -- YES prints a subset of variables  */
		ndim1=		/* -- Number of vars from 1st dimension */
		ndim2=		/* -- Number from 2nd dimension         */
		ndim3=		/* -- Number from 3rd dimension         */
		 			/*--------------------------------------*/
        sub=,       /* -- Variables for Subset CA.          */
		 		    /*   (Insert ALL when using all VAR=)   */
	    noprint=    /* -- YES excludes the zero levels      */
                    /*    from the printed output.          */
		 		    /*--------------------------------------*/
		haclust=    /* -- Perform cluster analysis for the  */
                    /*    the specified variables.          */
		fitclust=   /* -- Calculate the CCC statistic for   */
                    /*    a series of 2-7 clusters.         */
		nclust=     /* -- Number of clusters.               */
		id=         /* -- Required ID for cluster analysis. */
 		allbin=     /* -- YES when all variables are binary.*/
        out=        /* -- Output cluster information.       */
 	    printfreqs= /* -- YES prints the frequencies for    */
                    /*    the profiles ordered by the       */
                    /*    variables found in 'haclust='.    */
                    /*--------------------------------------*/

 The three basic parts to this macro are as follows:

  *  Part 1.  The macro finds and plots the discrimination measures   *
  *  for the set of variables.                                        *
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
  *  the cluster analysis.  To determine the number of clusters, the  *
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
  *  option is used, the variables in the 'haclust' entry should be   *
  *  ordered by the positive outcomes found for the variables along   *
  *  the first dimension, as indicated by the first map produced for  *
  *  the subset correspondence analysis.                              *
  ====================================================================;


/*----------------------------------------------*
 | SEE THE NOTES BELOW FOR USING THE MACRO.     |
 *----------------------------------------------*/
%prelim_ca(
         dataset=,
         response=,
         fmtresp=,
         explanvars=,
         covars=,
         fmtothr=,
		 id=,
		 onedim=);

*====================================================================================
	-- NOTES FOR PRELIM_CA MACRO --

(See the _POSSE Macros Users’ Guide for the Exploration of Observational Health Care Data_
		 for more detailed information and guidance for using this macro.)

 The macro insertions include the following:
						/*--------------------------------------*/
		dataset=		/* -- Dataset to be analyzed.           */
		response=		/* -- Outcome variable (>= 2 levels)    */
		fmtresp=		/* -- Format for outcomes (optional)    */
		explanvars=		/* -- Explanatory vars (> 2 levels)     */
		covars=			/* -- Covariates (> 2 levels)           */
		fmtothr=		/* -- Formats for other vars (required) */
		id=            	/* -- ID for observations               */
		onedim=			/* -- Enter YES for 1-dim. solution     */
		 				/*--------------------------------------*/

  NOTE: If m is the number of levels for the outcome and n is the
  total number of categories for all the other variables, then min(m,n)
  should generally be >= 3 to run this program.  If the outcome is
  binary, you can use the optional entry of 'onedim=YES'.

  The results for the macro include the tables of inertias and the
  correspondence maps for the types of variables which have been
  provided by the user.  For example, if only the names for the
  outcomes and covariates are provided, then only these results
  will be shown (i.e., one table of inertias and one map).

*=====================================================================================;


/*----------------------------------------------*
 | SEE THE NOTES BELOW FOR USING THE MACRO.     |
 *----------------------------------------------*/
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
		 stratavar=,
         fmtstrata=,
		 showobs=,
		 highlightobs=,
		 circlelevel=,
		 noplot=);

*=====================================================================================
	-- NOTES FOR CORRESPONDENCE MACRO --

(See the _POSSE Macros Users’ Guide for the Exploration of Observational Health Care Data_
		 for more detailed information and guidance for using this macro.)

 The macro insertions include the following:
						/*--------------------------------------*/
		dataset=		/* -- Dataset to be analyzed.           */
		response=		/* -- Outcome variable (>= 3 levels)    */
		fmtresp=		/* -- Format for outcomes (optional)    */
		explanvars=		/* -- Explanatory vars (required)       */
		covars=			/* -- Covariates                        */
		fmtothr=		/* -- Formats for other vars (required) */
		id=            	/* -- ID for observations               */
		onedim=			/* -- Enter YES for 1-dim. solution.    */
		twodim= 		/* -- Enter YES for 2-dim. solution.    */
		 				/*--------------------------------------*/
		stratavar= 		/* -- Insert a stratification variable. */
		 				/*    All types of variables must be    */
		 			   	/*    specified for this operation.     */
		 				/*    To stratify by the propensity     */
		 				/*    strata, enter 'propstrat' here.   */
        fmtstrata=   	/* -- Format for strata (optional)      */
			   			/*--------------------------------------*/
		showobs=		/* - Display observations in plots.     */
		highlightobs=	/* - Color obs. for level of other vars.*/ 
		circlelevel=	/* - Circle obs. for level of outcome.  */ 
		noplot=			/* - Insert 'ONE' or 'TWO' to suppress  */ 
						/*   either the first or second plots.  */
						/*--------------------------------------*/

  NOTE: If m is the number of levels for the outcome and n is the
  total number of levels for all the other variables, then min(m,n)
  should generally be >= 4 to run this program.  If the response
  has three levels, the optional entry of 'twodim=YES' will allow the
  program to run by producing results only for the first two dimen-
  sions, and if the outcome is binary, you can use the optional entry  
  of 'onedim=YES'.  However, if a stratification variable is specified, 
  the dimension will then be >= 3.

  Two options for the macro are as follows:

  *  Option 1 (No Stratification Variable):  The macro provides the   *
  *  tables of contributions to the inertias for the various types of *
  *  variables for the first three dimensions, with correspondence    *
  *  maps being given for the Dimension 1 versus Dimension 2 results  *
  *  and for the Dimension 2 versus Dimension 3 results.  The user    *
  *  can choose to either show or hide the individual observations    *
  *  for these maps, and the user also has the option of highlighting *
  *  one level of any of the explanatory variables or covariates, and *
  *  of also circling the observations for one level of the outcome.  *
  *  Either plot can also be suppressed using the NOPLOT option.  A   *
  *  larger size for a label shown in a map indicates a better fit    *
  *  for that effect.                                                 *
  *                                                                   *
  *  Option 2 (Using a Stratification Variable):  After inserting     *
  *  a variable name after 'stratavar=', the macro provides tables    *
  *  of contributions for results which stratify the outcomes by this *
  *  variable.  Optional formatting for the stratification variables  *
  *  can also be provided.  The stratification variable can be either *
  *  an existing covariate or new variable which is created and found *
  *  in the dataset with the other variables.  Other options, such as *
  *  highlighting or circling the observations with respect to a      *
  *  level of a factor or the outcome, are also available, and it is  *
  *  also possible to suppress the display of either of the plots.    *
  ====================================================================;


/*----------------------------------------------*
 | SEE THE NOTES BELOW FOR USING THE MACRO.     |
 *----------------------------------------------*/
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

*=====================================================================================
	-- NOTES FOR TABULATION MACRO --

(See the _POSSE Macros Users’ Guide for the Exploration of Observational Health Care Data_
		 for more detailed information and guidance for using this macro.)

 The macro insertions include the following:
		                    /*--------------------------------------*/
         dataset= 			/* -- Dataset to be analyzed            */
         response=          /* -- Outcome or response variable      */
         fmtresp= 		 	/* -- Formatting for outcome (optional) */
         secondvar=         /* -- Second variable (required)        */
         thirdvar=          /* -- Third variable (optional)         */
		 byvar=             /* -- By-variable                       */
		 id=                /* -- ID for observations               */ 
		 			  		/*--------------------------------------*/
		 			  		/*    -OPTIONAL-                        */
		 perc=		    	/* -- Set to NO for no row percentages  */
		 rowresp=		    /* -- Set to YES to make row variable   */
		 				    /*    the response/column variable      */
		 range1=		    /* -- Range for outcome variable        */
		 					/*    (e.g., '1 to 5')                  */
		 range2=		    /* -- Range for second variable         */
		 					/*    (e.g., '0 to 1')                  */
		 range3=  		    /* -- Range for third variable          */
		 					/*    (e.g., '0 to 2')                  */
                       		/*--------------------------------------*/
 ====================================================================;





