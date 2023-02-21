

require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

def self.find_by_name(name)
  sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
  DB[:conn].execute(sql, name)
end


def self.find_by(attributes)
    attribute, value = attributes.first
    value = value.to_i if value.to_i.to_s == value

    sql = "SELECT * FROM students WHERE #{attribute} = '#{value}'"
    results = DB[:conn].execute(sql)
    results.map do |row|
      {"id" => row[0], "name" => row[1], "grade" => row[2]}
    end
  end

#   The self.find_by method takes an attributes hash as an argument and 
#   returns an array of hashes representing the rows in the students table 
#   where the attribute key matches the attribute value. The method first
#    extracts the first attribute and value pair from the attributes hash
#     using the attributes.first method. It then checks whether the value 
#     is an integer or not by using the to_i.to_s == value check. If the value
#      is an integer, it converts it to an integer using the to_i method.
#      Next, the method constructs an SQL query string using string interpolation.
#       The query string selects all columns from the students table where the column 
#       specified by the attribute key matches the value of the attribute value. The 
#       query string is executed using the execute method on the DB[:conn] object. The 
#       results of the query are stored in the results variable.
#       Finally, the method maps over the results array and converts each row to a hash
#        with keys "id", "name", and "grade". The resulting array of hashes is returned by the method.
#        Note that this implementation assumes that the students table has columns named
#         "id", "name", and "grade". If the table has different column names or a different schema, 
#         the method will need to be modified accordingly.


# value = value.to_i if value.to_i.to_s == value
# This line of code is checking whether the value of 
# the attribute passed in is an integer or not. If the value 
# is an integer represented as a string, the line of code converts
#  it to an actual integer using the to_i method.
#  The to_i.to_s == value comparison checks if the string
#   value is the same as the integer value when it is converted to 
#   a string and back to an integer. If the values are the same, 
#   it means that the string value is an integer and can be converted 
#   to an actual integer value. If the comparison returns false, it means
#    that the string value is not an integer, so it should be passed as is to the SQL query.


end
