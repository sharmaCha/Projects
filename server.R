require(imager)
require(shiny)
require(jpeg)
require(png)
require(randomForest)
require(readr)
#install.packages("pixmap")
require(pixmap)
#install.packages("dplyr")
require(dplyr)
#install.packages("rgdal")
require(readbitmap)
require(rgdal)
#install.packages("jpeg")  
require(class)
require(caTools)
#install.packages("imager")
require(imager)

trainDF <- read.csv("E:\\ADS_Yelp_Analysis\\DataModel\\train_Yelp.csv")
trainDF <- na.omit(trainDF)
trainDF <- trainDF[,2:401]
set.seed(123)
split <- sample.split(trainDF, SplitRatio = 0.5)
train <- subset(trainDF, split == TRUE)
sum(is.na(train))

train <- na.omit(train)

trainDF_temp <- trainDF
downsampled_matrix = matrix(ncol = 100, nrow = nrow(trainDF_temp))
for(i in 1:nrow(trainDF_temp)){
  m = matrix(unlist(trainDF_temp[i, -1]),nrow = 10,byrow = F)
  img = as.cimg(m)
  img_resized = resize(img,round(width(img)/2),round(height(img)/2))
  downsampled_matrix[i, ] = as.vector(img_resized)
}

trainDF_downsampled = as.data.frame(downsampled_matrix)
trainDF_downsampled$labels = trainDF_temp$labels
trainDF_downsampled = trainDF_downsampled[,c(101, 1:100)]

trainDF_down <<- trainDF_downsampled

model <<- randomForest(labels ~ ., ntree=500, data=trainDF_down) # default mtry = sqrt(p), ntree = 500

test_images = list(rep(0,1))
test_mat = matrix(ncol = 401, nrow = 1)

preproc.image <- function(im) {
  photo_id = strsplit(1, split = ".jpg", fixed=T)
  photo_id2 = photo_id[[1]]
  test_mat[1,1] = as.numeric(photo_id2)
  test_mat[1,1]
  test_mat  
  test_images[[1]]= test_true_files
  img = test_images[[1]]
  length(dim(img))
  dim(img)
  r = as.data.frame(img[ , , 1])
  g = as.data.frame(img[ , , 2])
  b = as.data.frame(img[ , , 3])
  temp = (r + g + b)/3
  temp = as.vector(temp)
  temp = c(photo_id2, temp)
  View(temp)
  for(j in 2:401){
    test_mat[1,j] = temp$band1[j]
    
  }
  
  testDF = as.data.frame(test_mat)
  testDF = testDF %>% dplyr::rename(photo_id = V1)
  
  return(testDF)
}

shinyServer(function(input, output) {
  ntext <- eventReactive(input$goButton, {
    print(input$url)
    if (input$url == "http://") {
      NULL
    } else {
      tmp_file <- tempfile()
      download.file(input$url, destfile = tmp_file)
      tmp_file
    }
  })
  
  output$originImage = renderImage({
    list(src = if (input$tabs == "Upload Image") {
      if (is.null(input$file1)) {
        if (input$goButton == 0 || is.null(ntext())) {
          'cthd.jpg'
        } else {
          ntext()
        }
      } else {
        input$file1$datapath
      }
    } else {
      if (input$goButton == 0 || is.null(ntext())) {
        if (is.null(input$file1)) {
          'cthd.jpg'
        } else {
          input$file1$datapath
        }
      } else {
        ntext()
      }
    },
    title = "Original Image")
  }, deleteFile = FALSE)
  print(input$file1)
  output$res <- renderText({
    src = if (input$tabs == "Upload Image") {
      if (is.null(input$file1)) {
        if (input$goButton == 0 || is.null(ntext())) {
          'cthd.jpg'
        } else {
          ntext()
        }
      } else {
        input$file1$datapath
      }
    } else {
      if (input$goButton == 0 || is.null(ntext())) {
        if (is.null(input$file1)) {
          'cthd.jpg'
        } else {
          input$file1$datapath
        }
      } else {
        ntext()
      }
    }
    
    im <- load.image(src)
    normed <- preproc.image(im)
    prob <- predict(model, newdata=normed, type = "response")
    max.idx <- order(prob[,1], decreasing = TRUE)[1:5]
    result <- max.idx
    res_str <- ""
    for (i in 1:5) {
      tmp <- strsplit(result[i], " ")[[1]]
      for (j in 2:length(tmp)) {
        res_str <- paste0(res_str, tmp[j])
      }
      res_str <- paste0(res_str, "\n")
    }
    res_str
  })
  
})


 
