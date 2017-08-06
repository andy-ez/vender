require 'set'
require 'forwardable'
require_relative 'components/coin'
require_relative 'components/product'
require_relative 'components/coin_collection'
require_relative 'vending_machine_parts/calculator'
require_relative 'vending_machine_parts/cash_register'
require_relative 'vending_machine_parts/product_container'
require_relative 'vending_machine_parts/display'

# Main Vending Machine class made up of the various components
class VendingMachine
  extend Forwardable
  attr_accessor :cash_register, :product_container, :calculator, :display
  private :cash_register, :product_container, :calculator
  def initialize(options = {})
    coins = options[:coins] || {}
    @cash_register = VendingMachineParts::CashRegister.new(coins)
    load_change unless options[:coins]
    @product_container = VendingMachineParts::ProductContainer.new(options[:max_size])
    @calculator = VendingMachineParts::Calculator.new(@cash_register, @product_container)
    @display = VendingMachineParts::Display.new(@calculator)
  end

  # returns the monetary value of available change in the till
  def total_change
    cash_register.total_value
  end

  def selection
    calculator.selection
  end

  def make_selection(product_name)
    result = calculator.set_product(product_name)
    return display.write_message(result) if result.is_a? String
    display.selected_product(result)
  end

  def make_payment(coin, quantity=1)
    cash_register.add_payment(coin, quantity)
    cash_register.return_money_paid unless calculator.process_transaction
    return finish_transaction if transaction_successful?
    continue_transaction
  end

  def cancel
    calculator.reset
    cash_register.return_money_paid
  end

  def read_display
    puts display.message
  end

  def_delegators :@product_container, :add_product, :remove_product, :restock,
                 :total_quantity, :available_products, :max_size, :empty!
  def_delegators :@cash_register, :add_payment, :return_money_paid,
                 :release_money_paid, :remove_coins
  # fills the cash register with coins
  def_delegator :@cash_register, :fill_register, :load_change
  def_delegator :@cash_register, :clear!, :empty_register
  # returns the coin collection representing change
  def_delegator :@cash_register, :coins, :available_change

  private

  def status
    calculator.status
  end

  def transaction_successful?
    status == :success
  end

  def continue_transaction
    case status
    when :no_change
      calculator.reset
      display.no_change
    when :in_progress
      display.in_progress
    else
      display.welcome
    end
  end

  def finish_transaction
    returned_product = selection.clone
    returned_change = calculator.change.clone
    execute_closing_steps
    [returned_product, returned_change]
  end

  def execute_closing_steps
    display.success
    cash_register.release_money_paid
    cash_register.pay_out_change(calculator.change)
    remove_product(selection.name, 1)
    calculator.reset
  end
end
