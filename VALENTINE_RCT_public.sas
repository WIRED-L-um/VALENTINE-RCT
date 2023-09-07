
/** ====================================================================================================================== **/
/** ============================================================  RCT Paper    ========================================== **/
/** A Randomized Controlled Trial of a Remotely Delivered Mobile Health Intervention to Augment Cardiac Rehabilitation: == **/
/** The Virtual AppLication-supported ENvironment To INcrease Exercise (VALENTINE) Study  ================================ **/
/** ====================================================================================================================== **/
/** ================================================ Updated Date: Aug 2023 ============================================== **/
/** ====================================================================================================================== **/
/** ======================================================================================================================= **/
/** ===================================== Analytic CSV Data Import for analysis =========================================== **/
/** ======================================================================================================================= **/

/** Daily Step counts **/
PROC IMPORT OUT=COHORT FILE="H:\WIREDL\Dataset_Valentine_R\Data_Daily_Steps.csv";
RUN;
/** ====== 6 minute distance =============== **/
PROC IMPORT OUT=data_6mw FILE="H:\WIREDL\Dataset_Valentine_R\Data_6MW.csv";
RUN;
/** study cohort demographic data **/
PROC IMPORT OUT=STUDY FILE="H:\WIREDL\Dataset_Valentine_R\StudyParticipants 20221017.csv";
RUN;
/** EuroQol VAS **/
PROC IMPORT OUT=survey  FILE="H:\WIREDL\Dataset_Valentine_R\SurveyResults EQ5D 20221031.csv";
RUN;


/** ================================================================================================================= **/
/** Generating Table 1 **/
/** ================================================================================================================= **/

data STUDY;
set STUDY ;
length
race_new $ 40;

if Race in ("Asian", "African American", "Caucasian") then race_new=race;
else Race_new="Other or Unknown"; 

run;

data comm;
 length level $ 150
 ci c1 c2 ctotal $ 40;
 nvar=1; _line=0.5; level="Age of the patient"; output;
 nvar=2; _line=0.5; level='Sex';  output;
 nvar=3; _line=0.5; level="Race";  output;
 nvar=4; _line=0.5; level='Ethnicity';  output;
 nvar=5; _line=0.5; level='Study site';  output;
 nvar=6; _line=0.5; level='Device';  output;
 nvar=7; _line=0.5; level='Indication';  output;
 nvar=8; _line=0.5; level="CAD/MI";  output;
 nvar=9; _line=0.5; level='Heart failure';  output;
 nvar=10; _line=0.5; level="PCI CABG";  output;
 nvar=11; _line=0.5; level="History of valve repair or replacement";  output;

run;  

proc sort data=study;
by cohort;
run;

%Include 'H:\SAS-codes\Table\Table.sas';
%Table(dsn=study,
var =AgeEnrollment_years Gender Race_new
Ethnicity  
CardiacRehabCenter
device
Indication
ComorbidCAD_bool
ComorbidHF_bool
ComorbidPCICABG_bool
ComorbidValve_bool,
type=c d d	d d	d d d d d d,
by=cohort,
labelwrap=y,
outdoc=H:\WIREDL\Dataset_Valentine_R\Table1.rtf,
meandec=2,
 dvar=1 1 1 1 1 2 3 4 5 6 7 8 8  9 9 10  10 11 11,
dline=1 2 4 5 6 1 1 1 1 1 1 1 2  1 2  1 2 1 2,
comments=comm,
ttitle1=Characteristics of patients by cohort type); 


/** ================================================================ **/
/** =========== converting character to numeric ==================== **/
/** ================================================================ **/
/** ============= 6 min walk at baseline =Distance_m_0  ============ **/
/** ============= 6 min walk at 3 months =Distance_m_3  ============ **/
/** =======  6 min walk difference at 6 months =Distance_m_6  ====== **/
/** = 6 min walk difference at 3 months from baseline=Distance_dif3 = **/
/** = 6 min walk difference at 6 months from baseline=Distance_dif6 = **/
/** ================================================================ **/
/** ================================================================ **/

data data_6MW;
set data_6MW;
nDistance_dif3=Distance_dif3+0;
nDistance_dif6=Distance_dif6+0;
nDistance_m_6=Distance_m_6+0   ;
nDistance_m_3=Distance_m_3+0   ; 
run;

/** ========================================================================= **/
/** ============================ Suppliment Table1 ========================== **/
/** ============ ttests of the baseline, 3months, and 6 months outcomes ===== **/
/** ====== stratified by cohort types intervention vs. control ============== **/
/** ========================================================================= **/


ods pdf file="H:\WIREDL\Dataset_Valentine_R\supp_Table1.pdf";


proc ttests data=data_6MW ;
class cohort ; 
var  Distance_m_0 nDistance_m_3 nDistance_m_6;
run;


proc ttests data=COHORT ;
class cohort ; 
var  StepsAgg_0 StepsAgg_3 StepsAgg_6;
run;

ods pdf close;

/** ========================================================================= **/
/** ============================ Suppliment Table2 ========================== **/
/** ========================================================================= **/
/** === summary statistics of the baseline, 3months, and 6 months outcomes == **/
/** ================= stratified by device and cohort types ================= **/
/** ========================================================================= **/

ods pdf file="H:\WIREDL\Dataset_Valentine_R\supp_Table2.pdf";

proc means data=data_6MW  maxdec=1 mean std n nmiss;
class device cohort;
var Distance_m_0 nDistance_m_3 nDistance_m_6;
run;


proc means data=Distance maxdec=1 mean std n nmiss;
class cohort Device; 
var  StepsAgg_6  StepsAgg_3 StepsAgg_0;
run;

ods pdf close;

/** ================================================================================= **/
/** ======================================  Table2 ================================== **/
/** ================================================================================= **/
/** == regression analysis to jointly test the null hypothesis of no effect between = **/
/** == baseline and 3/6-months for 6-minute walk distance and Daily step counts ==== **/
/** ================================================================================= **/



ods pdf file="H:\WIREDL\Dataset_Valentine_R\Table2.pdf";
/** Change in 6-minute walk distance **/

proc glm data=data_6MW;
where Device="Apple Watch";
class Cohort(ref="Control") ;
model  nDistance_dif3= Cohort /solution;
run;

proc glm data=data_6MW;
where Device="Fitbit" ;
class Cohort(ref="Control") ;
model  nDistance_dif3= Cohort /solution;
run;


proc glm data=data_6MW;
where Device="Apple Watch";
class Cohort(ref="Control") ;
model  nDistance_dif6= Cohort /solution;
run;


proc glm data=data_6MW;
where Device="Fitbit";
class Cohort(ref="Control") ;
model  nDistance_dif6= Cohort /solution;
run;


proc glm data=data_6MW;
class Cohort(ref="Control") device;
model  nDistance_dif6= Cohort /solution;
run;
/** ========== Change in daily steps ================ **/

proc glm data=COHORT;
where Device="Fitbit" ;
class Cohort(ref="Control") ;
model  dif3= Cohort /solution;
run;


proc glm data=COHORT;
class Cohort(ref="Control") ;
model  dif3= Cohort /solution;
run;

proc glm data=COHORT;
where Device="Apple Watch"  ;
class Cohort(ref="Control") ;
model  dif3= Cohort /solution;
run;

proc glm data=COHORT;
where Device="Apple Watch"  ;
class Cohort(ref="Control") ;
model  dif6= Cohort /solution;
run;

proc glm data=COHORT;
where Device="Fitbit" ;
class Cohort(ref="Control") ;
model  dif6= Cohort /solution;
run;

proc glm data=COHORT;
class Cohort(ref="Control") ;
model  dif6= Cohort /solution;
run;
ods pdf close;


/** ==================================== sub group analysis ======================================== **/
/** Gathering the estimates for constructing  Supplementary Figure 1: Effects of the Intervention on 
Change in 6-Minute Walk Distance at 6-months for Important Subgroups in Fitbit (Top) and Apple Watch (Bottom) participants. **/
/** ==================================== sub group analysis ======================================== **/

proc glm data=data_6MW;
where Device="Apple Watch" ;
class Cohort(ref="Control") age_cat;
model  nDistance_dif6= cohort*age_cat /solution;
run;


proc glm data=data_6MW;
where Device="Fitbit" ;
class Cohort(ref="Control") ;
model  nDistance_dif6= cohort*age_cat /solution;
run;


proc glm data=data_6MW;
where Device="Apple Watch" ;
class Cohort(ref="Control") Gender;
model  nDistance_dif6= cohort*Gender /solution;
run;

proc glm data=data_6MW;
where Device="Fitbit" ;
class Cohort(ref="Control") Gender;
model  nDistance_dif6= cohort*Gender /solution;
run;

proc glm data=data_6MW;
where Device="Apple Watch" ;
class Cohort(ref="Control") CardiacRehabCenter;
model  nDistance_dif6= cohort*CardiacRehabCenter /solution;
run;


proc glm data=data_6MW;
where Device="Fitbit" ;
class Cohort(ref="Control") CardiacRehabCenter;
model  nDistance_dif6= cohort*CardiacRehabCenter /solution;
run;

proc glm data=data_6MW;
where Device="Apple Watch" ;
class Cohort(ref="Control") ComorbidHF_bool;
model  nDistance_dif6= cohort*ComorbidHF_bool /solution;
run;


proc glm data=data_6MW;
where Device="Fitbit" ;
class Cohort(ref="Control") ComorbidHF_bool;
model  nDistance_dif6= cohort*ComorbidHF_bool /solution;
run;
  


/** =============================================================================== **/
/** ======================    Change in EuroQol VAS     =========================== **/
/** =============================================================================== **/


/** =============================================================================== **/
/** ======== Taking the average score per phase and ScoreCategory ================= **/
/** =============================================================================== **/

proc sql;
create table mdat as select ParticipantIdentifier,phase, mean(score) as score, ScoreCategory
from survey group by ParticipantIdentifier,phase, ScoreCategory;
quit;

/** =============================================================================== **/
/** =========================== Gathering Demographic information ================= **/
/** =============================================================================== **/

proc sql;
create table nsurvey as select 
a.*,b.Cohort,b.device
from mdat as a,
study as b 
	 where a.ParticipantIdentifier=b.ParticipantIdentifier;
quit;

/** summary score for EQ-5D_Health_Scale at baseline and 6 months **/
proc means data=nsurvey maxdec=1;
where ScoreCategory="EQ-5D_Health_Scale";
class  phase;
var score;
run;

/** Saving Data for 6 months **/

data dat6;
set nsurvey;
where phase="6-mo." and ScoreCategory="EQ-5D_Health_Scale";
keep ParticipantIdentifier score cohort device;
run;

data dat6;
set dat6;
score_6=score;
drop score;
run;
/** Saving Data for Baseline **/

data dat0;
set nsurvey;
where phase="0-mo." and ScoreCategory="EQ-5D_Health_Scale";
keep ParticipantIdentifier score cohort device;
run;
/**  Data for Baseline and 6 months in wide format **/

proc sql;
create table survey_diff as select b.*,a.score_6 
from dat6 as a, dat0 as b
where a.ParticipantIdentifier=b.ParticipantIdentifier;
quit;
/**  Difference of the score for 6 months from Baseline **/

data survey_diff;
set survey_diff;
diff=score_6-score;
run;

/** ================================================================================= **/
/** ==============================  Table2 for VAS ================================== **/
/** ================================================================================= **/
/** == regression analysis to jointly test the null hypothesis of no effect between = **/
/** ===================== baseline and 6-months for  EuroQol VAS ==================== **/
/** ================================================================================= **/

ods pdf file="H:\WIREDL\Dataset_Valentine_R\Table2_VAS.pdf";
proc ttests data=survey_diff;
class Cohort;
var diff ;
run;
ods pdf close;


