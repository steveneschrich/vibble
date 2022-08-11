m <- tibble::rownames_to_column(mtcars, "cars")

test_that("creating vibble works", {
  expect_equal(nrow(x<-vibble::vibble(m, as_of="v1")),nrow(m))
  expect_equal(nrow(vibble::vibble(iris)), nrow(iris)-1)
  expect_equal(ncol(x), ncol(m)+1)
  expect_equal(colnames(x), c(colnames(m),"vlist"))
  expect_true("tbl_vdf" %in% class(x))
  expect_equal(vibble::vibble(m), vibble::vibble(m, as_of=lubridate::today()))
})

test_that("as_vibble works", {
  expect_equal(as_vibble(m, as_of="v1"), vibble(m, as_of="v1"))
})
