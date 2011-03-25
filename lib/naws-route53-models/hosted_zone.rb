require 'naws-route53-models/base'
require 'naws-route53-models/record_set'

class Naws::Route53::Models::HostedZone < Naws::Route53::Models::Base

  self.mutable_attributes = %w[name caller_reference comment]
  self.immutable_attributes = %w[name_servers]

  model_attributes *attributes

  validates_presence_of :name, :caller_reference

  def name_servers
    # The list API doesn't provide nameservers :(
    if @name_servers.nil? and !new_record? and !@reloading
      reload
      @name_servers
    else
      @name_servers
    end
  end

  def record_sets
    Naws::Route53::Models::RecordSet.all_with_context(context, :zone_id => id)
  end

  def change_record_sets(changes)
    @context.execute :change_resource_record_sets, :zone_id => id, :changes => changes
  end

  protected
  
    def self.build_list_request(context, options)
      Naws::Route53::ListHostedZonesRequest.new(context)
    end

    def build_get_request
      Naws::Route53::GetHostedZoneRequest.new(@context, :zone_id => id)
    end

    def build_create_request
      Naws::Route53::CreateHostedZoneRequest.new(@context, :name => name, :comment => comment, :caller_reference => caller_reference)
    end

    def build_delete_request
      Naws::Route53::DeleteHostedZoneRequest.new(@context, :zone_id => id)
    end
end
