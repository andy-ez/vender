require 'set'
require 'forwardable'
require 'components/coin'
require 'components/product'
require 'components/coin_collection'
require 'vending_machine_parts/calculator'
require 'vending_machine_parts/cash_register'
require 'vending_machine_parts/product_container'
require 'vending_machine_parts/display'

# Main Vending Machine class made up of the various components
class VendingMachine
  extend Forwardable
  attr_accessor :cash_register, :product_container, :calculator, :display

  def initialize(options = {})
    coins = options[:coins] || {}
    @cash_register = VendingMachineParts::CashRegister.new(coins)
    load_change unless options[:coins]
    @product_container = VendingMachineParts::ProductContainer.new(
      options[:max_size],
      options[:products]
    )
    @calculator = VendingMachineParts::Calculator.new(@cash_register, @product_container)
    @display = VendingMachineParts::Display.new(@calculator)
  end

  def make_selection(product_name)
    result = set_product(product_name)
    return display.write_message(result) if result.is_a? String
    display.selected_product(result)
  end

  def make_payment(coin, quantity = 1)
    add_payment(coin, quantity)
    return_money_paid unless calculator.process_transaction
    return finish_transaction if transaction_successful?
    continue_transaction
  end

  def cancel
    reset
    return_money_paid
  end

  def read_display
    display.show_last
  end

  def_delegators :@product_container, :add_product, :remove_product, :restock,
                 :total_quantity, :available_products, :max_size, :empty!
  def_delegators :@cash_register, :add_payment, :return_money_paid,
                 :release_money_paid, :remove_coins, :pay_out_change
  def_delegators :@calculator, :reset, :status, :change, :set_product, :selection
  # fills the cash register with coins
  def_delegator :@cash_register, :fill_register, :load_change
  def_delegator :@cash_register, :clear!, :empty_register
  def_delegator :@cash_register, :total_value, :total_change
  # returns the coin collection representing change
  def_delegator :@cash_register, :coins, :available_change
  private :cash_register, :product_container, :calculator, :status, :reset,
          :pay_out_change, :change, :set_product, :display

  private

  def transaction_successful?
    status == :success
  end

  def continue_transaction
    case status
    when :no_change
      reset
      display.no_change
    when :in_progress
      display.in_progress
    else
      display.welcome
    end
  end

  def finish_transaction
    returned_product = selection.clone
    returned_change = change.clone
    execute_closing_steps
    [returned_product, returned_change]
  end

  def execute_closing_steps
    display.success
    release_money_paid # release paid in money to register
    pay_out_change(change) # return change to customer
    remove_product(selection.name, 1)
    reset
  end
end
