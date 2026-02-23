library(insurancerating)
library(dplyr)

process_score_model <- stats::glm(
  nclaims ~ age_policyholder + power + bm + zip,
  data = MTPL,
  family = poisson(),
  offset = log(exposure)
)

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

#* Individual process score for a policyholder based on MTPL sample data
#* Returns a predicted claim frequency score
#* @param age_policyholder Age of the policyholder
#* @param power Power of the vehicle
#* @param bm Bonus-malus level
#* @param zip ZIP code zone
#* @param exposure Exposure period in years (must be > 0)
#* @post /process_score
function(age_policyholder, power, bm, zip, exposure, res) {
  tryCatch({
    params <- list(
      age_policyholder = age_policyholder,
      power = power,
      bm = bm,
      zip = zip,
      exposure = exposure
    )
    missing_fields <- names(params)[sapply(params, is.null)]
    if (length(missing_fields) > 0) {
      res$status <- 400
      return(list(error = paste("Missing fields:", paste(missing_fields, collapse = ", "))))
    }
    zip_value <- if (is.factor(MTPL$zip)) {
      factor(zip, levels = levels(MTPL$zip))
    } else {
      as.numeric(zip)
    }
    new_data <- data.frame(
      age_policyholder = as.numeric(age_policyholder),
      power = as.numeric(power),
      bm = as.numeric(bm),
      zip = zip_value,
      exposure = as.numeric(exposure)
    )
    if (anyNA(new_data) || any(new_data$exposure <= 0)) {
      res$status <- 400
      return(list(error = "Invalid input values for scoring."))
    }
    score <- stats::predict(process_score_model, newdata = new_data, type = "response")
    list(score = as.numeric(score))
  }, error = function(e) {
    res$status <- 500
    list(error = conditionMessage(e))
  })
}
