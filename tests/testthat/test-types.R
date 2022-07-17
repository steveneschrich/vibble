test_that("type_converter works for single value", {
  expect_identical(type_converter(1), as.numeric)
  expect_identical(type_converter(1.1), as.numeric)
  expect_identical(type_converter("a"), as.character)
  expect_identical(type_converter(TRUE), as.logical)
  expect_identical(type_converter(Sys.Date()), lubridate::as_date)
  expect_identical(type_converter(Sys.time()), lubridate::as_datetime)

})


test_that("type_converter works for missing values", {
  expect_identical(type_converter(NA), as.logical)
  expect_identical(type_converter(NULL), as.character)
  expect_identical(type_converter(NaN), as.numeric)
})

test_that("type_converter works for lists", {
  expect_identical(type_converter(c(0,1)), as.numeric)
  expect_identical(type_converter(list(0,1)), as.numeric)
  expect_identical(type_converter(c(1.1,1.2)), as.numeric)
  expect_identical(type_converter(list(1.1,1.2)), as.numeric)
  expect_identical(type_converter(c("a","b")), as.character)
  expect_identical(type_converter(list("a","b")), as.character)
  expect_identical(type_converter(c(TRUE, FALSE)), as.logical)
  expect_identical(type_converter(list(TRUE, FALSE)), as.logical)
  expect_identical(type_converter(c(Sys.Date(), Sys.Date())), lubridate::as_date)
  expect_identical(type_converter(list(Sys.Date(), Sys.Date())), lubridate::as_date)
  expect_identical(type_converter(c(Sys.time(), Sys.time())), lubridate::as_datetime)
  expect_identical(type_converter(list(Sys.time(), Sys.time())), lubridate::as_datetime)


})
