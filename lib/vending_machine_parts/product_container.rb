module VendingMachineParts
  # container for the actual products sold by the vending machine
  class ProductContainer
    attr_accessor :products, :prices, :max_size
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

    def initialize(max_size = 80)
      @max_size= max_size || 80
      @products = default_container
      @prices = DEFAULT_PRODUCTS.dup
    end

    def [](name)
      products[name]
    end

    def add_product(product, quantity=1)
      if can_add_product?(product, quantity)
        products[product.to_s] += quantity
        product.to_s
      end
    end

    def remove_product(product, quantity=1)
      if can_remove_product?(product, quantity)
        products[product.to_s] -= quantity
        product.to_s
      end
    end

    def restock
      self.products = default_container
    end

    def total_quantity
      products.reduce(0) do |sum, (product, quantity)|
        sum + quantity
      end
    end

    def available_products
      products.select { |_, quantity| quantity > 0 }
    end

    def empty!
      self.products = products.each { |key, _| products[key] = 0 }
    end

    def product_from_name(name)
      price = prices[name]
      Components::Product.new(name, price) if price
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
      total_quantity <= max_size - quantity
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

    def default_container
      DEFAULT_PRODUCTS.each_with_object({}) do |(prod, price), hash|
        hash[prod] = max_size / DEFAULT_PRODUCTS.length
      end
    end
  end
end
