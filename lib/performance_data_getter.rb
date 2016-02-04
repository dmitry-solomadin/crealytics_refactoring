require 'date'

class PerformanceDataGetter

  # Get latest performance data file for the project.
  # Assume file format as: project-#{date}-#{sample_date}_performancedata.txt
  # We sort by <sample_data> and get the latest data file.
  def self.latest_for_project(name)
    files = Dir["#{ENV["HOME"]}/workspace/*#{name}*_performancedata.txt"]

    files.sort_by! do |file|
      last_date = /\d+-\d+-\d+_[[:alpha:]]+\.txt$/.match file
      last_date = last_date.to_s.match /\d+-\d+-\d+/
      DateTime.parse(last_date.to_s)
    end

    raise ArgumentError.new("No files present at #{ENV["HOME"]}/workspace") if files.empty?

    files.last
  end

end