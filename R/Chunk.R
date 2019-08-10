#' A single "lump" of cash
#' 
#' A Chunk is the result of a single payment into an account. Money can be
#' debited from a Chunk but not credited to it. The value of a Chunk cannot fall
#' below zero - if this happens the Chunk is destroyed.
Chunk <- R6::R6Class(
  classname = "Chunk",
  public = list(
    value = 0,
    birthdate = NULL,
    uuid = NULL,
    initialize = function(value = 0, birthdate = Sys.time()) {
      self$value <- value
      self$birthdate <- birthdate
      self$uuid <- uuid::UUIDgenerate()
    },
    debit = function(amount) {
      self$value <- max(self$value - amount, 0)
    },
    is_empty = function() {
      self$value == 0
    },
    print = function() {
      cat("Chunk", self$uuid, "\n")
      cat("  Value:", self$value, "\n")
      cat("  Birthdate:", self$birthdate, "\n")
      invisible(self)
    }
  )
)


#' A variant of the Chunk that allows overdrafts
#' 
#' A BaseChunk is the first Chunk created in a Balance. Unline a regular Chunk,
#' a BaseChunk has debit and credit methods. The value of a BaseChunk can
#' decrease indefinitely (i.e. it can go overdrawn) but it can never increase
#' above zero.
BaseChunk <- R6::R6Class(
  classname = "BaseChunk",
  inherit = Chunk,
  public = list(
    credit = function(amount) {
      self$value <- min(self$value + amount, 0)
    },
    debit = function(amount) {
      self$value <- self$value - amount
    }
  )
)
