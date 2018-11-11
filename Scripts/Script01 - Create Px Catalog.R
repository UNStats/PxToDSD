
#===============================================================================
# Step 1: Create catalogue of PX files with annotations
#==============================================================================

library(data.table)


setwd("C:/Users/L.GonzalezMorales/Documents/GitHub/PxToDSD")


#-----------------------------------------------------------------------------
# List of countreis to be plotted on a map (with XY coordinates)
#------------------------------------------- ----------------------------------

PxCatalog <- as.data.table(read.table("Input/PCBS/PCBS-PX-Catalog.txt", 
                                          header = TRUE, 
                                          sep = "\t",
                                          quote = "",
                                          na.strings = "", 
                                          stringsAsFactors = FALSE,
                                          encoding = "UTF-8"))


pxSelect <- PxCatalog[, list(Code,EngTitle,ParentCode,TableId)]


pxSelect1 <- merge(pxSelect[is.na(TableId),
                            list(Parent2Code = ParentCode, 
                                 Parent1Code = Code,
                                 Parent1 = EngTitle)],
                   pxSelect[!is.na(TableId),
                            list(Code,
                                 Parent1Code = ParentCode,
                                 Indicator = EngTitle,
                                 TableId)],
                   all.y = TRUE)

pxSelect2 <- merge(pxSelect[is.na(TableId),
                            list(Parent3Code = ParentCode,
                                 Parent2Code = Code, 
                                 Parent2 = EngTitle)],
                   pxSelect1,
                   by= "Parent2Code",
                   all.y = TRUE)


pxSelect3 <- merge(pxSelect[is.na(TableId),
                            list(Parent3Code = Code, 
                                 Parent3 = EngTitle)],
                   pxSelect2,
                   by= "Parent3Code",
                   all.y = TRUE)

pxCatalogFlat <- pxSelect3[,list(Group0Code = Parent3Code,
                                Group0Desc = Parent3,
                                Group1Code = sapply(Parent2Code, function(x) paste0("'", x)),
                                Group1Desc = Parent2,
                                Group2Code = sapply(Parent1Code, function(x) paste0("'", x)),
                                Group2Desc = Parent1,
                                IndicatorCode = Code,
                                IndicatorDesc = Indicator,
                                TableId)]



write.table(pxCatalogFlat, 
            file = "Output/PCBS/PCBS-PX-Catalog-Flat.txt",
            append = FALSE,
            quote = FALSE, 
            sep = "\t",
            eol = "\n", 
            na = "", 
            dec = ".", 
            row.names = FALSE,
            col.names = TRUE, 
            fileEncoding = "UTF-8")

