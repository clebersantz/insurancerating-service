library(insurancerating)
library(dplyr)

#* @apiTitle Insurance Rating Service
#* @apiDescription HTTP service for insurance rating calculations using the insurancerating package with MTPL sample data.

#* Health check
#* @get /health
function() {
  list(status = "ok")
}

#* Univariate analysis on MTPL2 sample data segmented by area
#* Returns claim frequency, average severity, risk premium, loss ratio and average premium per area
#* @get /univariate
function(res) {
  tryCatch({
    result <- univariate(
      MTPL2,
      x        = area,
      nclaims  = nclaims,
      exposure = exposure,
      premium  = premium,
      severity = amount
    )
    as.data.frame(result)
  }, error = function(e) {
    res$status <- 500
    list(error = conditionMessage(e))
  })
}

#* Fit a GAM for claim frequency by policyholder age on MTPL sample data
#* Returns predicted claim frequency with 95% confidence intervals per age.
#* Response columns: x (age), predicted (claim frequency), lwr_95, upr_95.
#* @get /fit_gam
function(res) {
  tryCatch({
    model <- riskfactor_gam(
      MTPL,
      nclaims  = "nclaims",
      x        = "age_policyholder",
      exposure = "exposure"
    )
    as.data.frame(model$prediction)
  }, error = function(e) {
    res$status <- 500
    list(error = conditionMessage(e))
  })
}
