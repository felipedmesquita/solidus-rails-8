require 'spec_helper'

module Spree
  describe Api::InventoryUnitsController, type: :request do

    before do
      stub_authentication!
      @inventory_unit = create(:inventory_unit)
    end

    context "as an admin" do
      sign_in_as_admin!
      let(:variant) { create(:variant) }

      it "gets an inventory unit" do
        get :show, params: { id: @inventory_unit.id }
        expect(json_response['state']).to eq @inventory_unit.state
      end

      it "updates an inventory unit" do
        put :update, params: {
                           id: @inventory_unit.id,
                           inventory_unit: { variant_id: variant.id }
                         }
        expect(json_response['variant_id']).to eq variant.id
      end

      context 'fires state event' do
        it 'if supplied with :fire param' do
          put :update, params: {
                             id: @inventory_unit.id,
                             fire: 'ship',
                             inventory_unit: { variant_id: variant.id }
                           }

          expect(json_response['state']).to eq 'shipped'
        end

        it 'and returns exception if cannot fire' do
          put :update, params: {
                             id: @inventory_unit.id,
                             fire: 'return'
                           }
          expect(json_response['exception']).to match /cannot transition to return/
        end

        it 'and returns exception bad state' do
          put :update, params: {
                             id: @inventory_unit.id,
                             fire: 'bad'
                           }
          expect(json_response['exception']).to match /cannot transition to bad/
        end
      end
    end
  end
end
