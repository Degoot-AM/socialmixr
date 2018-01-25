##' List all surveys available for download
##'
##' @return character vector of surveys
##' @importFrom oai list_records
##' @examples
##' list_surveys()
##' @export
list_surveys <- function()
{
    ## circumvent R CMD CHECK errors by defining global variables
    id <- NULL
    relation.1 <- NULL
    datestamp <- NULL
    identifier.1 <- NULL
    identifier.3 <- NULL
    title <- NULL
    creator <- NULL

    record_list <-
        data.table(list_records("https://zenodo.org/oai2d",
                                metadataPrefix="oai_datacite",
                                set="user-social_contact_data"))

    relations <- grep("^relation(\\.|$)", colnames(record_list), value=TRUE)
    DOIs <- apply(record_list, 1, function(x) grep("^doi:", x[relations], value=TRUE)[1])
    record_list <- record_list[, doi := sub("^doi:", "", DOIs)]
    record_list <-
      record_list[record_list[, .I[datestamp == max(datestamp)], by=doi]$V1]
    record_list <- record_list[, id := seq_len(nrow(record_list))]
    setkey(record_list, id)
    return(record_list[, list(id, date, title, creator, url=paste0("https://doi.org/", doi))])
}

##' List all countries contained in a survey
##'
##' @param country.column column in the survey indicating the country
##' @param ... further arguments for \code{\link{get_survey}}
##' @return list of countries
##' @inheritParams get_survey
##' @examples
##' data(polymod)
##' survey_countries(polymod)
##' @export
survey_countries <- function(survey, country.column = "country", ...)
{
    survey <- get_survey(survey, ...)
    return(as.character(unique(survey[["participants"]][[country.column]])))
}

##' List all countries and regions for which socialmixr has population data
##'
##' Uses the World Population Prospects data from the \code{wpp2015} package
##' @return list of countries
##' @import wpp2015
##' @importFrom data.table data.table setkey
##' @importFrom utils data
##' @examples
##' wpp_countries()
##' @export
wpp_countries <- function()
{
    ## circumvent R CMD CHECK errors by defining global variables
    popF <- NULL
    popM <- NULL

    data(popF, package = "wpp2015", envir = environment())
    data(popM, package = "wpp2015", envir = environment())
    pop <- data.table(rbind(popF, popM))
    setkeyv(pop, "country")
    countries <- as.character(unique(pop$country))
    found_countries <-
        suppressWarnings(countrycode(countries, "country.name", "country.name"))
    found_countries <- found_countries[!is.na(found_countries)]
    return(found_countries)
}

