module Raix
  class Engine < ::Rails::Engine
    isolate_namespace Raix
    config.generators do |g|
      g.test_framework :rspec
    end  
    initializer 'raix.load_migrations' do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
