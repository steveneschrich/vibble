m <- tibble::tibble(tibble::rownames_to_column(mtcars, "cars"))
test_that("as_of works", {
  expect_equal(as_of(vibble(m)), m)
  expect_equal(as_of(vibble(m, as_of="now")), m)
})

test_that("as_of handles empty vibble", {
  expect_equal(as_of(vibble::vibble()), tibble::tibble())
})
