
foo <- read.csv(file = "./portland-burden-sgy.csv")

foobar <- foo %>% gather("burdenType", "value", 4:7) %>% spread(disease, "value") %>% mutate( CVD = HypertensiveHD + IHD + InflammatoryHD) %>% gather("disease", "value", -(1:3)) %>% filter(disease %in% c("BreastCancer", "ColonCancer", "Diabetes", "Dementia", "Depression", "CVD")) %>% select(disease,sex,age,burdenType,value) %>% arrange(disease,sex,age,burdenType)
names(foobar) <- c("disease","sex","ageClass","burdenType","value")

convertAge <- function(ageCat){
ageClass <- ifelse( ageCat == "0-4", "ageClass1",
			   ifelse( ageCat == "5-14", "ageClass2",
					  ifelse( ageCat == "15-29", "ageClass3",
							 ifelse( ageCat == "30-44", "ageClass4",
									ifelse( ageCat == "45-59", "ageClass5",
										       ifelse( ageCat == "60-69", "ageClass6",
												      ifelse( ageCat == "70-79", "ageClass7",
														     ifelse( ageCat == "80+", "ageClass8", NA))))))))
return(ageClass)
}


foobar <- within(foobar, sex <- ifelse(sex == "1", "M", ifelse( sex == "2", "F", NA)))
foobar <- within(foobar, ageClass <- convertAge(ageClass))

write.csv(foobar, file = "~/Portland/portland-burden-sgy-reformatted.csv", quote = FALSE, row.names = FALSE)
