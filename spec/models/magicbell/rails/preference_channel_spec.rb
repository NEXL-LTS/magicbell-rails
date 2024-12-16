# frozen_string_literal: true

require 'rails_helper'

module Magicbell
  module Rails
    RSpec.describe PreferenceChannel do
      describe 'validations' do
        it { is_expected.to validate_presence_of(:slug) }
        it { is_expected.to validate_uniqueness_of(:slug).scoped_to(:preference_category_id) }
        it { is_expected.to validate_inclusion_of(:enabled).in_array([true, false]) }
      end

      describe 'associations' do
        it { is_expected.to belong_to(:preference_category) }
      end

      describe '#to_bell_hash' do
        let(:channel) { create(:preference_channel) }

        it 'returns the correct hash structure' do
          expect(channel.to_bell_hash).to eq(
            slug: channel.slug,
            enabled: channel.enabled
          )
        end
      end
    end
  end
end
