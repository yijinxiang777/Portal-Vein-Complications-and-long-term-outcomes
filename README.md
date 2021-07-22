# Portal Vein Complications and Long-term Outcomes Following Pediatric Liver Transplant: Data from the Society of Pediatric Liver Transplantation  

In this paper, we use robust multicenter data from the [Society of Pediatric Liver Transplantation (SPLIT) registry](https://tts.org/split-home) to investigate portal vein complications in pediatric patients who have undergone liver transplant. Specifically, we analyze the prevalence of portal vein thrombosis or stenosis, risk factors for their development, timing of presentation, interventions, and long-term patient outcomes of graft loss and death.  

There are two SAS script and one R script for this study:  

Analysis00 - load SAS files and formats, recoded variables, abstract information from multiple visits, prepare the time to event variables, and merge multiple dataset.  

Analysis01 - Binary logistics regression, multivariate logistics regression, binary Cox Proportional Hazard models, Proportional Hazard assumption checking, and multivariate Cox Proportional Hazard models.  

Analysis02 - Generated Kaplan-Meier curve and survival table in R   
