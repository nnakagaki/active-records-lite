require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)

    where_str = ""
    params.each do |key, value|
      unless value == 0
        value = "'#{value.to_s}'" if key.to_s.to_i == 0
      end

      where_str += "#{key.to_s} = #{value} AND "
    end
    where_str = where_str[0..-6]

    p where_str

    result = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_str}
    SQL

    self.parse_all(result)
  end
end

class SQLObject
  extend Searchable
end
