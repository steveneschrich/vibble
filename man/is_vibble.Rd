% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/is.R
\name{is_vibble}
\alias{is_vibble}
\title{Test is the object is a vibble}
\usage{
is_vibble(x)
}
\arguments{
\item{x}{An object}
}
\value{
\code{TRUE} if the object inherits from the \code{tbl_vdf} class.
}
\description{
This function returns \code{TRUE} for vibbles and \code{FALSE} for all other objects,
including tibbles and regular data frames.
}
