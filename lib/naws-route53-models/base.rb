require 'active_model'
require 'naws-route53-models'

class Naws::Route53::Models::Base
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  # These shouldn't be publicly writable. I'm thinking about how to change that.
  attr_accessor :id, :context
  attr_reader :response

  def self.inherited(by)
    by.send(:extend, ActiveModel::Naming)
    by.send(:extend, ClassMethods)
  end

  def initialize(attrs = {})
    attrs.each do |name,val|
      if public_attribute?(name)
        send("#{name}=", val)
      end
    end
    @context = Naws::Route53::Models.context
  end

  def reload
    response = @context.execute_request build_get_request
    populate_from_response(response)
  end

  def new_record?
    !id
  end

  def save
    if valid?
      if new_record?
        create_record
      else
        update_record
      end
    else
      false
    end
  end
  
  def destroy
    @context.execute_request build_delete_request
    @id = nil
    self
  end

  # Abducted from AR::Base, sorta
  def inspect
    attributes_as_nice_string = (["id"] + self.class.attributes).collect { |name|
      "#{name}: #{send(name).inspect}"
    }.compact.join(", ")
    "#<#{self.class} #{attributes_as_nice_string}>"
  end

  module ClassMethods
    
    attr_accessor :mutable_attributes, :immutable_attributes

    def attributes
      (mutable_attributes || []) + (immutable_attributes + [])
    end

    def all_with_context(context, options = {})
      response = context.execute_request build_list_request(context)
      response.hosted_zones.map do |hosted_zone|
        new(hosted_zone)
      end
    end

    def all(options = {})
      all_with_context(Naws::Route53::Models.context, options)
    end

    def find(id, find_all_options = {})
      if id == :all
        all(options)
      else
        record = new
        record.id = id
        record.reload
      end
    end

    def find_with_context(context, id)
      record = new_with_context(context)
      record.id = id
      record.reload
    end

    def new_with_context(context, attrs = {})
      record = new(attrs)
      record.context = context
      record
    end

    protected

    def build_list_request(context)
      raise NotImplementedError, "This model does not support list operations"
    end

  end

  protected

    def public_attribute?(name)
      public_methods.include?("#{name}=") or public_methods.include?(:"#{name}=")
    end

    def populate_from_response(response, type = :get)
      @response = response
      self.class.attributes.each do |attr| 
        self.send("#{attr}=", response.send(attr)) if response.respond_to?(attr)
      end
      self
    end

    def create_record
      response = @context.execute_request build_create_request
      populate_from_response(response, :create)
      self
    end

    def update_record
      @context.execute_request build_update_request
      self
    end

    def delete_record
      @context.execute_request build_delete_request
      self
    end

    
    def build_get_request
      raise NotImplementedError, "This model does not support get operations"
    end
    
    def build_create_request
      raise NotImplementedError, "This model does not support create operations"
    end

    def build_update_request
      raise NotImplementedError, "This model does not support update operations"
    end

    def build_delete_request
      raise NotImplementedError, "This model does not support delete operations"
    end

end
