class TestSource < ArcFurnace::Source
  def initialize(rows)
    @rows = rows
    @index = 0
  end
  def empty?
    @index >= @rows.size
  end
  def advance
    @index += 1
  end
  def row
    result = @index < @rows.size ? @rows[@index] : nil
    advance
    result
  end
end
