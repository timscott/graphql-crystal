class Type
  def self.accepts?(value)
    false
  end
  def self.resolve(args, obj)
    obj
  end
end

class StringType < Type
  def self.accepts?(value : String)
    true
  end
end

class IntegerType < Type
  def self.accepts?(value : Number)
    true
  end
end

class IDType < Type
  def self.accepts?(value : Int)
    true
  end
end

class EnumType(T) < Type
  def self.accepts?(value)
    T.values.map(&.to_s).includes? value
  end
  def self.resolve(value)
    value.to_s
  end
end

# we cant use this type without
# instantiating it due to
# https://github.com/crystal-lang/crystal/issues/4353
class ListType(T) < Type

  def accepts?(values)
    return false unless values.is_a?(Array)
    values.each do |v|
      unless T.accepts?(v)
        return false
      end
    end
    true
  end

  def of_type
    {{@type.type_vars.first}}
  end

  def resolve(selections, obj)
    obj.as(Array).map do |e|
      T.resolve(selections, e).as(GraphQL::ObjectType::Resolvable::ReturnType)
    end.reject do |e|
      !e.is_a?(GraphQL::ObjectType::Resolvable::ReturnType)
    end
  end

end
