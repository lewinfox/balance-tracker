#' A series of Chunks
#' 
#' A Balance is composed of Chunks. When a Balance is created, its first Chunk
#' is a BaseChunk. A balance always has exactly one BaseChunk (which handles
#' overdrafts) and zero or more Chunks (which handle credit balances).
Balance <- R6::R6Class(
  classname = "Balance",
  public = list(
    uuid = NULL,
    chunks = list(),
    balance = NULL,
    initialize = function() {
      self$uuid <- uuid::UUIDgenerate()
      self$chunks <- list(BaseChunk$new())
      self$balance <- self$calculate_balance()
    },
    print = function() {
      cat("Balance:", self$balance, "\n")
      for (c in self$chunks) print(c)
      invisible(self)
    },
    calculate_balance = function() {
      self$balance <- sum(sapply(self$chunks, function(c) c$value))
    },
    credit = function(amount) {
      self$chunks <- c(Chunk$new(amount), self$chunks)
      self$calculate_balance()
    },
    debit = function(amount) {
      amount_to_debit <- amount
      while (amount_to_debit > 0) {
        if (is(self$chunks[[1]], "BaseChunk")) {
          amount_to_take_from_chunk <- amount_to_debit
          self$chunks[[1]]$debit(amount_to_take_from_chunk)
        } else {
          amount_to_take_from_chunk <- min(amount_to_debit, self$chunks[[1]]$value)
          self$chunks[[1]]$debit(amount_to_take_from_chunk)
          if (self$chunks[[1]]$is_empty()) {
            self$chunks[[1]] <- NULL
          }
        }
        amount_to_debit <- amount_to_debit - amount_to_take_from_chunk
      }
    }
  )
)
