require_relative '../components/product'

module VendingMachine
  # container for the actual products sold by the vending machine
  class ProductContainer
    attr_accessor :products, :prices
    MAX_SIZE = 80 #limit on products container can hold
    DEFAULT_PRODUCTS = {
      'Snickers' => 110,
      'Mars' => 90,
      'Twix' => 100,
      'Crisps' => 210,
      'Fanta' => 160,
      'Coke' => 140,
      'Sprite' => 150,
      'Gum' => 40
    }.freeze

    def initialize
      set_default_container
      @prices = DEFAULT_PRODUCTS.dup
    end

    def [](name)
      products[name]
    end

    def add_product(product, quantity)
      if can_add_product?(product, quantity)
        products[product.to_s] += quantity
      end
    end

    def remove_product(product, quantity)
      if can_remove_product?(product, quantity)
        products[product.to_s] -= quantity
      end
    end

    def restock
      set_default_container
    end

    def total_quantity
      products.reduce(0) do |sum, (product, quantity)|
        sum + quantity
      end
    end

    private

    def can_add_product?(product, quantity)
      handle_errors(product, quantity)
      capacity_for_quantity?(quantity)
    end

    def can_remove_product?(product, quantity)
      handle_errors(product, quantity)
      available_quantity?(product, quantity)
    end

    def handle_errors(product, quantity)
      handle_negative_quantity(quantity)
      handle_missing_product(product)
    end

    def capacity_for_quantity?(quantity)
      total_quantity <= MAX_SIZE - quantity
    end

    def available_quantity?(product, quantity)
      quantity <= products[product]
    end

    def valid_quantity?(quantity)
      quantity.is_a?(Integer) && quantity > 0
    end

    def valid_product?(product)
      products.has_key?(product)
    end

    def handle_negative_quantity(quantity)
      raise(ArgumentError, 'Quantity must be a positive number') unless valid_quantity?(quantity)
    end

    def handle_missing_product(product)
      if product.is_a?(String)
        raise(ArgumentError, "Product Name: #{product} is not recognised") unless valid_product?(product)
      elsif product.is_a? Components::Product
        prices[product.name] = product.value
        products[product.name] = 0
      else
        raise(ArgumentError, "Invalid product")
      end
    end

    def set_default_container
      @products = DEFAULT_PRODUCTS.each_with_object({}) do |(prod, price), hash|
        hash[prod] = 10
      end
    end
  end
end
