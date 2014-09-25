class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) { name }
      define_method((name.to_s + "=").to_sym) { |arg| name = arg }
    end
  end
end
