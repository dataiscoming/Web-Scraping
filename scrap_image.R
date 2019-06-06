# Starter time stored
start_time <- Sys.time()

# Packages
library("rvest")
library("dplyr")
library("progress")

# Set up the input data frame containing the character names and the URL to scrap
character <- data.frame("character_name"=c('Daenerys_Targaryen_1',"Daenerys_Targaryen_2",'Jon_Snow_1','Jon_Snow_2'),
                        "character_url"=c("https://gameofthrones.fandom.com/wiki/Category:Image_%28Daenerys_Targaryen%29",
                                          "https://gameofthrones.fandom.com/wiki/Category:Image_%28Daenerys_Targaryen%29?from=Dany+promo+season+4+ep10+fullsize.jpg",
                                          "https://gameofthrones.fandom.com/wiki/Category:Image_%28Jon_Snow%29",
                                          "https://gameofthrones.fandom.com/wiki/Category:Image_%28Jon_Snow%29?from=Jon+TQJ.jpg"),
                        stringsAsFactors=FALSE)

# Creation of the function to extract the image from https://gameofthrones.fandom.com
get_image<-function(character_name,character_url){
  
  # Download the URL of the character
  download.file(character_url, destfile = "url_character.html", quiet=TRUE)
  
  # Extracting the links to the images 
  node_character <- read_html("url_character.html") %>%
    html_nodes(xpath='//*[@id="mw-content-text"]/div/ul/li/a') %>%
    html_attr('href')
  
  # Progress Bar to follow the evolution of the execution, showing the estimated time of completion 
  pb <- progress_bar$new(format = "downloading [:bar] :current/:total (:percent) :eta",
                         total = length(node_character))
  
  # Download of the link to the single image with a better resolution
  for(i in 1:length(node_character)){
    url_image<-paste0("https://gameofthrones.fandom.com",node_character[i]) 
    download.file(url_image, destfile = "url_image.html", quiet=TRUE)
    node_image <- read_html("url_image.html") %>%
      html_nodes(xpath = '//*[@id="file"]/a') %>%
      html_attr('href')
    
  # Download of the image
    tryCatch(download.file(node_image, destfile = 
                             paste0("image/Scraping/",character_name,'/',character_name,i,".png"),mode = "wb",quiet = TRUE),
             error= function(e){cat("Error")},
             warning= function(w){cat("Warning")})
    
    pb$tick()
  }
  
  # Deleting the temporary files
  file.remove("url_image.html")
  file.remove("url_character.html")
}
  
# Scraping images of the characters
# Deanerys 1
get_image(character$character_name[1],character$character_url[1])
# Deanerys 2
get_image(character$character_name[2],character$character_url[2])
# Jon Snow 1
get_image(character$character_name[3],character$character_url[3])
# Jon Snow 2
get_image(character$character_name[4],character$character_url[4])

# end time stored
end_time <- Sys.time()
# Show how much time the code needed to be executed
end_time-start_time
