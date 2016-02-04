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

	def initialize(modification_factor:, cancellation_factor:)
		@modification_factor = modification_factor
		@cancellation_factor = cancellation_factor
	end

	def modify(output, input)
		input = write_sorted_by_clicks(input)

		input_enumerator = CSVHelper.lazy_read(input)

    elements = input_enumerator.map { |el| combine_values(el.to_hash) }

    write_output(elements, output)
	end

	private

  def write_output(elements, output)
    file_name = output.gsub('.txt', '')
    elements.each_slice(LINES_PER_FILE).with_index do |values, index|
      CSVHelper.write(values, elements.first.keys, file_name + "_#{index}.txt")
    end
  end

	def combine_values(hash)
		LAST_VALUE_WINS.each do |key|
			hash[key] = hash[key]
		end
		LAST_REAL_VALUE_WINS.each do |key|
			hash[key] = hash[key]
		end
		INT_VALUES.each do |key|
			hash[key] = hash[key].to_s
		end
		FLOAT_VALUES.each do |key|
			hash[key] = hash[key].from_german_to_f.to_german_s
		end
    COMMISSION_VALUES.each do |key|
			hash[key] = (@cancellation_factor * hash[key].from_german_to_f).to_german_s
		end
    COMMISSION_VALUES_OTHER.each do |key|
			hash[key] = (@cancellation_factor * @modification_factor * hash[key].from_german_to_f).to_german_s
		end
		hash
	end

	def write_sorted_by_clicks(file)
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
modifier = Modifier.new(modification_factor: 1, cancellation_factor: 0.4)
modifier.modify(modified, input)

puts "DONE modifying"
