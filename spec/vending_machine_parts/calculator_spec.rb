RSpec.describe VendingMachineParts::Calculator do
  let(:products) { VendingMachineParts::ProductContainer.new }
  let(:register) { VendingMachineParts::CashRegister.new }
  let(:calculator) { described_class.new(register, products) }

  it 'is initialised with an idle status' do
    expect(calculator.status).to eq(:idle)
  end

  context 'selecting a product' do
    describe '#set_product' do
      context 'with a valid selection and idle status' do
        it 'stores a product in selection' do
          calculator.set_product('Snickers')
          expect(calculator.selection).to be_a Components::Product
        end

        # Allow selecting different products
        it 'does not change status' do
          calculator.set_product('Snickers')
          expect(calculator.status).to eq(:idle)
        end

        it 'stores the correct product' do
          calculator.set_product('Snickers')
          expect(calculator.selection.name).to eq('Snickers')
          expect(calculator.selection.value).to eq(110)
        end

        it 'returns the product' do
          expect(calculator.set_product('Snickers').name).to eq('Snickers')
        end
      end

      context 'when status is not idle' do
        before do 
          calculator.instance_variable_set(:@status, :in_progress)
        end
        it 'does not select a product' do
          calculator.set_product('Snickers')
          expect(calculator.selection).to be nil 
        end

        it 'does not change the selection if one is present' do
          calculator.instance_variable_set(:@selection, 'Current')
          calculator.set_product('Snickers')
          expect(calculator.selection).to eq('Current')
        end

        it 'returns an error message String' do
          expect(calculator.set_product('Snickers'))
            .to eq('A transaction is already in Progress')
        end
      end

      context 'when product does not exist or is finished' do
        it 'does not selcet a product' do
          calculator.set_product('Invalid')
          expect(calculator.selection).to be nil 
        end

        it 'does not change the selection if one is present' do
          calculator.instance_variable_set(:@selection, 'Current')
          calculator.set_product('Invalid')
          expect(calculator.selection).to eq('Current')
        end

        it 'returns an error message String' do
          expect(calculator.set_product('Current'))
            .to eq('Current is not available')
        end
      end
    end
  end

  context 'Processing a transaction' do
    describe '#process_transaction' do
      context 'when no selection is made' do
        it 'returns nil' do
          expect(calculator.process_transaction).to be nil
        end

        it 'does not change status' do
          calculator.process_transaction
          expect(calculator.status).to eq(:idle)
        end
      end

      context 'when an exact amount is inserted' do
        before do
          products.remove_product('Snickers', 5)
          products.add_product(Components::Product.new('New Prod', 100), 5)
          register.add_payment('£1')
          calculator.set_product('New Prod')
        end
        it 'should set the status to success' do
          calculator.process_transaction
          expect(calculator.status).to eq(:success)
        end

        it 'should return true' do
          expect(calculator.process_transaction).to be true
        end
      end

      context 'when too little is inserted' do
        before do
          products.remove_product('Snickers', 5)
          products.add_product(Components::Product.new('New Prod', 110), 5)
          register.add_payment('£1')
          calculator.set_product('New Prod')
        end

        it 'should set the status to in progress' do
          calculator.process_transaction
          expect(calculator.status).to eq(:in_progress)
        end

        it 'should return true' do
          expect(calculator.process_transaction).to be true
        end
      end

      context 'when too much is inserted' do
        context 'when there is not enough change' do
          before do
            register.add_coins('20p', 1)
            register.add_coins('5p', 1)
            products.remove_product('Snickers', 5)
            products.add_product(Components::Product.new('New Prod', 70), 5)
            register.add_payment('£1')
            calculator.set_product('New Prod')
          end
          it 'should set status to no_change' do
            calculator.process_transaction
            expect(calculator.status).to eq(:no_change)
          end

          it 'should return false' do
            expect(calculator.process_transaction).to be false
          end

          it 'should not increase the change variable' do
            calculator.process_transaction
            expect(calculator.change.empty?).to be true
          end
        end

        context 'when there is enough change' do
          before do
            register.fill_register
            products.remove_product('Snickers', 5)
            products.add_product(Components::Product.new('New Prod', 70), 5)
            register.add_payment('£1')
            calculator.set_product('New Prod')
          end
          it 'should set status to success' do
            calculator.process_transaction
            expect(calculator.status).to eq(:success)
          end

          it 'should return true' do
            expect(calculator.process_transaction).to be true
          end

          it 'should have the correct change in the change variable' do
            calculator.process_transaction
            expect(calculator.change.total_value).to eq(30)
          end

          it 'should have change in as few coins as possible' do
            calculator.process_transaction
            change_coin_values = calculator.change.coins
              .select { |_, quantity| quantity > 0 }.keys
            # e.g. change should be 10&20p instead of 15 2ps
            expect(change_coin_values).to match_array(['10p', '20p'])
          end
        end
      end
    end
  end

  describe '#reset' do
    before do
      calculator.instance_variable_set(:@change, 20)
      calculator.instance_variable_set(:@selection, 'Selection')
      calculator.instance_variable_set(:@status, :not_idle)
      calculator.reset
    end

    it 'should set status to idle' do
      expect(calculator.status).to eq(:idle)
    end

    it 'should set selection to nil' do
      expect(calculator.selection).to be nil
    end

    it 'should set change to an empty coin collection' do
      expect(calculator.change). to be_a Components::CoinCollection
      expect(calculator.change.empty?). to be true
    end
  end
end
