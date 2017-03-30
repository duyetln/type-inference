class Type; end
class TNum < Type
  def to_s
    "num"
  end
end
class TBool < Type
  def to_s
    "bool"
  end
end

class TVar < Type
  attr_reader :x
  def initialize(x)
    @x = x
  end

  def to_s
    "'#{x}"
  end
end

class TFun < Type
  attr_reader :x
  attr_reader :e
  def initialize(x, e)
    @x = x
    @e = e
  end

  def to_s
    "#{x} -> #{e}"
  end
end

class TList < Type
  attr_reader :t
  def initialize(t)
    @t = t
  end

  def to_s
    "#{t} list"
  end
end
