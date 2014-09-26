require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      p source_options = through_options.model_class.assoc_options[source_name]

      through_one = through_options.model_class.where(
        :id => self.send(through_options.foreign_key))

      result = []
      through_one.each do |each_one|
        result += source_options.model_class.where(
          :id => each_one.send(source_options.foreign_key))
      end

      result[0]

      # does not work for has_many, but works for has_one
      # self.send(through_name).send(source_name)
    end
  end
end
