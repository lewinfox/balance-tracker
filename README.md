# balance-tracker

The idea here is to be able to answer the question, when looking at a transaction
history for a bank account, "how old is this cash?".

It implements a LIFO (last-in-first-out) queue, where each credit to the account
is treated as a discrete unit called a `Chunk`. A collection of `Chunk`s is a 
`Balance`. Debits from a `Balance` are handled by debting money from the most 
recently created `Chunk` until it is exhausted, at which point it is destroyed.

Negative balances are handled by a `BaseChunk` which is a subclass of `Chunk`. A
`BaseChunk` can only have values >= 0, but can be infinitely extended below
zero, i.e. go overdrawn. Credits to a `BaseChunk` do not create new `Chunk`s
until the total balance is above zero.

## Example
```r
# A Balance is created with a nil-value BaseChunk
b <- Balance$new()
print(b)

# Credits will create new Chunks
b$credit(100)
print(b)

b$credit(200)
print(b)

# Debits remove value from newest Chunks first
b$debit(150)
print(b)

b$debit(100)
print(b)

# A Balance can go overdrawn
b$debit(1000)
print(b)

# Credits to an overdrawn Balance do not create new Chunks but increase the
# value of the BaseChunk, up to a maximum of zero
b$credit(300)
b$credit(300)
b$credit(300)
print(b)

# Once past zero, new credits create new Chunks
b$credit(200)
b$credit(200)
print(b)

```