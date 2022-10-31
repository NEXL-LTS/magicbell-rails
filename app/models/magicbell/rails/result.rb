module Magicbell
  module Rails
    class Result < ApplicationRecord
      belongs_to :notification
    end
  end
end
