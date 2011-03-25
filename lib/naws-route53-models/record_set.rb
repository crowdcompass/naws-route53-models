require 'naws-route53-models/base'

class Naws::Route53::Models::RecordSet < Naws::Route53::Models::Base

  # Route53 has no distinct identifier for a single record/record set.
  # Instead, you need the zone ID, record type, and record name.
  # This means you need something like:
  #   ["ZPPJKFJ5B07YQ", "www.example.com", "A"]
  class Identifier < Struct.new(:zone_id, :name, :type)
    
    def initialize(*a)
      if a.first.kind_of?(Array)
        super(*a.first)
      elsif a.first.kind_of?(String)
        super(*a.first.split(/\s+/))
      elsif a.first.kind_of?(self.class)
        super(a.zone_id, a.name, a.type)
      else
        super
      end
    end
    
    def to_params
      {:zone_id => zone_id, :name => name, :type => type}
    end

  end

  self.mutable_attributes = %w[name type ttl records]
  
  attr_reader :id
  def id=(value)
    @id = Identifier.new(value)
  end

  model_attributes *attributes

  def new_record?
    @id.type.nil?
  end

  protected

    def self.build_list_request(context, options)
      context.request :list_resource_record_sets, options
    end

    def build_get_request
      @context.request :list_resource_record_sets, @id.to_params.merge(:maxitems => 1)
    end

    def build_create_request
      @context.request :change_resource_record_sets, :zone_id => @id.zone_id, :changes => [create_change]
    end

    def build_delete_request
      @context.request :change_resource_record_sets, :zone_id => @id.zone_id, :changes => [delete_change]
    end

    def build_update_request
      @context.request :change_resource_record_sets, :zone_id => @id.zone_id, :changes => [delete_change, create_change]
    end

    # Returns a DELETE action for the original state of this object.
    def delete_change
      h = { "action" => "DELETE" }
      h.merge! attributes
      changes.each do |attr, vals|
        h[attr] = vals.first
      end
      h.symbolize_keys
    end

    # Returns a CREATE action for the current state of this object.
    def create_change
      h = { "action" => "CREATE" }
      h.merge!(attributes)
      h.symbolize_keys
    end

    def after_list_build(attrs, options)
      self.id = [options[:zone_id], @name, @type]
    end

end
