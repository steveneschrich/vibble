test_that("versions returns versions", {
  expect_equal(versions(vibble(iris, as_of="v1")), c("v1"))
  expect_equal(versions(add_snapshot(vibble(iris,as_of="v1"), iris, "v2")), c("v1","v2"))

})

test_that("versions handles edge cases", {
  expect_equal(versions(vibble::vibble()),c())
})
