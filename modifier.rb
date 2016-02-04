require_relative 'lib/combiner'
require_relative 'lib/performance_data_getter'
require_relative 'lib/csv_helper'
require_relative 'lib/core_extensions/string'
require_relative 'lib/core_extensions/float'

class Modifier

	KEYWORD_UNIQUE_ID = 'Keyword Unique ID'
	LAST_VALUE_WINS = ['Account ID', 'Account Name', 'Campaign', 'Ad Group', 'Keyword', 'Keyword Type', 'Subid',
                     'Paused', 'Max CPC', 'Keyword Unique ID', 'ACCOUNT', 'CAMPAIGN', 'BRAND', 'BRAND+CATEGORY',
                     'ADGROUP', 'KEYWORD']
	LAST_REAL_VALUE_WINS = ['Last Avg CPC', 'Last Avg Pos']
	INT_VALUES = ['Clicks', 'Impressions', 'ACCOUNT - Clicks', 'CAMPAIGN - Clicks', 'BRAND - Clicks',
                'BRAND+CATEGORY - Clicks', 'ADGROUP - Clicks', 'KEYWORD - Clicks']
	FLOAT_VALUES = ['Avg CPC', 'CTR', 'Est EPC', 'newBid', 'Costs', 'Avg Pos']
  COMMISSION_VALUES = ['number of commissions']
  COMMISSION_VALUES_OTHER = ['Commission Value', 'ACCOUNT - Commission Value', 'CAMPAIGN - Commission Value',
                             'BRAND - Commission Value', 'BRAND+CATEGORY - Commission Value',
                             'ADGROUP - Commission Value', 'KEYWORD - Commission Value']

  LINES_PER_FILE = 120000

	def initialize(saleamount_factor, cancellation_factor)
		@saleamount_factor = saleamount_factor
		@cancellation_factor = cancellation_factor
	end

	def modify(output, input)
		input = sort_by_clicks(input)

		input_enumerator = CSVHelper.lazy_read(input)

    # TODO: Not sure we need that at all
		combiner = Combiner.new do |value|
			value[KEYWORD_UNIQUE_ID]
    end.combine(input_enumerator)

		merger = Enumerator.new do |yielder|
			while true
				begin
					list_of_rows = combiner.next
					merged = combine_hashes(list_of_rows)
					yielder.yield(combine_values(merged))
				rescue StopIteration
					break
				end
			end
    end

    write_file(merger, output)
	end

	private

  def write_file(merger, output)
    done = false
    file_index = 0
    file_name = output.gsub('.txt', '')
    while !done do
      CSV.open(file_name + "_#{file_index}.txt", "wb", { :col_sep => "\t", :headers => :first_row, :row_sep => "\r\n" }) do |csv|
        headers_written = false
        line_count = 0
        while line_count < LINES_PER_FILE
          begin
            merged = merger.next
            unless headers_written
              csv << merged.keys
              headers_written = true
              line_count += 1
            end
            csv << merged
            line_count += 1
          rescue StopIteration
            done = true
            break
          end
        end
        file_index += 1
      end
    end
  end

	def combine_values(hash)
		LAST_VALUE_WINS.each do |key|
			hash[key] = hash[key].last
		end
		LAST_REAL_VALUE_WINS.each do |key|
			hash[key] = hash[key].select {|v| not (v.nil? or v == 0 or v == '0' or v == '')}.last
		end
		INT_VALUES.each do |key|
			hash[key] = hash[key][0].to_s
		end
		FLOAT_VALUES.each do |key|
			hash[key] = hash[key][0].from_german_to_f.to_german_s
		end
    COMMISSION_VALUES.each do |key|
			hash[key] = (@cancellation_factor * hash[key][0].from_german_to_f).to_german_s
		end
    COMMISSION_VALUES_OTHER.each do |key|
			hash[key] = (@cancellation_factor * @saleamount_factor * hash[key][0].from_german_to_f).to_german_s
		end
		hash
	end

	def combine_hashes(list_of_rows)
		keys = []
		list_of_rows.each do |row|
			next if row.nil?
			row.headers.each do |key|
				keys << key
			end
		end
		result = {}
		keys.each do |key|
			result[key] = []
			list_of_rows.each do |row|
				result[key] << (row.nil? ? nil : row[key])
			end
		end
		result
	end

	def sort_by_clicks(file)
    output = "#{file}.sorted"
		content_as_table = CSVHelper.parse(file)
		headers = content_as_table.headers
		index_of_key = headers.index('Clicks')
		content = content_as_table.sort_by { |a| -a[index_of_key].to_i }
		CSVHelper.write(content, headers, output)
    output
	end
end

# Note: un-refactored code had a bug when the file with strict data was rendered
# I've fixed it by reading actually latest data file for project.
modified = input = PerformanceDataGetter.latest_for_project('project_2012-07-27_*')
modification_factor = 1
cancellation_factor = 0.4
modifier = Modifier.new(modification_factor, cancellation_factor)
modifier.modify(modified, input)

puts "DONE modifying"
