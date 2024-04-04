# frozen_string_literal: true

module FunctionDispatch
  extend ActiveSupport::Concern

  class_methods do
    attr_reader :functions

    def function(name, description: nil, **parameters, &block)
      @functions ||= []
      @functions << begin
        { type: "function", function: { name:, parameters: { type: "object", properties: {} } } }.tap do |definition|
          definition[:function][:description] = description if description.present?
          parameters.map do |key, value|
            definition[:function][:parameters][:properties][key] = value
          end
        end
      end

      define_method(name) do |arguments|
        if Rails.env.local?
          puts "_" * 80
          puts "FunctionDispatch#function:"
          puts "#{name}(#{arguments})"
          puts "_" * 80
        end
        instance_exec(arguments, &block)
      end
    end
  end
end
