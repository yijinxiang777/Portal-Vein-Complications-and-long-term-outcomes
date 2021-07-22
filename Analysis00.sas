libname trans "C:\Users\yxian33\OneDrive - Emory University\Projects_Yijin_Xiang\From_Tracy\transplant\In_data";
libname library "C:\Users\yxian33\OneDrive - Emory University\Projects_Yijin_Xiang\From_Tracy\transplant\In_data";
%let outpath = C:\Users\yxian33\OneDrive - Emory University\Projects_Yijin_Xiang\From_Tracy\transplant\Output;

proc format;
value race 1 = 'Native Alaskan/Amer Ind'
           2 = 'Asian'
		   3 = 'Black/AfricanAmerican'
		   4 = 'Native Hawaii/Pacific Isl'
		   5 = 'White'
		   6 = 'Other race'
		   7 = 'Mixed Race';
value $reop "1" = 'Reoperation';
value $anti "1" = 'Anticoagulation';
value $radi "1" = 'Interventional radiology';
value $obs  "1" = 'Observation';
value diagnosis 1 = "Acute liver failure"
                2 = "Biliary atresia"
                3 = "Other cholestatic liver disease"
                4 = "Metabolic"
                5 = "Malignancy"
                6 = "Autoimmune/Immune-Mediated"
                7 = "Other";
run;

********************************************************************
* Create a modified demographic dataset (add age, race, whether aa or non-aa)
*********************;
data trans.dem_rc;
     set trans.dem;
     TBIRTHDT_M = round(TBIRTHDT*-12/365.25,2);
     array race_ary{7} REGNATIV REGASIAN REGBLACK REGHAWII REGWHITE REGOTH REGMULT;
     race_count = 0;
     do i = 1 to 7;
       if race_ary{i} = "1" then do;
          race_count = race_count + 1;
	      race = i;
	   end;
     end;
     if missing(race) then race = .;
     if race_count > 1 then do;
        race = 7;
        race_multi = 1;
     end;
     else race_multi = .;
	 format race race.;
	 if race in (1,2,4,5,6,7) then aa_cat = 0;
	 else if race = 3 then aa_cat = 1;
	 else aa_cat = .;
     do i = 1 to 7;
	    if race = 7 and race_ary{i} = "1" then 
	    race_multi = CAT(race_multi,i);
	 end;
	 if REGETHNI = "3" then REGETHNI = ""; 
run;
*Check the recoding;
proc freq data= trans.dem_rc;
table REGETHNI race_multi race race*REGNATIV race*REGASIAN race*REGBLACK race*REGHAWII race*REGWHITE race*REGOTH race*REGMULT;
run;

****************************************************************************************
*Preprare two datasets to create variable stands for pvc, pvs and long_term short_term ;

proc contents data= trans.ltfupage2;
run;
proc freq data=trans.ltfupage2;
table LTFVCPVT LTFVCPVS;
run;
proc sort data= trans.ltfupage2;
by PROJID ATDATE;
run;
 
data long_term_pre;
    set trans.ltfupage2;
	if PROTSEG = "A";
run;    
data long_term;
    set long_term_pre;
	by PROJID;
	retain pvt_lt_count pvs_lt_count hvt_lt_count hat_lt_count fu_time_lt FVC;
    if first.PROJID then do pvt_lt_count =0; pvs_lt_count =0;FVC=LTFVC;
                            fu_time_lt=ATDATE;hvt_lt_count=0;hat_lt_count=0; end;
	if ATDATE = . then fu_time_lt = fu_time_lt;
	else fu_time_lt = ATDATE;
	if missing(LTFVC) then FVC =FVC;
	else FVC=LTFVC;
	if LTFVCPVT ="1" then do; pvc_lt = 1; pvt_lt_count=pvt_lt_count+1; pvt_lt = 1; 
					   end;
    if LTFVCPVS ="1" then do; pvc_lt = 1;  pvs_lt_count=pvs_lt_count+1;  pvs_lt = 1;
					   end; 
/*	if LTFVCHVT = "1" then do; hvt_lt_count =1; end;*/
    if LTFVCHAT = "1" then do; hat_lt_count =1; end;
    if last.projid and pvt_lt_count > 0 and pvs_lt_count >0 then pvc_lt_type = "both";
	else if last.projid and pvs_lt_count > 0 then pvc_lt_type ="pvs";
	else if last.projid and pvt_lt_count > 0 then pvc_lt_type ="pvt";
    if last.projid and hat_lt_count >0 then hepatic_lt_compli = 1;
	else hepatic_lt_compli = 0;
	keep PROJID FVC ATDATE fu_time_lt pvc_lt_type pvc_lt pvt_lt  pvs_lt 
	     pvt_lt_count pvs_lt_count pvc_lt_type hepatic_lt_compli ;
run;
proc print data=long_term;
where  missing(fu_time_lt);
run;
proc freq data=long_term;
table FVC*pvt_lt_count FVC*pvs_lt_count/missing;
run;
data long_term_last;
set long_term;
by PROJID;
if last.projid;
/*if not missing(FVC) or not missing(pvc_lt_type);*/
FVC_l = FVC;
keep PROJID pvc_lt_type hepatic_lt_compli fu_time_lt FVC_l;
run;
proc freq data= long_term_last;
table  pvc_lt_type hepatic_lt_compli;
run;
*check the recoding of the variable;
proc freq data= long_term;
table  pvt_lt pvs_lt pvc_lt;
run;
*Create follow-up time;
/*proc sql;*/
/*create table pvc_lt_list as*/
/*select projid,VISNO,pvt_lt,pvt_time_lt, pvs_lt,pvs_time_lt from long_term where pvc_lt =1;*/
/*quit;*/
/*proc sort data= pvc_lt_list;*/
/*by projid,VISNO;*/
/*run;*/
/*data pvc_lt_list_clean;*/
/*    set pvc_lt_list;*/
/*	by projid;*/
/*	if first.projid then fu_time = min (pvt_time_lt,pvs_time_lt);*/
/*run;*/
/**/
/*proc transpose data=pvc_lt_list  out= pvc_lt_list_w prefix=pvc;*/
/*   by projid VISNO;*/
/*   var pvt_lt pvt_time_lt pvs_lt pvs_time_lt ;*/
/*  run;*/
/*proc sql;*/
/*select  projid PROTSEG VISNO ATDATE pvc_lt pvt_lt pvt_time_lt pvt_anti_lt pvt_repo_lt pvt_radi_lt pvt_obs_lt pvs_lt pvs_time_lt*/
/*	pvs_anti_lt pvs_repo_lt pvs_radi_lt pvs_obs_lt from long_term where projid IN (select distinct patientid from list_id);*/
/*group by projid;*/

*****************************************************************************;
*Preprare two datasets to create variable stands for pvc, pvs and short_term ;
proc contents data= trans.efupage1;
run;
proc freq data=trans.efupage1;
table TPFVCPVT TPFVCPVS;
run;
proc sort data= trans.efupage1;
by PROJID FASDTTP;
run;

data short_term_pre;
    set trans.efupage1;
	if PROTSEG = "A";
run;

data short_term;
    set short_term_pre;
	retain pvt_st_count pvs_st_count hvt_st_count hat_st_count fu_time_st FVC;
	by PROJID;
    if first.PROJID then do pvt_st_count =0; pvs_st_count =0; fu_time_st=FASDTTP; 
                            hvt_st_count=0;hat_st_count=0;FVC = TPFVC30; end;
    if FASDTTP = . then fu_time_st = fu_time_st;
	else fu_time_st = FASDTTP;
	if TPFVC30 = . then FVC =FVC;
	else FVC = TPFVC30;
    if TPFVCPVT ="1" then do; pvc_st = 1; pvt_st_count=pvt_st_count+1; pvt_st = 1; 
					   end;
    if TPFVCPVS ="1" then do; pvc_st = 1; pvs_st_count=pvs_st_count+1; pvs_st = 1; 
					   end;
/*    if TPFVCHVT = "1" then do; hvt_st_count =1; end;*/
    if TPFVCHAT = "1" then do; hat_st_count =1; end;
	if last.projid and pvt_st_count > 0 and pvs_st_count >0 then pvc_st_type = "both";
	else if last.projid and pvs_st_count > 0 then pvc_st_type ="pvs";
	else if last.projid and pvt_st_count > 0 then pvc_st_type ="pvt";
    if last.projid and  hat_st_count >0 then hepatic_st_compli = 1;
	else hepatic_st_compli = 0;
	keep PROJID FVC FASDTTP fu_time_st pvc_st pvt_st  pvs_st 
	pvt_st_count pvs_st_count pvc_st_type hepatic_st_compli;
run;
proc print data=short_term;
where  missing(fu_time_st);
run;
data short_term_last ;
set short_term;
by PROJID;
if last.projid;
FVC_s = FVC;
/*if not missing(FVC) or not missing(pvc_st_type);*/
keep PROJID pvc_st_type fu_time_st  hepatic_st_compli FVC_s;
run;
proc freq data= short_term_last;
table  pvc_st_type hepatic_st_compli;
run;
proc freq data= short_term;
table  pvt_st pvs_st pvc_st;
run;
**************************************************************************;
******Prepare dataset for transplant information**************************;
data tpp_two;
merge full_dem_grf(keep=PROJID PROTSEG TPPPROCT TPSDNRTY in=a) tpp_rc (keep=PROJID PROTSEG proc_type donor_type);
by PROJID PROTSEG;
if a;
run;
proc freq data=tpp_two;
table TPPPROCT*proc_type  TPSDNRTY*donor_type/nopercent nocol norow missing;
run;
data tpp;
  merge trans.tpp(keep=PROJID TPPGFTFL PROTSEG TPPPELDA TPPMELDA  REGPRDIS TPPDAGEY
TPPDAGEM TPPDSEX TPPDETHN TPPDONRC TPPDNAT TPPDASIA TPPDBLK TPPDHISP TPPDHAWI TPPDWHIT TPPDMLTR
TPSDNRTY TPPPROCT TPPDBTYP REGBLOOD TPPDTEST TPPSRCRE TPPTOBIL TPPINR TPPALB ELSTDTTP TPSTWIT TPSTCITH TPPTCITM TPPVEINT) trans.dem_rc(keep=PROJID TBIRTHDT_M REGSEX);
   by PROJID;
   if PROTSEG = "A";
   *Donor age;
   donor_age = max(TPPDAGEY*12, TPPDAGEM);
   *Primary diagnosis;
   if first(cats(REGPRDIS))='2' then diagnosis = 1;
   else if index( REGPRDIS, '101') >0 then  diagnosis = 2;
   else if REGPRDIS in ("102",'107') then diagnosis = 3;
   else if REGPRDIS in ('110', '313', '603', '604', '701','702','704','999') then diagnosis =7;
   else if REGPRDIS in ("108",'605') then diagnosis = 6;
   else if first(cats(REGPRDIS))='4' then diagnosis = 5;
   else if first(cats(REGPRDIS))='3' or REGPRDIS in ('111','112','113','888')then diagnosis = 4; 
   else diagnosis =.; 
   if diagnosis =2 then diagnosis_cat="BA  ";
   else if diagnosis in (1,3,4,5,6,7) then diagnosis_cat="Other";
   else diagnosis_cat ="    ";
   *donor's Race;
        array race_ary{7} TPPDNAT TPPDASIA TPPDBLK TPPDHAWI TPPDWHIT TPPDONRC TPPDMLTR;
     do i = 1 to 7;
       if race_ary{i} in ("1", "99") then donor_race = i;
     end;
	 rename TPPDHISP= dornor_eth;
	 drop i TPPDNAT TPPDASIA TPPDBLK TPPDHAWI TPPDWHIT TPPDONRC TPPDMLTR;
	 format donor_race race.; 
   *abo macthing;
   if TPPDBTYP=REGBLOOD and REGBLOOD~="" then abo_match = "Indentical  ";else
   if TPPDBTYP~=REGBLOOD and not missing(REGBLOOD) and not missing(TPPDBTYP) then abo_match="Incompatible"; 
   else abo_match ="      ";
   *liver type;
   *TPPPROCT 1=Whole liver, 2=Partial liver, remainder not transplanted or living transplant, 3=Split liver, 9=Unknown;
   *TPSDNRTY 1=Deceased- Brain Death, 2=Deceased- Donation after Cardiac Death (DCD), 3=Living, 9=Unknown;
   if TPPPROCT = "1" then liver_type = "Whole            "; else 
   if TPPPROCT = "3" then liver_type = "Split            "; else 
   if TPPPROCT = "2" and TPSDNRTY in ("1","2","3") then liver_type ="partial_Deceased"; else
   if TPPPROCT = "2" and TPSDNRTY in ("4") then liver_type ="partial_living"; else 
   if TPPPROCT = "2"  then liver_type ="partial_unknown"; else
   liver_type ="    ";
   if TPPPROCT = "1" then transplant_type = "Whole             ";
   else if TPPPROCT in ("2" "3") then transplant_type = "split/reduced/live";
   if TPSDNRTY in ("4") then donor_live = "Living ";
   else if TPSDNRTY in ("1","3","2") then donor_live ="Deceased";
   *MELD Score calculation;
   *MELD Score = 0.957 x Loge(creatinine mg/dL)
                  + 0.378 x Loge(bilirubin mg/dL)
                  + 1.120 x Loge(INR) + 0.6431;
   if TBIRTHDT_M >= 144 then do;
     if TPPSRCRE = 0 then creatinine =.;
     else if 0 < TPPSRCRE < 1 then creatinine = 1;
	 else if TPPSRCRE > 4 or TPPDTEST = "1" then creatinine = 4;
     else creatinine = TPPSRCRE;
	 if TPPTOBIL = 0 or TPPTOBIL >10 then bilirubin =.;
	 else if 0 < TPPTOBIL < 1 then bilirubin = 1;
     else bilirubin = TPPTOBIL;
	 if TPPINR = 0 then TPPINR = .;
     meld_cal = round(10*(0.957 * log(creatinine) + 0.378 * log(bilirubin)
                + 1.12 * log(TPPINR) + 0.6431),1);
     end;
   *PELD Score calculation;
   *PELD Score = 0.480 x Loge(bilirubin mg/dL) bilirubin
                 + 1.857 x Loge(INR) TPPINR
                 - 0.687 x Loge(albumin g/dL) TPPALB
                 + 0.436 if the patient is less than 1 year old (scores for patients listed for liver
transplantation before the patient’s first birthday continue to include the value assigned
for age (< 1 Year) until the patient reached the age of 24 months)
                /// + 0.667 if the patient has growth failure (<-2 Standard deviation)//;
     if TBIRTHDT_M < 144 then do;
     if TPPALB = 0 or TPPALB >10 then albumin =.;
     else if 0 < TPPALB < 1 then albumin = 1;
     else albumin = TPPALB;
	 if TPPTOBIL = 0 or TPPTOBIL >10 then bilirubin =.;
     else if 0 < TPPTOBIL < 1 then bilirubin = 1;
     else bilirubin = TPPTOBIL;
	 if 0 < TBIRTHDT_M < 12 or (TBIRTHDT_M < 24 and (TBIRTHDT_M*30 + ELSTDTTP)< 365.25)
 then age_ind = 1;
	 else if TBIRTHDT_M =. then age_ind = .;
	 else age_ind = 0;
	 if TPPINR = 0 then TPPINR = .;
     peld_cal = round(10*(0.480 * log(bilirubin) +
                + 1.857 * log(TPPINR) - 0.687 * log(albumin) + 0.436 * age_ind),1);
	 if peld_cal <-10 then peld_cal=.;
     end;
     /*Create bilirubin for control*/
	 if 0<bilirubin <2 then bilirubin_cat = "<2 ";
	 else if 2<=bilirubin =<6 then bilirubin_cat = "2-6";
	 else if 6<bilirubin then bilirubin_cat = ">6";
     format diagnosis diagnosis.;
run;
proc print data =tpp;
where peld_cal <-10 and peld_cal ~=.;
var meld_cal TBIRTHDT_M TPPALB albumin peld_cal TPPTOBIL bilirubin peld_cal TPPINR;
run;
proc means data =tpp mean std q1 median q3 min max;
var TPSTWIT TPSTCITH TPPTCITM;
run;
proc freq data = tpp;
table diagnosis_cat REGPRDIS*diagnosis liver_type*TPPPROCT liver_type*TPSDNRTY/missing;
run;
proc freq data = tpp;
table diagnosis REGPRDIS abo_match liver_type bilirubin_cat transplant_type/missing;
run;
proc freq data=tpp;
table donor_live*TPSDNRTY/missing;
run;
proc sql;
select count(*), PROJID from tpp
group by PROJID
having count(*) >1;
proc freq data =tpp;
table graft_failure ;
run;
proc sort data =trans.ecsplitb;
by PROJID;
RUN;
**********************************************************************;
*create a dataset for graft_failure;
data full_dem_grf exclude;
merge trans.dem_rc(in = a)  short_term_last(in=d) long_term_last(in=e) trans.dth(in=b keep=PROJID DTHWAIT TDTHDATE RTEGFPRI DTHWAIT) 
trans.ecsplitb (in = c keep=PROJID TSTARTDT2) tpp(in=f) ;
by PROJID;

*complications;
if (pvc_lt_type = "both") or (pvc_st_type = "both") or 
(pvc_st_type="pvs" and pvc_lt_type="pvt") or (pvc_st_type="pvt" and pvc_lt_type="pvs") then do; pvc = "both         "; pvc_cat = "both";complication =1;end;
else if pvc_st_type = pvc_lt_type and pvc_st_type ~= "" then do; pvc = cats(pvc_st_type,"_stlt"); pvc_cat = cats(pvc_st_type);complication =1;;end;
else if pvc_st_type ~= "" then do; pvc = cats(pvc_st_type,"_st"); pvc_cat = cats(pvc_st_type);complication =1;end;
else if pvc_lt_type ~= "" then do; pvc = cats(pvc_lt_type,"_lt"); pvc_cat = cats(pvc_lt_type);complication =1;end;
else do; pvc="None"; pvc_cat ="None";complication =0;end;
if hepatic_st_compli = 1 or hepatic_lt_compli =1 then hepatic_compli =1;
else hepatic_compli =0;
/*Create variables for table 3*/
/*1-5 yrs    1*/
/*6-10 yrs   2*/
/*11-18 yrs  3*/

if TBIRTHDT_M <=12 then age_cat = 1;
else if TBIRTHDT_M <=60 then age_cat = 2;
else if TBIRTHDT_M <=120 then age_cat = 3;
else age_cat=4;
/*Age -  two catgories*/
if age_cat = 1 then age_lt5 = 1;
else  age_lt5 = 0;
/*Create variable efor ischemia time for table 3*/
if not missing(TPSTWIT) and  TPSTWIT <=60 then do;warm_ische_time_cat = 1;
												  warm_ische_time_3cat =1;
                                                  warm_ische_time_gt3=0;end; else
if 60< TPSTWIT <=120 then do; warm_ische_time_cat = 2;
                              warm_ische_time_3cat =2;
                              warm_ische_time_gt3=0;end; else
if 120< TPSTWIT <=180 then do; warm_ische_time_cat = 3;
                               warm_ische_time_3cat =2;
                               warm_ische_time_gt3=0;end; else
if 180< TPSTWIT  then do; warm_ische_time_cat = 4; 
                          warm_ische_time_gt3=1;
                          warm_ische_time_3cat =3;end;
cold_ische_time = TPSTCITH*60 + TPPTCITM;
cold_ische_time_h = TPSTCITH + (TPPTCITM/60);
if not missing(cold_ische_time) and  cold_ische_time <=300 then cold_ische_time_cat = 1; else
if 300< cold_ische_time <=600 then cold_ische_time_cat = 2; else
if 600< cold_ische_time  then cold_ische_time_cat = 3; 
*Graft failure and censor;
*must had graft failure if they had a second transplant;
if c then do ;graft_failure=1;fu_time_grf = Tstartdt2; end;
*doesn't have a transplant but die of graft failure;
else if b and (RTEGFPRI~="" or DTHWAIT ="1") then do;death=1;graft_failure=1;fu_time_grf = TDTHDATE; end;
else do; graft_failure = 0; fu_time_grf = max(fu_time_st,fu_time_lt); end;

if c then do; retransplant = 1;fu_time_retrans = Tstartdt2;end;
else do;retransplant = 0; fu_time_retrans = max(fu_time_st,fu_time_lt); end;
if not d and not e and graft_failure=1  then exclude_reason = "No PVC info w/ outcome  ";else
if not d and not e then exclude_reason = "No PVC info w/o outcome " ;
fu_time_grf_yrs =fu_time_grf/365.25;
fu_time_retrans_yrs = fu_time_retrans/365.25;
if max(fvc_l,fvc_s)ge 0 or not missing(pvc_lt_type) or not missing(pvc_st_type) then output full_dem_grf ;else output exclude;
run;
**************Output the dataset for plot*************;
proc export 
  data=full_dem_grf 
  dbms=xlsx 
  outfile="C:\Users\yxian33\OneDrive - Emory University\Projects_Yijin_Xiang\From_Tracy\transplant\full_dem_grf_0524.xlsx" 
  replace;
run;
/******************************************/

**********************************************************************;
*Death;
data death_time;
set trans.efupage1(keep = PROJID PROTSEG FASDTTP TPFVCPVT TPFVCPVS TPFPVTAC TPFPVTRO TPFPVTIR TPFPVTOB TPFPVSAC
                          TPFPVSRO TPFPVSIR TPFPVSOB TPFVCHVT TPFVCHAT TPFVC30)  
     trans.ltfupage2 (keep = PROJID PROTSEG ATDATE LTFVCPVT LTFVCPVS LTFPVTAN LTFPVTRE LTFPVTIR LTFPVTOB LTFPVSAN
                             LTFPVSRE LTFPVSIR LTFPVSOB LTFVCHVT LTFVCHAT LTFVC);
if FASDTTP ~=. then fu_time = FASDTTP;
else fu_time = ATDATE;
drop FASDTTP ATDATE;
run;

proc sort data=death_time;
by PROJID PROTSEG;
run;
*record whether they had the complication across the entire follow-up period;
proc sql;
create table death_fu_time as
select PROJID, max(fu_time) as fu_time, 
max(TPFVCPVT)as pvt_st, max(TPFVCPVS)as pvs_st,
max(LTFVCPVT)as pvt_lt, max(LTFVCPVS)as pvs_lt,
max(TPFVCHVT)as hvt_st, max(TPFVCHAT) as hat_st,
max(LTFVCHVT)as hvt_lt, max(LTFVCHAT) as hat_lt,
max(TPFPVTAC)as pvt_st_anti, max(TPFPVTRO)as pvt_st_reop,
max(TPFPVTIR)as pvt_st_radi, max(TPFPVTOB)as pvt_st_obs,
max(TPFPVSAC)as pvs_st_anti, max(TPFPVSRO)as pvs_st_reop,
max(TPFPVSIR)as pvs_st_radi, max(TPFPVSOB)as pvs_st_obs,
max(LTFPVTAN)as pvt_lt_anti, max(LTFPVTRE)as pvt_lt_reop,
max(LTFPVTIR)as pvt_lt_radi, max(LTFPVTOB)as pvt_lt_obs,
max(LTFPVSAN)as pvs_lt_anti, max(LTFPVSRE)as pvs_lt_reop,
max(LTFPVSIR)as pvs_lt_radi, max(LTFPVSOB)as pvs_lt_obs,
max(LTFVC) as pvc_lt, max(TPFVC30) as pvc_st,
max(case when PROTSEG ="A" then TPFVCPVT END) as pvt_st_a,
max(case when PROTSEG ="A" then TPFVCPVS END) as pvs_st_a,
max(case when PROTSEG ="A" then LTFVCPVT END) as pvt_lt_a,
max(case when PROTSEG ="A" then LTFVCPVS END) as pvs_lt_a,
max(case when PROTSEG ="A" then LTFVC END) as pvc_lt_a,
max(case when PROTSEG ="A" then TPFVC30 END) as pvc_st_a
from death_time
group by PROJID;
quit;
proc freq data = death_fu_time;
table pvt_st*pvt_lt pvs_st*pvs_lt/missing;
run;
proc means data=death_fu_time n nmiss;
var fu_time;
run;
*****************************************************************;
/*Table 4 -  Intervention for PVC*/
Data table4;
    set death_fu_time;
pvt = max(pvt_st,pvt_lt);
pvs = max(pvs_st,pvs_lt);
pvt_st_m =max(pvt_st);
pvt_lt_m =max(pvt_lt);
pvs_st_m =max(pvs_st);
pvs_lt_m =max(pvs_lt);
pvt_a = max(pvt_st_a,pvt_lt_a);
pvs_a = max(pvs_st_a,pvs_lt_a);
pvt_anti = max(pvt_st_anti,pvt_lt_anti);
pvs_anti = max(pvs_st_anti,pvs_lt_anti);
pvt_reop = max(pvt_st_reop,pvt_lt_reop);
pvs_reop = max(pvs_st_reop,pvs_lt_reop);
pvt_radi = max(pvt_st_radi,pvt_lt_radi);
pvs_radi = max(pvs_st_radi,pvs_lt_radi);
pvt_obs = max(pvt_st_obs,pvt_lt_obs);
pvs_obs = max(pvs_st_obs,pvs_lt_obs);
if not missing(pvt_a) or not missing(pvs_a) or not missing(pvc_lt_a) or not missing(pvc_st_a);
keep PROJID pvt pvs  pvt_a pvs_a pvt_anti pvs_anti pvt_reop pvs_reop pvt_radi pvs_radi pvt_obs pvs_obs
     pvt_st_m pvt_lt_m pvs_st_m pvs_lt_m;
run;

proc freq data = table4;
table pvs*pvt pvs pvt pvt_st_m*pvt_lt_m pvs_st_m*pvs_lt_m
      pvt*pvt_anti*pvt_reop*pvt_radi*pvt_obs pvs*pvs_anti*pvs_reop*pvs_radi*pvs_obs/ list missing;
run;
*record whether they had complications in the each time of transplant;
proc sql;
create table death_fu_time_by_group as
select PROJID, PROTSEG,
max(TPFVCPVT)as pvt_st,max(TPFVCPVS)as pvs_st,
max(LTFVCPVT)as pvt_lt, max(LTFVCPVS)as pvs_lt,
max(LTFVC) as pvc_lt, max(TPFVC30) as pvc_st
from death_time
group by PROJID,PROTSEG;
quit;

*****************************************************************;
/*Merge all transplant dataset*/
DATA full_A (rename=(pvc=pvc_a pvt=pvt_a pvs=pvs_a pvs_vt = pvs_vt_a)) 
     full_b (rename=(pvc=pvc_b pvt=pvt_b pvs=pvs_b pvs_vt = pvs_vt_b))
     full_c (rename=(pvc=pvc_c pvt=pvt_c pvs=pvs_c pvs_vt = pvs_vt_c))
     full_d (rename=(pvc=pvc_d pvt=pvt_d pvs=pvs_d pvs_vt = pvs_vt_d));
set death_fu_time_by_group;
pvt = max(pvt_st,pvt_lt);
pvs = max(pvs_st,pvs_lt);
pvc = max(pvc_lt,pvc_st);
/*if pvt = pst and pst =1 then pvc_both=1;*/
/*if pvc_both = 1 then pvc =3;*/
/*else if pst = 1 then pvc =2;*/
/*else if pvt = 1 then pvc = 1; */
if pvs = 1 or pvt =1 then pvs_vt=1;
else if pvc =. then pvs_vt =.;
else pvs_vt=0;
/*Recode the 11670 to pst_vt = 0 due to missing pvc for long time*/
/*if PROTSEG = "A" and PROJID = "11670" then pst_vt = 0;*/
if PROTSEG ="A" and pvs_vt~=. then output full_a;
if PROTSEG ="B" and pvs_vt~=. then output full_b;
if PROTSEG ="C" and pvs_vt~=. then output full_c;
if PROTSEG ="D" and pvs_vt~=. then output full_d;
keep PROJID pvc pvt pvs pvs_vt;
run;

proc freq data=full_a;
table pvs_vt_a ;
run;
*****************************************************************;
/*dataset per transplant*/
data full_pvc(keep= PROJID complication_a complication_b complication_c complication_d);
merge full_A(in=a) full_b(in=b) full_c(in=c) full_d(in=d);
by PROJID;
if pvs_vt_a = 1 and  a then complication_a=1;
else if a then complication_a=0;
else complication_a=.;
if pvs_vt_b = 1 and  b then complication_b=1;
else if b then complication_b=0;
else complication_b=.;
if pvs_vt_c = 1 and  c then complication_c=1;
else if c then complication_c=0;
else complication_c=.;
if pvs_vt_d = 1 and  d then complication_d=1;
else  if d then  complication_d=0;
else complication_d=.;
run;
proc freq data=full_pvc;
where not missing(complication_a);
table complication_a complication_b complication_a*complication_b complication_a*complication_b*complication_c*complication_d/ list missing;
run;
proc contents data =full_dem_dt;
run;
*****************************************************************;
/*Merge all dataset*/
*create a dataset for death;
data full_dem_dt exclude;
merge trans.dem_rc (in = a) 
trans.dth(in=b keep=PROJID TDTHDATE RTEGFPRI TLSTDTTP) 
death_fu_time (keep=PROJID fu_time pvt_st pvs_st pvt_lt pvs_lt 
                    hvt_st hat_st hvt_lt hat_lt pvc_st pvc_lt
                    pvt_st_anti pvt_st_reop pvt_st_radi pvt_st_obs
					pvs_st_anti pvs_st_reop pvs_st_radi pvs_st_obs
                    pvt_lt_anti pvt_lt_reop pvt_lt_radi pvt_lt_obs
					pvs_lt_anti pvs_lt_reop pvs_lt_radi pvs_lt_obs)
full_pvc
tpp;
by PROJID;
if a and not missing(complication_a);
*management of complications;
anti = max(pvt_st_anti,pvs_st_anti,pvt_lt_anti,pvs_lt_anti,0);
reop = max(pvt_st_reop, pvs_st_reop, pvt_lt_reop, pvs_lt_reop,0);
radi = max(pvt_st_radi, pvs_st_radi, pvt_lt_radi, pvs_lt_radi,0);
obs  = max(pvt_st_obs, pvs_st_obs, pvt_lt_obs, pvs_lt_obs,0);
management = cats(anti,reop,radi,obs);
*hepatic thromobosis complications;
/*hvt = max(hvt_st,hvt_lt,0);*/
hat = max(hat_st,hat_lt,0);
hepa_complication = max(hat,0);
*complications;
if (pvt_st=1 and pvs_st=1) or (pvt_st=1 and pvs_lt=1) or (pvt_lt=1 and pvs_st=1) or (pvt_lt=1 and pvs_lt=1)
then do; pvc = "both         "; pvc_cat = "both"; complication =1; end;
else if pvt_st = pvt_lt and pvt_lt =1 then do; pvc = "pvt_stlt" ; pvc_cat = "pvt";complication =1;;end;
else if pvs_st = pvs_lt and pvs_lt =1 then do; pvc = "pvs_stlt"; pvc_cat = "pvs" ;complication =1;;end;
else if pvt_st =1 then do; pvc = "pvt_st"; pvc_cat = "pvt";complication =1;end;
else if pvs_st =1 then do; pvc = "pvs_st"; pvc_cat = "pvs" ;complication =1;end;
else if pvt_lt =1 then do; pvc = "pvt_lt"; pvc_cat = "pvt";complication =1;end;
else if pvs_lt =1 then do; pvc = "pvs_lt"; pvc_cat = "pvs" ;complication =1;end;
else do; pvc="None"; pvc_cat = "None" ;complication =0;end;
*Death and death censor;
if b then do; death =1;fu_time_dt = TDTHDATE;end; 
else do; death = 0; fu_time_dt = fu_time; end;
fu_time_dt_yrs =fu_time_dt/365.25;
/*Create variables for table 3*/
if TBIRTHDT_M <=12 then age_cat = 1;
else if TBIRTHDT_M <=60 then age_cat = 2;
else if TBIRTHDT_M <=120 then age_cat = 3;
else age_cat=4;
/*Create variable efor ischemia time for table 3*/
if not missing(TPSTWIT) and  TPSTWIT <=60 then warm_ische_time_cat = 1; else
if 60< TPSTWIT <=120 then warm_ische_time_cat = 2; else
if 120< TPSTWIT <=180 then warm_ische_time_cat = 3; else
if 180< TPSTWIT  then warm_ische_time_cat = 4; 
cold_ische_time = TPSTCITH*60 + TPPTCITM;
cold_ische_time_h = TPSTCITH + (TPPTCITM/60);
if not missing(cold_ische_time) and  cold_ische_time <=300 then cold_ische_time_cat = 1; else
if 300< cold_ische_time <=600 then cold_ische_time_cat = 2; else
if 600< cold_ische_time  then cold_ische_time_cat = 3; 
run;
**************Output the dataset for plot*************;
proc export 
  data=full_dem_dt 
  dbms=xlsx 
  outfile="C:\Users\yxian33\OneDrive - Emory University\Projects_Yijin_Xiang\From_Tracy\transplant\full_dem_dt_0524.xlsx" 
  replace;
run;
/******************************************/
