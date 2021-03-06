#' @title Create control structures for multi-criteria tuning.
#'
#' @description
#' The following tuners are available:
#' \describe{
#'   \item{makeTuneMultiCritControlGrid}{Grid search. All kinds of parameter types can be handled.
#'     You can either use their correct param type and \code{resolution},
#'     or discretize them yourself by always using \code{\link[ParamHelpers]{makeDiscreteParam}}
#'     in the \code{par.set} passed to \code{\link{tuneParams}}.}
#'   \item{makeTuneMultiCritControlRandom}{Random search. All kinds of parameter types can be handled.}
#'   \item{makeTuneMultiCritControlNSGA2}{Evolutionary method \code{\link[mco]{nsga2}}.
#'     Can handle numeric(vector) and integer(vector) hyperparameters, but no dependencies.
#'     For integers the internally proposed numeric values are automatically rounded.}
#'   \item{makeTuneMultiCritControlMBO}{Model-based/ Bayesian optimization. All kinds of
#'     parameter types can be handled.}
#' }
#'
#' @inheritParams TuneControl
#' @param budget [\code{integer(1)}]\cr
#'   Maximum budget for tuning. This value restricts the number of function
#'   evaluations. In case of \code{makeTuneMultiCritControlGrid} this number
#'   must be identical to the size of the grid. For
#'   \code{makeTuneMultiCritControlRandom} the \code{budget} equals the number
#'   of iterations (\code{maxit}) performed by the random search algorithm.
#'   In case of \code{makeTuneMultiCritControlNSGA2} the \code{budget}
#'   corresponds to the product of the maximum number of generations
#'   (\code{max(generations)}) + 1 (for the initial population) and the size of
#'   the population (\code{popsize}). For \code{makeTuneMultiCritControlMBO} the
#'   \code{budget} equals the number of objective function evaluations, i.e. the
#'   number of MBO iterations + the size of the initial design. If not \code{NULL},
#'   this will overwrite existing stopping conditions in \code{mbo.control}.
#' @return [\code{\link{TuneMultiCritControl}}]. The specific subclass is one of
#'   \code{\link{TuneMultiCritControlGrid}}, \code{\link{TuneMultiCritControlRandom}},
#'   \code{\link{TuneMultiCritControlNSGA2}}, \code{\link{TuneMultiCritControlMBO}}.
#' @family tune_multicrit
#' @name TuneMultiCritControl
#' @rdname TuneMultiCritControl
#' @aliases TuneMultiCritControlGrid TuneMultiCritControlRandom TuneMultiCritControlNSGA2 TuneMultiCritControlMBO
NULL

makeTuneMultiCritControl = function(measures, same.resampling.instance,
  impute.val = NULL, log.fun = "default", final.dw.perc = NULL, budget = NULL, ..., cl) {

  assertFlag(same.resampling.instance)
  if (!is.null(impute.val))
    assertNumeric(impute.val, any.missing = FALSE)
  if (identical(log.fun, "default"))
    log.fun = logFunTune
  else if (identical(log.fun, "memory"))
    log.fun = logFunTuneMemory
  if (!is.null(budget))
    budget = asCount(budget)
  x = makeOptControl(same.resampling.instance, impute.val, log.fun = log.fun,
    final.dw.perc = final.dw.perc, ...)
  x$budget = budget
  addClasses(x, c(cl, "TuneMultiCritControl"))
}

#' @export
print.TuneMultiCritControl = function(x, ...) {
  catf("Tune multicrit control: %s", class(x)[1])
  catf("Same resampling instance: %s", x$same.resampling.instance)
  catf("Imputation value: %s", ifelse(is.null(x$impute.val), "<worst>", collapse(sprintf("%g", x$impute.val))))
  catf("Budget: %i", x$budget)
  catf("Further arguments: %s", convertToShortString(x$extra.args))
}

