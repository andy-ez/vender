module VendingMachineParts
  # Encapsulation of display duties
  class Display
    attr_reader :message, :calculator
    def initialize(calculator)
      @calculator = calculator
      welcome
    end

    def show_last
      puts message
    end

    def success
    @message = "Successfully bought: #{calculator.selection}.\n"\
    "Paid: #{display_price(calculator.money_paid.total_value)}.\n"\
    "Change: #{display_price(change)}"
    puts message
    end

    def write_message(msg)
      puts @message = msg
    end

    def in_progress
      puts @message = "Please insert: #{display_price(calculator.shortfall)}"
    end

    def no_change
      puts @message = 'Insufficient change available, please use an exact amount.'
    end

    def welcome
      puts @message = 'Welcome. Please select a product'
    end

    def select_product       
      puts @message = 'Please select a product first.'
    end

    def money_paid
      puts @message = "Paid In: #{display_price(calculator.money_paid.total_value)}"
    end

    def out_of_stock(product_name)
      puts @message = "#{product_name} is currently out of stock."
    end

    def selected_product(product)
      puts @message = "Selected #{product.name}. Please insert at least #{display_price(product.value)}."
    end

    def invalid_product_selection
      puts @message = 'Invalid Selection: Please choose from available products.'
    end

    private

    def change
      calculator.change ? calculator.change.total_value : 0
    end

    def display_price(price)
      display_price = format "£%.2f", price.to_f / 100
    end
  end
end