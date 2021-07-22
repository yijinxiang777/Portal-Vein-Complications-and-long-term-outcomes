/**************Table 1 and table2************/
proc ttest data=full_dem_grf;
var TBIRTHDT_M  ;
class complication;
run;
proc means data=full_dem_grf mean std median q1 q3;
var TBIRTHDT_M  ;
class complication;
run;
proc freq data=full_dem_grf;
table complication REGSEX*complication REGETHNI*complication race*complication diagnosis*complication donor_live*complication
transplant_type*complication/missing  NOROW NOPERCENT;
run;
proc freq data=full_dem_grf;
table race*complication pvc_cat /missing  NOROW NOPERCENT ;
run;
%include "C:\Users\yxian33\OneDrive - Emory University\Projects_Yijin_Xiang\Winship_Macro\UNI_CAT V30.sas";
TITLE 'Table 1 Univariate Association with complication';
%UNI_CAT(dataset = full_dem_grf, 
	outcome = complication, 
	clist = REGSEX REGETHNI race diagnosis TPPDSEX donor_race dornor_eth liver_type abo_match TPPVEINT hepatic_compli donor_live transplant_type, 
	nlist = TBIRTHDT_M donor_age  TPSTWIT cold_ische_time_h, 
	nonpar = F,
	rowpercent = F,
	orientation = portrait,
	outpath = &outpath, 
	fname = Table 1 Univariate Association with complication);
TITLE;
proc means data=full_dem_grf mean std max min;
var TPSTWIT  cold_ische_time_h;
class complication;
run;
proc freq data=full_dem_grf;
table hepatic_compli*complication 
      diagnosis*complication 
      dornor_eth*complication 
      liver_type*complication 
      abo_match*complication
      donor_live*complication/missing NOROW NOPERCENT;
run;
proc freq data=full_dem_grf;
table liver_type abo_match/missing;
run;
proc npar1way data=full_dem_grf wilcoxon;
class complication;
var race diagnosis donor_race;
run;
/**************Table 3************/
proc logistic data=full_dem_grf ;
class  age_cat (ref='1') ;
model complication (event='1')= age_cat ;
contrast  'OR - age 2 vs 1' age_cat 1 0 0/est=exp ;
contrast 'OR - age 3 vs 1' age_cat 0 1 0/est=exp;
contrast 'OR - age 4 vs 1' age_cat 0 0 1/est=exp;
run;
proc logistic data=full_dem_grf ;
class  diagnosis (ref="Biliary atresia") ;
model complication (event='1')= diagnosis ;
contrast  'OR - diagnosis Metabolic vs Biliary atresia' diagnosis  0 0 0 1 0 0  /est=exp ;
contrast  'OR - diagnosis Acute liver failure vs Biliary atresia' diagnosis  1 0 0 0 0 0 /est=exp ;
contrast  'OR - diagnosis Malignancy vs Biliary atresia' diagnosis  0 0 1 0 0 0 /est=exp ;
contrast  'OR - diagnosis Autoimmune/Immune-Mediated vs Biliary atresia' diagnosis  0 1 0 0 0 0 /est=exp ;
contrast  'OR - diagnosis Other cholestatic liver disease vs Biliary atresia' diagnosis  0 0 0 0 0 1 /est=exp ;
contrast  'OR - diagnosis Other vs Biliary atresia' diagnosis  0 0 0 0 1 0 /est=exp ;
run;
proc logistic data=full_dem_grf ;
class  liver_type (ref="Whole            ") ;
model complication (event='1')= liver_type  ;
 contrast  'OR - liver_type Split vs Whole' liver_type 1 0 0 0/est=exp ;
 contrast 'OR - liver_type partial_Deceased vs Whole' liver_type 0 1 0 0/est=exp;
 contrast 'OR - liver_type partial_living vs Whole' liver_type 0 0 1 0/est=exp;
 contrast 'OR - liver_type partial_unknown vs Whole' liver_type 0 0 0 1/est=exp;
run;
proc logistic data=full_dem_grf ;
where liver_type ~="Whole            ";
class  donor_live (ref = "Decease");
model complication (event='1')= donor_live  ;
 contrast 'OR - donor living vs Decease' donor_live 1/est=exp;
run;
proc logistic data=full_dem_grf ;
class  warm_ische_time_cat (ref="1") ;
model complication (event='1')= warm_ische_time_cat  ;
 contrast  'OR - Warm Ischemia Time 1-2 hrs  vs <1 hr' warm_ische_time_cat 1 0 0 /est=exp ;
 contrast 'OR - Warm Ischemia Time 2-3 hrs vs <1 hr' warm_ische_time_cat 0 1 0 /est=exp;
 contrast 'OR - Warm Ischemia Time >3 hrs vs <1 hr' warm_ische_time_cat 0 0 1 /est=exp;
run;
proc logistic data=full_dem_grf ;
class  warm_ische_time_3cat (ref="1") ;
model complication (event='1')= warm_ische_time_3cat  ;
  contrast 'OR - Warm Ischemia Time 1-2 hrs vs <1 hr' warm_ische_time_3cat 1 0/est=exp;
  contrast 'OR - Warm Ischemia Time >3  hrs vs <1 hr' warm_ische_time_3cat 0 1/est=exp;
run;
proc logistic data=full_dem_grf ;
class  cold_ische_time_cat (ref="1") ;
model complication (event='1')= cold_ische_time_cat  ;
 contrast  'OR - cold Ischemia Time 5-10 hrs  vs <5 hr' cold_ische_time_cat 1 0 /est=exp ;
 contrast 'OR - cold Ischemia Time >10 hrs vs <5 hr' cold_ische_time_cat 0 1 /est=exp;
run;
proc logistic data=full_dem_grf ;
class  TPPVEINT (ref="No") ;
model complication (event='1')= TPPVEINT  ;
contrast  'OR - TPPVEINT Yes vs No' TPPVEINT 1/est=exp ;
run;
proc logistic data=full_dem_grf ;
class  hepatic_compli (ref="0") ;
model complication (event='1')= hepatic_compli  ;
contrast  'OR - hepatic_compli Yes vs No' hepatic_compli 1/est=exp ;
run;
proc logistic data=full_dem_grf ;
class age_cat(ref='1')  diagnosis(ref="Biliary atresia")  
      liver_type(ref="Whole            ") warm_ische_time_cat(ref='1')  cold_ische_time_cat(ref='1') 
      TPPVEINT (ref="No")  hepatic_compli(ref="0");
model complication (event='1')= age_cat diagnosis liver_type warm_ische_time_cat cold_ische_time_cat
                                TPPVEINT hepatic_compli;
contrast  'OR - age 2 vs 1' age_cat 1 0 0/est=exp ;
contrast 'OR - age 3 vs 1' age_cat 0 1 0/est=exp;
contrast 'OR - age 4 vs 1' age_cat 0 0 1/est=exp;
contrast  'OR - diagnosis Metabolic vs Biliary atresia' diagnosis  0 0 0 1 0 0  /est=exp ;
contrast  'OR - diagnosis Acute liver failure vs Biliary atresia' diagnosis  1 0 0 0 0 0 /est=exp ;
contrast  'OR - diagnosis Malignancy vs Biliary atresia' diagnosis  0 0 1 0 0 0 /est=exp ;
contrast  'OR - diagnosis Autoimmune/Immune-Mediated vs Biliary atresia' diagnosis  0 1 0 0 0 0 /est=exp ;
contrast  'OR - diagnosis Other cholestatic liver disease vs Biliary atresia' diagnosis  0 0 0 0 0 1 /est=exp ;
contrast  'OR - diagnosis Other vs Biliary atresia' diagnosis  0 0 0 0 1 0 /est=exp ;
 contrast  'OR - liver_type Split vs Whole' liver_type 1 0 0 0/est=exp ;
 contrast 'OR - liver_type partial_Deceased vs Whole' liver_type 0 1 0 0/est=exp;
 contrast 'OR - liver_type partial_living vs Whole' liver_type 0 0 1 0/est=exp;
 contrast 'OR - liver_type partial_unknown vs Whole' liver_type 0 0 0 1/est=exp;
 contrast  'OR - Warm Ischemia Time 1-2 hrs  vs <1 hr' warm_ische_time_cat 1 0 0 /est=exp ;
 contrast 'OR - Warm Ischemia Time 2-3 hrs vs <1 hr' warm_ische_time_cat 0 1 0 /est=exp;
 contrast 'OR - Warm Ischemia Time >3 hrs vs <1 hr' warm_ische_time_cat 0 0 1 /est=exp;
 contrast  'OR - cold Ischemia Time 5-10 hrs  vs <5 hr' cold_ische_time_cat 1 0 /est=exp ;
 contrast 'OR - cold Ischemia Time >10 hrs vs <5 hr' cold_ische_time_cat 0 1 /est=exp;
contrast  'OR - TPPVEINT Yes vs No' TPPVEINT 1/est=exp ;
contrast  'OR - hepatic_compli Yes vs No' hepatic_compli 1/est=exp ;
run;
proc freq data=full_dem_grf;
table age_lt5;
run;
proc logistic data=full_dem_grf ;
class age_lt5(ref='0')  diagnosis_cat(ref="Othe")  
      transplant_type(ref='Whole             ') warm_ische_time_gt3(ref='0')   
      TPPVEINT (ref="No")  hepatic_compli(ref="0");
model complication (event='1')= age_lt5 diagnosis_cat transplant_type warm_ische_time_gt3 
                                TPPVEINT hepatic_compli;
contrast  'OR - age 1 vs 2' age_lt5 1 0/est=exp ;
contrast  'OR - diagnosis BA failure vs Other' diagnosis_cat  1 0 /est=exp ;
 contrast  'OR - liver_type others vs Whole' transplant_type 1 0/est=exp ;
 contrast 'OR - Warm Ischemia Time >3 hrs vs others' warm_ische_time_gt3 1 0 /est=exp;
contrast  'OR - TPPVEINT Yes vs No' TPPVEINT 1/est=exp ;
contrast  'OR - hepatic_compli Yes vs No' hepatic_compli 1/est=exp ;
run;
proc logistic data=full_dem_grf ;
class diagnosis_cat(ref="BA  ")  ;
model complication (event='1')= diagnosis_cat ;
contrast  'OR - diagnosis Other  failure vs BA' diagnosis_cat  1 0 /est=exp ;
run;
proc logistic data=full_dem_grf ;
class  transplant_type (ref="Whole            ") ;
model complication (event='1')= transplant_type  ;
 contrast  'OR - liver_type others vs Whole' transplant_type 1 0/est=exp ;
run;
proc logistic data=full_dem_grf ;
class age_cat(ref='1')  diagnosis_cat(ref="BA  ")  
      transplant_type (ref="Whole            ") warm_ische_time_cat(ref='1')  cold_ische_time_cat(ref='1') 
      TPPVEINT (ref="No")  hepatic_compli(ref="0");
model complication (event='1')= age_cat diagnosis_cat transplant_type warm_ische_time_cat cold_ische_time_cat
                                TPPVEINT hepatic_compli;
contrast  'OR - age 2 vs 1' age_cat 1 0 0/est=exp ;
contrast 'OR - age 3 vs 1' age_cat 0 1 0/est=exp;
contrast 'OR - age 4 vs 1' age_cat 0 0 1/est=exp;
contrast  'OR - diagnosis Other  failure vs BA' diagnosis_cat  1 0 /est=exp ;
contrast  'OR - liver_type others vs Whole' transplant_type 1 0/est=exp ;
contrast  'OR - Warm Ischemia Time 1-2 hrs  vs <1 hr' warm_ische_time_cat 1 0 0 /est=exp ;
 contrast 'OR - Warm Ischemia Time 2-3 hrs vs <1 hr' warm_ische_time_cat 0 1 0 /est=exp;
 contrast 'OR - Warm Ischemia Time >3 hrs vs <1 hr' warm_ische_time_cat 0 0 1 /est=exp;
 contrast  'OR - cold Ischemia Time 5-10 hrs  vs <5 hr' cold_ische_time_cat 1 0 /est=exp ;
 contrast 'OR - cold Ischemia Time >10 hrs vs <5 hr' cold_ische_time_cat 0 1 /est=exp;
contrast  'OR - TPPVEINT Yes vs No' TPPVEINT 1/est=exp ;
contrast  'OR - hepatic_compli Yes vs No' hepatic_compli 1/est=exp ;
run;
proc freq data=full_dem_grf;
table cold_ische_time_cat*warm_ische_time_cat;
run;
/*************************************/
/*Cox proportional hazard*/
*******************************************************************;
*test for proportional hazard;
*g(t)=t;
/*proc phreg data=full_dem_grf;*/
/*model fu_time_grf * graft_failure(0)= complication complication_t;*/
/*complication_t=complication * fu_time_grf;*/
/*run;*/
/**g(t)=ln(t);*/
/*proc phreg data=full_dem_grf;*/
/*model fu_time_grf * graft_failure(0)= complication complication_logt;*/
/*complication_logt=complication * log(fu_time_grf);*/
/*run;*/
/**GOF test;*/
/*proc phreg data=full_dem_grf;*/
/*model fu_time_grf * graft_failure(0)= complication;*/
/*output out=residual ressch=sh_tx;*/
/*run;*/
/**/
/*data failure;*/
/*     set residual;*/
/*	 where graft_failure=1;*/
/*run;*/
/**/
/*proc rank data=failure out=rank ties=mean;*/
/*     var fu_time_grf;*/
/*	 ranks timerank;*/
/*run;*/
/*proc corr data=rank nosimple;*/
/*     with timerank;*/
/*	 var sh_tx;*/
/*run;*/
*******************************************************************;
**********************************************************************;
Proc lifetest data=full_dem_grf method=km plots=lls;
time fu_time_grf_yrs * graft_failure(0);
strata complication;
run;
proc phreg data=full_dem_grf;
class complication (ref='0')/param=ref;
model fu_time_grf_yrs * graft_failure(0)= complication / ties=efron rl;
*contrast "Complication vs. no" complication 1/estimate=exp;
run;
proc phreg data=full_dem_grf;
class complication (ref='0')TPPDSEX aa_cat bilirubin_cat diagnosis transplant_type hepatic_compli TPPVEINT /param=ref;
model fu_time_grf_yrs * graft_failure(0)= complication aa_cat TPPDSEX TBIRTHDT_M bilirubin_cat diagnosis transplant_type cold_ische_time_h
                                TPPVEINT hepatic_compli  / ties=efron rl;
*contrast "Complication vs. no" complication 1/estimate=exp;
run;

proc phreg data=full_dem_grf;
class complication (ref='0') aa_cat(ref='0') /param=ref;
model fu_time_grf * graft_failure(0)=  complication aa_cat complication*aa_cat;
contrast "AA" complication 1 complication*aa_cat 1 /estimate=exp;
contrast "non-AA" complication 1  /estimate=exp;
run;
proc phreg data=full_dem_grf;
class complication (ref='0') aa_cat(ref='0')TPPDSEX bilirubin_cat diagnosis transplant_type hepatic_compli TPPVEINT/param=ref;
model fu_time_grf * graft_failure(0)=  complication aa_cat  complication*aa_cat  TPPDSEX TBIRTHDT_M bilirubin_cat diagnosis transplant_type cold_ische_time_h
                                TPPVEINT hepatic_compli ;
contrast "AA" complication 1 complication*aa_cat 1 /estimate=exp;
contrast "non-AA" complication 1  /estimate=exp;
run;
Proc lifetest data=full_dem_grf method=km plots=lls;
time fu_time_grf * graft_failure(0);
strata aa_cat complication;
run;
proc phreg data=full_dem_grf;
class complication (ref='0') hepatic_compli(ref='0')/param=ref;
model fu_time_grf * graft_failure(0)=  complication   hepatic_compli complication*hepatic_compli;
contrast "hat" complication 1 hepatic_compli*complication 1 /estimate=exp;
contrast "non-hat" complication 1  /estimate=exp;
run;
proc phreg data=full_dem_grf;
class complication (ref='0') hepatic_compli(ref='0')TPPDSEX bilirubin_cat diagnosis transplant_type hepatic_compli TPPVEINT/param=ref;
model fu_time_grf * graft_failure(0)=  complication aa_cat  complication*hepatic_compli  TPPDSEX TBIRTHDT_M bilirubin_cat diagnosis transplant_type cold_ische_time_h
                                TPPVEINT hepatic_compli ;
contrast "hat" complication 1 hepatic_compli*complication 1 /estimate=exp;
contrast "non-hat" complication 1  /estimate=exp;
run;
*****************************************************************************;
/*Death - Cox PH model*/
proc phreg data=full_dem_dt;
class complication(ref='0') hepa_complication aa_cat TPPDSEX bilirubin_cat diagnosis transplant_type TPPVEINT;
model fu_time_dt_yrs * death(0)= complication hepa_complication aa_cat TPPDSEX TBIRTHDT_M bilirubin_cat diagnosis transplant_type cold_ische_time_h
                                TPPVEINT/ ties=efron rl;
contrast "Complication vs. no" complication 1/estimate=exp;
run;
proc phreg data=full_dem_grf;
class complication (ref='0')TPPDSEX aa_cat bilirubin_cat diagnosis transplant_type hepatic_compli TPPVEINT /param=ref;
model fu_time_grf_yrs * graft_failure(0)= complication aa_cat TPPDSEX TBIRTHDT_M bilirubin_cat diagnosis transplant_type cold_ische_time_h
                                TPPVEINT hepatic_compli  / ties=efron rl;
*contrast "Complication vs. no" complication 1/estimate=exp;
run;
proc phreg data=full_dem_dt;
class aa_cat;
model fu_time_dt * death(0)=  complication  hepa_complication aa_cat complication*aa_cat;
contrast "complication/AA" complication 1 complication*aa_cat 1 /estimate=exp;
contrast "complication/NONAA" complication 1 complication*aa_cat 0 /estimate=exp;
run;
proc phreg data=full_dem_dt;
model fu_time_dt * death(0)=  complication  aa_cat complication*aa_cat;
contrast "complication/AA" complication 1 complication*aa_cat 1 /estimate=exp;
contrast "complication/NONAA" complication 1 complication*aa_cat 0 /estimate=exp;
run;
