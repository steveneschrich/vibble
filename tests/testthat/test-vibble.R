
test_that("creating vibble works", {
  expect_equal(nrow(x<-vibble::vibble(iris, as_of="v1")),nrow(iris))
  expect_equal(ncol(x), ncol(iris)+2)
  expect_equal(colnames(x), c(colnames(iris),"ValidFrom","ValidTo"))
  expect_true(all(is.na(x$ValidTo)))
  expect_true(all(x$ValidFrom == "v1"))
  expect_equal(class(x), c("vibble","data.frame"))
  expect_equal(vibble::vibble(iris), vibble::vibble(iris, as_of=lubridate::today()))
})

test_that("as_vibble works", {
  expect_equal(as_vibble(iris, as_of="v1"), vibble(iris, as_of="v1"))
})
