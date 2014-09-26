require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  attr_reader :foreign_key, :primary_key, :class_name

  def initialize(name, options = {})
    default = { foreign_key: "#{name}_id".to_sym,
                primary_key: :id,
                class_name: "#{name}".camelcase.singularize}

    options = default.merge(options)

    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    default = { foreign_key: "#{self_class_name}_id".underscore.to_sym,
                primary_key: :id,
                class_name: "#{name}".camelcase.singularize}

    options = default.merge(options)

    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    define_method(name) do
      @options = BelongsToOptions.new(name, options)
      @options.model_class.find(self.attributes[@options.foreign_key])
    end

    assoc_options[name] = BelongsToOptions.new(name, options)
  end

  def has_many(name, options = {})
    define_method(name) do
      @options = HasManyOptions.new(name, self.class, options)
      @options.model_class.where(
        @options.foreign_key => self.attributes[@options.primary_key])
    end
  end

  def assoc_options
    @relation_attr ||= {}
  end
end

class SQLObject
  extend Associatable
end
