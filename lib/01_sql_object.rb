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

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        attributes = instance_variable_get(:@attributes)
        attributes[column]
      end
    end

    self.columns.each do |column|
      define_method("#{column}=".to_sym) do |arg|
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
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map do |result|
      new_result = {}
      result.each do |key, value|
        new_result[key.to_sym] = value
      end

      self.new(new_result)
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        ? == id
    SQL

    self.parse_all(result)[0]
  end

  def initialize(params = {})
    @attributes = params
    params.each do |attr_name, value|
      attr_sym = attr_name.to_sym
      unless self.class.columns.include?(attr_sym)
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    unless instance_variable_get(:@attributes)
      instance_variable_set(:@attributes, Hash.new)
    end

    instance_variable_get(:@attributes)
  end

  def attribute_values
    instance_variable_get(:@attributes).values
  end

  def insert
    ids = DBConnection.execute(<<-SQL)
      SELECT
        id
      FROM
        #{self.class.table_name}
    SQL

    next_id = ids[-1].values[0] + 1
    self.id = next_id

    attribute_key_string = "(" + "#{self.attributes.keys.map(&:to_s)}"[1..-2] + ")"
    attribute_key_string.gsub!("\"","\'")

    question_str = "(" + (["?"] * attribute_values.count).join(",") + ")"

    DBConnection.execute(<<-SQL,attribute_values)
      INSERT INTO
        #{self.class.table_name} #{attribute_key_string}
      VALUES
        #{question_str}
    SQL
  end

  def update
    my_id = self.id

    set_str = ""
    self.attributes.each do |key, value|
      next if key == :id
      unless value == 0
        value = "'#{value.to_s}'" if key.to_s.to_i == 0
      end

      set_str += "#{key.to_s} = #{value}, "
    end
    set_str = set_str[0..-3]

    DBConnection.execute(<<-SQL, my_id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_str}
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id
      update
    else
      insert
    end
  end
end
