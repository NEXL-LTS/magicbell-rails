# frozen_string_literal: true

require 'rails_helper'

module Magicbell
  module Rails
    RSpec.describe PreferenceCategory do
      describe 'validations' do
        it { is_expected.to validate_presence_of(:slug) }
        it { is_expected.to validate_uniqueness_of(:slug).scoped_to(:notification_preference_id) }
      end

      describe 'associations' do
        it { is_expected.to belong_to(:notification_preference) }
        it { is_expected.to have_many(:channels).class_name('PreferenceChannel').dependent(:destroy) }
      end

      describe '#to_bell_hash' do
        let(:category) { create(:preference_category) }
        let!(:channel) { create(:preference_channel, preference_category: category) }

        it 'returns the correct hash structure' do
          expect(category.to_bell_hash).to eq(
            slug: category.slug,
            channels: [
              {
                slug: channel.slug,
                enabled: channel.enabled
              }
            ]
          )
        end
      end
    end
  end
end
