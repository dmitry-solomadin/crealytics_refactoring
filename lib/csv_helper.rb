require 'csv'

class CSVHelper

  DEFAULT_CSV_OPTIONS = { :col_sep => "\t", :headers => :first_row }

  class << self
    def parse(file)
      CSV.read(file, DEFAULT_CSV_OPTIONS)
    end

    def lazy_read(file)
      Enumerator.new do |yielder|
        CSV.foreach(file, DEFAULT_CSV_OPTIONS) do |row|
          yielder.yield(row)
        end
      end
    end

    def write(content, headers, output)
      CSV.open(output, "wb", { :col_sep => "\t", :headers => :first_row, :row_sep => "\r\n" }) do |csv|
        csv << headers
        content.each { |row| csv << row }
      end
    end
  end

end