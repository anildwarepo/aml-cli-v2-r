library(optparse)
library(AzureStor)
library(AzureAuth)



# Read config file from environment file. 
readRenviron("r1.env")

#function to retrieve token to connect to ADLS Gen2
connect_to_adlsgen2 <- function() {
  
  token <- AzureRMR::get_azure_token("https://storage.azure.com",
                                     tenant=Sys.getenv("TENANT"), app=Sys.getenv("APPID"), password=Sys.getenv("CLIENTSECRET"))
  ad_endp_tok2 <<- storage_endpoint(Sys.getenv("ADLSGEN2ENDPOINT"), token=token)
  
}

#fetch token
connect_to_adlsgen2()

#list adls gen2 containers
list_storage_containers(ad_endp_tok2)

#set working container
cont <- storage_container(ad_endp_tok2, "datascience")


#download file from ADLS Gen2 from working container
storage_multidownload(cont, src="/accidentdata/accidents.Rd", dest="/adlsgen2store/accidents.Rd")


options <- list(
  make_option(c("-d", "--data_folder"), default="/adlsgen2store")
)

opt_parser <- OptionParser(option_list = options)
opt <- parse_args(opt_parser)

paste(opt$data_folder)

accidents <- readRDS(file.path(opt$data_folder, "accidents.Rd"))
summary(accidents)

mod <- glm(dead ~ dvcat + seatbelt + frontal + sex + ageOFocc + yearVeh + airbag  + occRole, family=binomial, data=accidents)
summary(mod)
predictions <- factor(ifelse(predict(mod)>0.1, "dead","alive"))
accuracy <- mean(predictions == accidents$dead)

output_dir = "/adlsgen2store"
if (!dir.exists(output_dir)){
  dir.create(output_dir)
}
saveRDS(mod, file = file.path(output_dir, "model.rds"))
message("Model saved")


#upload local file to ADLS Gen2 working container
storage_multiupload(cont, file.path(output_dir, "model.rds"), "/outputs/model.rds")
message(paste("file uploaded to ADLS Gen2 endpoint ",Sys.getenv("ADLSGEN2ENDPOINT")))