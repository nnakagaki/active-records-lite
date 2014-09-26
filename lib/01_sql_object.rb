require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    table = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    table[0].map { |entry| entry.to_sym }
  end

  def initialize(params)
    p "hello"
    p params
    params.each do |attr_name, value|
      attr_sym = attr_name.to_sym
      unless self.columns.include?(attr_sym)
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  # def attributes
  #   unless instance_variable_get(:@attributes)
  #     instance_variable_set(:@attributes, Hash.new)
  #   end
  #
  #   instance_variable_get(:@attributes)
  # end

  def self.finalize!
    define_method(:attributes) do
      unless instance_variable_get(:@attributes)
        instance_variable_set(:@attributes, Hash.new)
      end

      instance_variable_get(:@attributes)
    end

    self.columns.each do |column|
      define_method(column) do
        attributes = instance_variable_get(:@attributes)
        attributes[column]
      end
    end

    self.columns.each do |column|
      define_method("#{column}=".to_sym) do |arg|
        attributes
        attribute = instance_variable_get(:@attributes)
        attribute[column] = arg
        instance_variable_set(:@attributes, attribute)
      end
    end
  end

  def self.table_name=(table_name)
    instance_variable_set(:@table_name, table_name)
  end

  def self.table_name
    current_table_name = instance_variable_get(:@table_name)

    if current_table_name
      current_table_name
    else
      instance_variable_set(:@table_name, "#{self}".tableize)
    end
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # ...
  end

  def attributes
    # ...
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
