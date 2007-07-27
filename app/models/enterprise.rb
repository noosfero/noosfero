#A enterprise is a kind of profile. According to the system concept, only enterprises can offer priducts/services
class Enterprise < Profile

  validates_numericality_of :foundation_year, :only_integer => true
end
