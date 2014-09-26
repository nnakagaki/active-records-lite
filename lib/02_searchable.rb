require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)

    where_str = ""
    params.each do |key, value|
      unless value == 0
        value = "'#{value.to_s}'" if value.to_s.to_i == 0
      end
      where_str += "#{key.to_s} = #{value} AND "
    end
    where_str = where_str[0..-6]

    if query_stack.strip[0] == "S"
      self.query_stack << " AND " + where_str
    else
      self.query_stack << (<<-SQL.chomp)
      SELECT
      *
      FROM
      #{self.table_name}
      WHERE
      #{where_str}
      SQL
    end

    result = DBConnection.execute(query_stack)

    self.parse_all(result)
  end

  def query_stack
    @stack ||= ""
  end
end

class SQLObject
  extend Searchable
end
