m <- tibble::tibble(tibble::rownames_to_column(mtcars, "car"))

test_that("add_snapshot with same structure works", {

  expect_equal(
    add_snapshot(vibble::vibble(m, as_of="2022-01-01"),
                            m, as_of="2022-01-02") |>
      tibble::tibble() |>
      dplyr::select(1:12),
    m
  )
  expect_equal((add_snapshot(vibble::vibble(m, as_of="2022-01-01"), m, as_of="2022-01-02") |>
                 dplyr::select(-vlist) |> magrittr::set_class(c("tbl_df","tbl","data.frame"))), m)

})


md <- add_snapshot(vibble::vibble(m, as_of="2022-01-01"), m[,1:3], as_of="2022-01-02")

test_that("add_snapshot with different structure works", {
  expect_equal(as_of(md, "2022-01-01"), m)
  expect_equal(as_of(md, "2022-01-02"), m[,1:3])
  expect_equal(magrittr::set_rownames(md[1:32,1:3], NULL), magrittr::set_rownames(md[33:64,1:3], NULL))
  expect_true(all(is.na(md[33:64,4:12])))
  expect_true(all(purrr::map(md$vlist[1:32], ~.)=="2022-01-01"))
  expect_true(all(purrr::map(md$vlist[33:64],~.)=="2022-01-02"))
})

test_that("empty vibble can be added to", {
  expect_equal(nrow(vibble::vibble(tibble::tibble())), 0)
  expect_equal(
    add_snapshot(vibble(tibble::tibble(), as_of="v1"),iris, as_of="v2"),
    vibble::vibble(iris, as_of="v2")
  )
})
