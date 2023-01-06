module Magicbell
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace Magicbell::Rails

      config.generators do |g|
        g.test_framework :rspec
      end
    end
  end
end
