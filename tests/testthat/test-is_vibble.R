test_that("is_vibble works", {
  expect_true(is_vibble(vibble(cars)))
  expect_false(is_vibble(tibble::tibble()))
})
