library(bikr)
context("bicycleStatus function checks")

testStatus <- bicycleStatus(scotlandAmsterdam)

test_that("Max 'Total normalised' is equal to 1", {
  expect_output(max(testStatus$'Total normalised'), "1")

})

test_that("'Total normalised' results are less than 1", {
  expect_output(testStatus$'Total normalised' <= 1, "TRUE")
  
})

test_that("'Total normalised' results are equal or greater than 0", {
  expect_output(testStatus$'Total normalised' >= 0, "TRUE")
  
})
