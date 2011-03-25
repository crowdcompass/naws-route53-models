require 'naws-route53'

module Naws
  module Route53
    module Models
      class << self
        attr_reader :context
        def initialize_context(*args)
          @context = Naws::Route53::Context.new(*args)
        end
      end
    end
  end
end

require 'naws-route53-models/hosted_zone'
