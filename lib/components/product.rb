require 'set'

module Components
  # This represents a product with a given name and monetary value (in pence).
  class Product
    attr_reader :value, :name

    def initialize(name, price_in_pence)
      @name = name
      @value = price_in_pence
      handle_invalid_price
    end

    def to_s
      name
    end

    private

    def handle_invalid_price
      raise ArgumentError, "Price must be an integer greater than 0" unless valid_price?
    end

    def valid_price?
      value.is_a?(Fixnum) && value > 0
    end
  end
end
