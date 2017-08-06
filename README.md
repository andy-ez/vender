# Simple Vending Machine
Basic Vending Machine Simulator with the following key features:
  - Once an item is selected and the appropriate amount of money is inserted, the vending machine should return the correct product.
  - Returns change if too much money is provided, or prompts for more money if insufficient funds have been inserted.
  - Accepts standard UK coins (1p, 2p, 5p, 10p, 20p, 50p, £1, £2)
  - Coins can be reloaded or emptied
  - Has an initial load of products which can be completely emptied or restocked.
  - Adding custom products
  - Setting a limit on product capacity
  - Keeps track of available change and available products

## Installation

* Download the project folder then in a terminal session navigate to the project's directory and run:
    `bundle install`
  Note this application will require a working Ruby installation (>1.9.3).

## Testing
Tests can be run by running the command:
    `rspec`

## Usage

Application can be run in an IRB session from the command line by typing:
    `./run`
Or alternatively:
    `irb -r './lib/vending_machine.rb'`

### Example Usage
In the IRB session try out the following:

### Create a new machine
All functionality is centered on the VendingMachine class which can be instantiated as below:
```ruby
# create a Venidng Machine loaded with default products and change 
shop = VendingMachine.new

```

### Product Managment
Once you have a vending machine instance you can retrieve the products it has available:

```ruby
  # show avilable products and their quantities
  shop.available_products
  # removes a product (removes 1 by default if no quantity passed) if it is present
  shop.remove_product('Snickers', 5)
  # adds a default product by passing string name and optional quantity if there is capacity
  shop.add_product('Snickers')
  # adds a custom new product with a price of £2.10 (input price in pence)
  shop.add_product({name: 'My Custom Product', price: 210})
  # refills products
  shop.restock
  # clears all products
  shop.empty!
```

### Transactions

```ruby
# to begin a transaction make a product selection
shop.make_selection 'Snickers' #
# to pay for the product insert a coin by running
shop.make_payment '£1' #accepts valid coin names as strings
# if you change your mind...you can cancel a transaction before its complete
shop.cancel
```

### Cash Managment

```ruby
# view quanatity of coins available
shop.available_change
# load the register with a given quantity of each coin (default of 20/coin)
shop.load_change(60)
```
