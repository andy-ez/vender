RSpec.describe VendingMachine do
  let(:vending_machine) { described_class.new }
  let(:default_products) { %w[Snickers Mars Twix Crisps Fanta Coke Sprite Gum] }
  context 'Default initialization settings' do
    it 'has an initial load of products' do
      expect(vending_machine.available_products.keys).to match_array(default_products)
    end

    it 'loads available chnage to default of 20 coins each' do
      expect(vending_machine.available_change.values).to eq([20] * 8)
    end

    it 'has an initial product quantity of 10 per item' do
      expect(vending_machine.available_products.values).to match_array([10] * 8)
    end
  end

  context 'custom initialization settings' do
    let(:machine) do 
      described_class.new(
        coins: { '£1' => 20, '1p' => 50 },
        max_size: 200
      )
    end
    it 'can accept an initial load of coins' do
      expect(machine.available_change)
        .to eq(Components::CoinCollection.new('£1' => 20, '1p' => 50))
    end

    it 'does not loads available chnage to default' do
      expect(machine.available_change['2p']).to eq(0)
    end

    it 'can set the max_size on container' do
      expect(machine.max_size).to eq 200
    end
  end

  context 'product managment' do
    it 'can return the total quantity of products' do
      expect(vending_machine.total_quantity).to eq 80
    end

    it 'can remove a product' do
      vending_machine.remove_product 'Snickers', 1
      expect(vending_machine.available_products['Snickers']).to eq 9
    end

    it 'can add a new product' do
      vending_machine.remove_product('Snickers', 10)
      vending_machine.add_product(Components::Product.new('New Chocolate', 190), 10)
      expect(vending_machine.available_products['New Chocolate']).to eq 10
    end
  end

  context 'coin managment' do
    # default coin stack value = 7760p
    it 'can return the monetary value of current change in register' do
      expect(vending_machine.total_change).to eq(7760)
    end

    it 'can clear the register' do
      vending_machine.empty_register
      expect(vending_machine.available_change.values).to eq([0] * 8)
    end

    it 'can fill the register with coins' do
      vending_machine.load_change(60)
      expect(vending_machine.available_change.values).to eq([60] * 8)
    end
  end

  context 'making a selection' do
    context 'with valid selection' do
      it 'should have the correct selection made' do
        vending_machine.make_selection('Snickers')
        expect(vending_machine.selection.to_s).to eq 'Snickers'
      end

      it 'should output the name of the selection' do
        machine = described_class.new
        expect(STDOUT).to receive(:puts).with 'Snickers'
        machine.make_selection 'Snickers'
      end
    end

    context 'with invalid selection' do
      it 'should have no selection made' do
        vending_machine.make_selection 'Invalid Product'
        expect(vending_machine.selection).to be nil
      end

      it 'should output invalid product' do
        machine = described_class.new
        expect(STDOUT).to receive(:puts).with 'Invalid Product is not available'
        machine.make_selection 'Invalid Product'
      end
    end

    context 'in middle of transaction' do
      before do
        vending_machine.make_selection 'Snickers'
        vending_machine.make_payment '£1'
      end

      it 'should not change the selection' do
        vending_machine.make_selection 'Mars'
        expect(vending_machine.selection.to_s).to eq 'Snickers'
      end

      it 'should output transaction in progress' do
        expect(STDOUT).to receive(:puts).with 'A transaction is already in Progress'
        vending_machine.make_selection 'Mars'
      end
    end
  end

  context 'making a payment' do
    context 'with valid selection' do
      before do
        vending_machine.make_selection 'Snickers'
        vending_machine.make_payment '£1'
      end
      it 'should add the payment to the money_paid in cash_register' do
        register = vending_machine.instance_variable_get(:@cash_register)
        expect(register.money_paid['£1']).to eq 1
      end

      context 'with invalid coin' do
        it 'should raise an argument error' do
          expect{ vending_machine.make_payment '£3' }.to raise_error ArgumentError
        end
      end
    end

    context 'valid selection with exact payment' do
      before do
        vending_machine.make_selection 'Twix'
      end

      it 'should return an array including the product and an empty coin collection' do
        results = vending_machine.make_payment '£1'
        expect(results[0].to_s).to eq 'Twix'
        expect(results[1].empty?).to be true
      end

      it 'should remove the product from the machine' do
        vending_machine.make_payment '£1'
        expect(vending_machine.available_products['Twix']).to eq(9)
      end

      it 'should add the payment to available change' do
        vending_machine.make_payment '£1'
        expect(vending_machine.available_change['£1']).to eq(21)
      end

      context 'multiple transactions' do
        before do
          6.times do
            vending_machine.make_selection 'Twix'
            vending_machine.make_payment '£1'
          end
        end

        it 'should have the correct product count' do
          expect(vending_machine.available_products['Twix']).to eq(4)
        end

        it 'should have the correct coin count' do
          expect(vending_machine.available_change['£1']).to eq(26)
        end
      end
    end

    context 'valid selection with too little paid' do
      before { vending_machine.make_selection 'Snickers' }

      it 'should return nil' do
        results = vending_machine.make_payment '£1'
        expect(results).to be nil
      end

      it 'should output a prompt to insert the residual amount' do
        output = 'Please insert: £0.10'
        expect(STDOUT).to receive(:puts).with output
        vending_machine.make_payment '£1'
      end
    end

    context 'valid selection with too much paid' do
      context 'with change available' do
        before { vending_machine.make_selection 'Snickers' }
        it 'should return an array containing the product' do
          results = vending_machine.make_payment '£2'
          expect(results[0].to_s).to eq 'Snickers'
        end

        it 'should remove the product from the machine' do
          vending_machine.make_payment '£2'
          expect(vending_machine.available_products['Snickers']).to eq(9)
        end

        it 'should return an array with change in as few coins as possible' do
          results = vending_machine.make_payment '£2'
          expect(results[1]['50p']).to eq 1
          expect(results[1]['20p']).to eq 2
        end

        it 'should remove the change from the cash register' do
          vending_machine.make_payment '£2'
          expect(vending_machine.available_change['50p']).to eq 19
          expect(vending_machine.available_change['20p']).to eq 18
        end

        it 'adds the coin to the register as available change' do
          vending_machine.make_payment '£2'
          expect(vending_machine.available_change['£2']).to eq 21
        end
      end

      context 'with insufficient change available' do
        before do
          vending_machine.empty_register
          vending_machine.make_selection 'Snickers'
        end
        it 'should return nil' do
          results = vending_machine.make_payment '£2'
          expect(results).to be nil
        end

        it 'should output a prompt to alert no change' do
          output = 'Insufficient change available, please use an exact amount.'
          expect(STDOUT).to receive(:puts).with output
          vending_machine.make_payment '£2'
        end

        it 'does not add the coin to the register as available change' do
          vending_machine.make_payment '£2'
          expect(vending_machine.available_change['£2']).to eq 0
        end

        it 'does not remove the productr' do
          vending_machine.make_payment '£2'
          expect(vending_machine.available_products['Snickers']).to eq 10
        end
      end
    end

    context 'with invalid selection' do
      before { vending_machine.make_selection 'Invalid Option' }
      it 'should not add the payment to the cash_register' do
        vending_machine.make_payment '£1'
        register = vending_machine.instance_variable_get(:@cash_register)
        expect(register.money_paid['£1']).to eq 0
      end

      it 'outputs the welcome message' do
        expect(STDOUT).to receive(:puts).with 'Welcome. Please select a product'
        vending_machine.make_payment '£1'
      end
    end
  end

  context 'cancelling a transaction' do
    before do
      vending_machine.make_selection 'Snickers'
      vending_machine.make_payment '£1'
      vending_machine.cancel
    end
    it 'should not add the payment to the cash_register' do
      expect(vending_machine.available_change['£1']).to eq 20
    end

    it 'should not have a current selection' do
      expect(vending_machine.selection).to be nil
    end

    it 'should return the value of the money paid in' do
      vending_machine.make_selection 'Snickers'
      vending_machine.make_payment '£1'
      expect(vending_machine.cancel).to eq(100)
    end
  end

  context 'reading display' do
    it 'can view the last displayed message' do
      vending_machine.make_selection 'Snickers'
      vending_machine.make_payment '£1'
      expect(STDOUT).to receive(:puts).with('Please insert: £0.10')
      vending_machine.read_display
    end
  end
end
