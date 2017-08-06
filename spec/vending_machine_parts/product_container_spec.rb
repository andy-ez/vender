RSpec.describe VendingMachineParts::ProductContainer do
  let(:new_container) { described_class.new }
  let(:full_container) do
    {
      'Snickers' => 10,
      'Mars' => 10,
      'Twix' => 10,
      'Crisps' => 10,
      'Fanta' => 10,
      'Coke' => 10,
      'Sprite' => 10,
      'Gum' => 10
    }
  end

  describe '#initialize' do
    it 'creates a new container with public products ivar set to a full container' do
      expect(new_container.products).to eq(full_container)
    end

    it 'sets the max size to a default of 80' do
      expect(new_container.max_size).to eq(80)
    end

    it 'sets the max size to argument if present' do
      big_container = described_class.new(250)
      expect(big_container.max_size).to eq(250)
    end
  end

  describe '#remove_product' do
    context 'with invalid quantity' do
      it 'raises an argumennt error' do
        expect { new_container.remove_product('Something', -19) }.to raise_error(ArgumentError)
      end
    end

    context 'with invalid Product name' do
      it 'raises an argumennt error' do
        expect { new_container.add_product('Something', 19) }.to raise_error(ArgumentError)
      end
    end

    context 'with valid Product name and quantity' do
      context 'when there is enough of the product' do
        it 'removes the quantity of the product' do
          new_container.remove_product('Snickers', 8)
          expect(new_container['Snickers']).to eq(2)
        end

        it 'returns the name of the product removed' do
          expect(new_container.remove_product('Snickers', 8))
            .to eq('Snickers')
        end
      end

      context 'when there is not enough of the product' do
        it 'does not remove the quantity of the product' do
          new_container.remove_product('Snickers', 18)
          expect(new_container['Snickers']).to eq(10)
        end
      end
    end
  end

  describe '#add_product' do
    context 'with invalid quantity' do
      it 'raises an argumennt error' do
        expect { new_container.add_product('Something', -19) }.to raise_error(ArgumentError)
      end
    end

    context 'with invalid Product name' do
      it 'raises an argumennt error' do
        expect { new_container.add_product('Something', 19) }.to raise_error(ArgumentError)
      end
    end

    context 'with valid Product name and quantity' do
      context 'when there is no capacity to add' do
        it 'does not add the quantity of the product' do
          new_container.add_product('Snickers', 19)
          expect(new_container['Snickers']).to eq(10)
        end
      end

      context 'when there is capacity to add' do
        it 'adds the quantity of the product' do
          new_container.remove_product('Twix', 8)
          new_container.add_product('Snickers', 7)
          expect(new_container['Snickers']).to eq(17)
        end

        it 'returns the name of the product added' do
          new_container.remove_product('Twix', 8)
          expect(new_container.add_product('Snickers', 8))
            .to eq('Snickers')
        end
      end

      context 'when adding a non default product' do
        before do
          new_container.remove_product('Twix', 10)
          new_container.add_product(
            Components::Product.new('New Chocolate', 119), 
            7
          )
        end
        it 'adds the quantity of the product' do
          expect(new_container['New Chocolate']).to eq(7)
        end

        it 'adds the products price to the prices ivar' do
          expect(new_container.prices['New Chocolate']).to eq(119)
        end
      end
    end
  end

  describe '#total_quantity' do
    it 'returns the total count of all products' do
      expect(new_container.total_quantity).to eq(80)
    end
  end

  describe '#available_products' do
    let(:available) do
      {
        'Crisps' => 10,
        'Fanta' => 10,
        'Coke' => 10,
        'Sprite' => 10,
        'Gum' => 10
      }
    end
    it 'returns products with quantities greater than 0' do
      new_container.remove_product('Snickers', 10)
      new_container.remove_product('Mars', 10)
      new_container.remove_product('Twix', 10)
      expect(new_container.available_products).to eq(available)
    end
  end

  it 'can be emptied' do
    new_container.empty!
    expect(new_container.products.values).to eq([0] * 8)
  end
end
