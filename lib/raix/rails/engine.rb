module Raix
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace Raix

      config.autoload_paths << File.expand_path("../app", __FILE__)
    end
  end
end