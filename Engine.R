library('rvest')
library('stringr')
library('pdftools')
library('tesseract')

hrefs<-read_html('http://biznes.pap.pl/pl/news/listings/1,') %>% 
  html_nodes("table.espi") %>%
  html_nodes(xpath="tr/td/a") %>%
  html_attr("href")
links<-paste('http://biznes.pap.pl',hrefs,sep="")
oldlinks<-links;
#contains<-c('nexity','ml-system'); #what company youre looking for



#every n minutes:
repeat
{
  tryCatch({
    hrefs<-read_html('http://biznes.pap.pl/pl/news/listings/1,') %>% 
      html_nodes("table.espi") %>%
      html_nodes(xpath="tr/td/a") %>%
      html_attr("href")
    links<-paste('http://biznes.pap.pl',hrefs,sep="")
    news<-setdiff(links,oldlinks)
    oldlinks<-links;
    #news<-links[str_detect(links,paste(contains,collapse='|'))] #in case of contains
    #w div iq2 jest info o za³¹cznikach
    for(i in news)
    {
      out=max(as.numeric(list.files('Data')))+1;
      
      
      website<-read_html(i)
      info<-website %>% 
        html_nodes('#depesza') %>% 
        html_text
      info<-info[1]
      #cat(info)
      #cat('\n')
      
      
      dir.create(paste('Data/',out,sep=""));
      write(info,paste('Data/',out,'/main.txt',sep=""));
  
      
      
      attachments<-website %>%
        html_nodes('.iq2') %>%
        html_nodes(xpath="a") %>%
        html_attr("href")
      if(length(attachments!=0))
      {
        attachments<-paste('http://www.biznes.pap.pl',attachments,sep="")
        for(j in attachments)
        {
          tryCatch({
            attach<-pdf_text(pdf=j)
            if(object.size(attach)<130)
            {
              attach<-pdf_ocr_text(j,language='pol',dpi=1000)
            }
            #cat(attach)
            write(attach,paste('Data/',out,'/att',which(j==attachments),'.txt',sep=""));
          }, error=function(f){cat("Error in attachments, folder ",out," and link\n",j)});
        }
        #system('CMD /C "ECHO The R process has finished running && PAUSE"', 
        #       invisible=FALSE, wait=FALSE)
      }
      #cat(as.character(Sys.time()))
    }
    closeAllConnections()
    Sys.sleep(5)
  }, error=function(e){cat("Error at time: ",as.character(Sys.time())," and mess: ",message(e))});
}

write(attach,'C:/Users/Wojtek/Desktop/file2.txt')
library('htmltidy')
x<-html_text(tidy_html(read_html(j)))


