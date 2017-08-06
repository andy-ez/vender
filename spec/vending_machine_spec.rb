RSpec.describe VendingMachine do
  let(:vending_machine) { described_class.new }
  let(:default_products) { %w[Snickers Mars Twix Crisps Fanta Coke Sprite Gum] }
  it 'has an initial load of products' do
    expect(vending_machine.available_products.keys).to match_array(default_products)
  end

  it 'has an initial product quantity of 10 per item' do
    expect(vending_machine.available_products.values).to match_array([10] * 8)
  end

  it 'can returns the total quantity of products' do
    expect(vending_machine.total_quantity).to eq(80)
  end

  it 'can remove a product' do
    vending_machine.remove_product('Snickers', 1)
    expect(vending_machine.available_products['Snickers']).to eq(9)
  end

  it 'can add a new product' do
    vending_machine.remove_product('Snickers', 10)
    vending_machine.add_product(Components::Product.new('New Chocolate', 190), 10)
    expect(vending_machine.available_products['New Chocolate']).to eq(10)
  end

  it 'has an initial load of coins' do
    expect(vending_machine.total_change).to be > 0
  end
end
