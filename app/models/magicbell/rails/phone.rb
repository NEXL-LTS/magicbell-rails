module Magicbell
  module Rails
    class Phone < ApplicationRecord
      belongs_to :recipient
    end
  end
end
