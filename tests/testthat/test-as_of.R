m <- tibble::tibble(tibble::rownames_to_column(mtcars, "cars"))
test_that("as_of works", {
  expect_equal(as_of(vibble(m)), m)
  expect_equal(as_of(vibble(m, as_of="now")), m)
})

test_that("as_of handles empty vibble", {
  expect_equal(as_of(vibble::vibble()), tibble::tibble())
  expect_error(as_of(tibble::tibble()))

})

test_that("as_of handles mismatched version tags", {
  expect_error(as_of(vibble::vibble(iris, as_of="v1"), as_of=lubridate::today()))
})

test_that("as_of handles null as_of, to find the most recent tag", {
  expect_equal(as_of(vibble::vibble(iris, as_of="v1")) , as_of(vibble::vibble(iris, as_of="v1"), as_of="v1"))
})

test_that("as_of handles exact only search", {
  expect_equal(as_of(vibble::vibble(iris, as_of="v1"), "v2", exact = TRUE),tibble::tibble())
  expect_equal(
    as_of(vibble::vibble(iris, as_of="v1"), exact=FALSE, "v2"),
    as_of(vibble::vibble(iris, as_of="v1"), exact=TRUE, "v1")
  )
})

m <- vibble::add_snapshot(vibble::vibble(iris, as_of="2022-01-01"), mtcars, as_of="2022-01-02")
test_that("Random data frames at different times are preserved.", {
  expect_equal(sort(as_of(m, as_of="2022-01-01")$Sepal.Length), sort(iris$Sepal.Length))
  expect_equal(as_of(m, as_of="2022-01-02"), tibble::tibble(mtcars))

})
