/*Import the dataset to sas*/
data German.credit;
infile 'C:\Users\chamath\Desktop\SAS\SAS_Projects\German credit\german.txt';
input checking$ duration history$ purpose$ amount savings$ employ$ rate status$
debtors$ residence property$ age other_plans$ housing$ exist_cr job$ provide phone$ foreign$ goodbad;
run;

/*What is in the dataset*/
proc contents data=German.credit position;
run;

/*Finding the missing values*/
ods pdf file="C:\Users\chamath\Desktop\SAS\SAS_Projects\German credit\missing.pdf";
title "Missing values";
proc sql;
select*from German.credit
where checking is null or duration is null or history is null or purpose is null or amount is null or savings is null or employ is null or rate is null or status is null or
debtors is null or residence is null or property is null or age is null or other_plans is null or housing is null or exist_cr is null or job is null or provide is null or phone 
is null or foreign is null or goodbad is null;
quit;
ods pdf close;

/*Variable transformation*/
data German.credit_1;
set German.credit;
if goodbad=1 then y='Good'; 
else y='Bad';
run;

/* Univariate analysis */
proc univariate data=German.credit_1 ; /*get an idea about all continuous variables*/
var duration rate residence exist_cr amount age;
run;

proc univariate data=German.credit_1 noprint; /*plotting histograms for all continuous variables*/
var rate residence exist_cr amount age duration provide;
histogram;
run;

title 'Distribution of Duration';
proc univariate data=German.credit_1 noprint;
histogram duration/midpoints=10 to 80 by 10; /*changing the bin with*/
run;

/*Box plots for above 3 continuous predictors*/
title;
proc sgplot data= German.credit_1;
 vbox amount;
run;

proc sgplot data= German.credit_1;
 vbox age; 
run;

proc sgplot data= German.credit_1;
 vbox duration; 
run;

/*Analysing the response variable*/
ods pdf file="C:\Users\chamath\Desktop\SAS\SAS_Projects\German credit\class_variable.pdf";
title 'Distribution of class variable';
proc gchart data=German.credit_1;
vbar y/ percent;
run;
ods pdf close;

/*Getting correlation*/
ods pdf file="C:\Users\chamath\Desktop\SAS\SAS_Projects\German credit\correlation.pdf";
proc corr data=German.credit_1;
var duration rate residence exist_cr amount age;
with duration rate residence exist_cr amount age;
run;
ods pdf close;

/*Modeling (Logistic regression)*/
proc logistic data=German.credit_1;
	class checking history purpose savings employ status debtors property other_plans housing job provide phone foreign;
    model y(event="Good")=checking duration history purpose amount savings employ rate status debtors residence property 
                          age other_plans housing exist_cr job provide phone foreign /selection=stepwise;
    output out=German.preds predprobs=crossvalidate;
run;

proc logistic data=German.preds;
   	class checking history purpose savings employ status debtors property other_plans housing job provide phone foreign;
    model y(event="Good")=checking duration history purpose amount savings employ rate status debtors residence property
					   age other_plans housing exist_cr job provide phone foreign;
    roc 'Crossvalidation' pred=xp_Good;
    roccontrast;
run;

/*Defining probability thresholds for maximum profit*/
data German.preds_1;
set German.preds;
if xp_Good > 0.7 then predicted_response="good";  /*also checked for xp_Good > 0.5 and 0.6*/
else predicted_response="bad";
run;

proc freq data=German.preds_1;
tables y*predicted_response /norow nocol;
run;
