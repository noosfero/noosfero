require File.dirname(__FILE__) + '/../../config/environment'

class AddBirthDateToPerson < ActiveRecord::Migration

  class ConvertDates
    def self.convert(date_string)
      return if date_string.blank?
      return date_string if date_string.kind_of?(Date)
      return unless date_string.kind_of?(String)
      return if date_string =~ /[a-zA-Z]/

      if date_string =~ /^\d\d([^\d]+)\d\d$/
        date_string += $1 + (Date.today.year - 100).to_s
      end

      if date_string =~ /[^\d](\d\d)$/
        year = $1.to_i
        date_string = date_string[0..-3] + (year > (Date.today.year - 2000) ? year + 1900 : year + 2000).to_s
      end

      if ! ((date_string =~ /(\d+)[^\d]+(\d+)[^\d]+(\d+)/) || (date_string =~ /^(\d\d)(\d\d)(\d\d\d\d)$/))
        return nil
      end
      begin
        Date.new($3.to_i, $2.to_i, $1.to_i)
      rescue Exception => e
        nil
      end
    end
  end

  class Person < ActiveRecord::Base
    self.table_name = 'profiles'
    serialize :data, Hash
  end

  def self.up
    add_column :profiles, :birth_date, :date
    offset = 0
    while p = Person.where("type = 'Person'").order(:id).offset(offset).first
      p.birth_date = ConvertDates.convert(p.data[:birth_date].to_s)
      p.save
      offset += 1
    end
  end

  def self.down
    remove_column :profiles, :birth_date
  end
end

if $PROGRAM_NAME == __FILE__
  require File.dirname(__FILE__) + '/../../test/test_helper'

  class ConvertDatesTest <  Test::Unit::TestCase
    SAMPLE = [
      "",
      "06/06/1973",
      "08/02/1981",
      "",
      "06/01/1955",
      "06 de dezembro ",
      "",
      "01/10/2980",
      "06/03/68",
      "21/07/1975",
      "13/11/1985",
      "",
      "17/11/2007",
      "",
      "19/10/1982",
      "",
      "22/07/1973",
      "17/02",
      "",
      "24/03/1966",
      "02-07-62",
      "11/071987",
      "10/01/1978",
      "04/07/1981",
      "",
      "14/06/00",
      "06/05",
      "21/12/1941",
      "04/04",
      "02.01.1956",
      "",
      "06/02/1986",
      "11/03/1981",
      "17.08.1956",
      "",
      "",
      "",
      "14/12/1981",
      "29/10/1962",
      "13/01/1982",
      "14/07/1984",
      "",
      "05/02/1976",
      "",
      "02-07-1962",
      "15/11/1976",
      "06/10/1970",
      "",
      "23/ 12/ 1999",
      "10/05/1972",
      "26/06/1951",
      "19/11/1954",
      "14/03/2002",
      "",
      "",
      "",
      "17/06/1979",
      "07/08/1976",
      "19/09/1990",
      "21/06/1958",
      "",
      "09/10/1968",
      "17/11/1984",
      "21/02/1989",
      "18 de março",
      "",
      "23/03/1984",
      "18/08/1969",
      "01/07/1991",
      "22/02/1981",
      "02/05/1984",
      "",
      "19/10/1988",
      "04 de maio",
      "",
      "",
      "",
      "",
      "25/09/1985",
      "29/04/1991",
      "",
      "21/09/1975",
      "15/06/1976",
      "23/04/1983",
      "15/08/1981",
      "15/06/1972",
      "",
      "",
      "AGOSTO",
      "01/02",
      "",
      "24/10/1980",
      "11/07/1976",
      "",
      "",
      "01/02",
      "",
      "",
      "",
      "",
      "03/09/1982",
      "",
      "",
      "13/03/1985",
      "",
      "",
      "03/10/1974",
      "14.08.1981",
      "",
      "14/11/1979",
      "",
      "",
      "30/07/1981",
      "",
      "",
      "13/09/1979",
      "14/06/1978",
      "05/09/1957",
      "",
      "",
      "03/09/1982",
      "12/01/1987",
      "13/03/1986",
      "9/12/80",
      "21/12/1982",
      "15/12/85",
      "07/05/84",
      "21/10/1983",
      "4/07/1984",
      "17/04/1977",
      "9 junio 86",
      "12 diciembre 1983",
      "25/04/1959",
      "08/08/1972",
      "12/01/1986",
      "13/09/1979",
      "19/01/1986",
      "05/04/1982",
      "24/12/1958",
      "07 / 05 / 1956",
      "02/05/1984",
      "14/06/1980",
      "03/09/1982",
      "12/01/1987",
      "13/03/1986",
      "9/12/80",
      "21/12/1982",
      "15/12/85",
      "07/05/84",
      "21/10/1983",
      "4/07/1984",
      "17/04/1977",
      "9 junio 86",
      "12 diciembre 1983",
      "25/04/1959",
      "08/08/1972",
      "12/01/1986",
      "13/09/1979",
      "19/01/1986",
      "05/04/1982",
      "24/12/1958",
      "07 / 05 / 1956",
      "02/05/1984",
      "14/06/1980"
    ]

    should 'convert with slash' do
      date = AddBirthDateToPerson::ConvertDates.convert('10/01/2009')
      assert_equal [10, 1, 2009], [date.day, date.month, date.year]
    end

    should 'convert with hyphen' do
      date = AddBirthDateToPerson::ConvertDates.convert('10-01-2009')
      assert_equal [10, 1, 2009], [date.day, date.month, date.year]
    end

    should 'convert with dot' do
      date = AddBirthDateToPerson::ConvertDates.convert('10.01.2009')
      assert_equal [10, 1, 2009], [date.day, date.month, date.year]
    end

    should 'convert with slash and space' do
      date = AddBirthDateToPerson::ConvertDates.convert('10/ 01/ 2009')
      assert_equal [10, 1, 2009], [date.day, date.month, date.year]
    end

    should 'convert with empty to nil' do
      date = AddBirthDateToPerson::ConvertDates.convert('')
      assert_nil date
    end

    should 'convert with nil to nil' do
      date = AddBirthDateToPerson::ConvertDates.convert(nil)
      assert_nil date
    end

    should 'convert with two digits 1900' do
      date = AddBirthDateToPerson::ConvertDates.convert('10/01/99')
      assert_equal [10, 1, 1999], [date.day, date.month, date.year]
    end

    should 'convert with two digits 2000' do
      date = AddBirthDateToPerson::ConvertDates.convert('10/01/09')
      assert_equal [10, 1, 2009], [date.day, date.month, date.year]
    end

    should 'convert with two numbers' do
      date = AddBirthDateToPerson::ConvertDates.convert('10/01')
      assert_equal [10, 1, (Date.today.year - 100)], [date.day, date.month, date.year]
    end

    should 'convert to nil if non-numeric date' do
      date = AddBirthDateToPerson::ConvertDates.convert('10 de agosto de 2009')
      assert_nil date
    end

    should 'do nothing if date' do
      date = AddBirthDateToPerson::ConvertDates.convert(Date.today)
      assert_equal Date.today, date
    end

    should 'return nil when not string nor date' do
      date = AddBirthDateToPerson::ConvertDates.convert(1001)
      assert_nil date
    end

    should 'convert date without separators' do
      date = AddBirthDateToPerson::ConvertDates.convert('27071977')
      assert_equal [ 1977, 07, 27] , [date.year, date.month, date.day]
    end

    should 'not try to create invalid date' do
      assert_nil AddBirthDateToPerson::ConvertDates.convert('70/05/1987')
    end

    SAMPLE.each_with_index do |string,i|
      should "convert sample #{i} (#{string})" do
        result = AddBirthDateToPerson::ConvertDates.convert(string)
        assert(result.nil? || result.is_a?(Date))
      end
    end

  end

end
