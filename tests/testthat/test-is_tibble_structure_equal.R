m <- tibble::rownames_to_column(mtcars, "cars")
test_that("tibble_structure_compare", {
  expect_true(is_tibble_structure_equal(m, m))
  expect_true(is_tibble_structure_equal(m, m[,12:1]))
  expect_true(is_tibble_structure_equal(m, m[1:12,]))
  expect_false(is_tibble_structure_equal(m, m[,1:3]))
  expect_false(is_tibble_structure_equal(m[,1:3], m))
})
