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
  # private :cash_register, :product_container, :calculator
  def initialize
    @cash_register = VendingMachineParts::CashRegister.new
    load_change
    @product_container = VendingMachineParts::ProductContainer.new
    @calculator = VendingMachineParts::Calculator.new(@cash_register, @product_container)
    @display = VendingMachineParts::Display.new(@calculator)
  end

  # returns the monetary value of available change in the till
  def total_change
    @cash_register.total_value
  end

  def selection
    calculator.selection
  end

  def make_selection(product_name)
    result = calculator.set_product(product_name)
    display.write_message(result.to_s)
  end

  def make_payment(coin, quantity=1)
    cash_register.add_payment(coin, quantity)
    cash_register.return_money_paid unless calculator.process_transaction
    return finish_transaction if transaction_successful?
    continue_transaction
    # if selection.nil?
    #   display.select_product
    # else
    #   cash_register.add_payment(coin, quantity)
    #   calculator.process_transaction
    #   handle_result
    # end
  end

  def cancel
    calculator.reset
    cash_register.return_money_paid
  end

  def transaction_successful?
    status == :success
  end

  def read_display
    puts display.message
  end

  def_delegators :@product_container, :add_product, :remove_product, :restock,
                 :total_quantity, :available_products
  def_delegators :@cash_register, :add_payment, :return_money_paid,
                 :release_money_paid
  # fills the cash register with coins
  def_delegator :@cash_register, :fill_register, :load_change
  # returns the coin collection representing change
  def_delegator :@cash_register, :coins, :change

  private

  def status
    calculator.status
  end

  def continue_transaction
    case status
    when :no_change
      display.no_change
      return_result = [nil, cash_register.return_money_paid]
      calculator.reset
    when :in_progress
      display.in_progress
    else
      display.welcome
    end
    return_result if return_result
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
