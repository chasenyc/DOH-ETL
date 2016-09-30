require 'open-uri'
require 'csv'
require 'sqlite3'

require_relative 'loader'

class Extractor

  def initialize(url = "https://data.cityofnewyork.us/api/views/43nn-pn8j/rows.csv?accessType=DOWNLOAD")
    @url = url
    @results = []
  end

  def extract_transform_and_load
    extract
    transform
    load_into_db
  end

  def extract
    File.open("temp.csv", "wb") do |saved_file|
      puts 'downloading, please be patient as this may take a few minutes...'
      open(@url, "rb") do |read_file|
        saved_file.write(read_file.read)
      end
      puts 'download complete!'
    end
  end

  def transform
    puts "scanning records and transforming data"
    CSV.foreach("temp.csv", :headers => true, :header_converters => lambda { |h| h.downcase.gsub(' ', '_') }) do |csv_obj|
      @results << transform_data(csv_obj.to_h)
      load_into_db if @results.length > 2000
    end
    File.delete("temp.csv")
  end

  def load_into_db
    loader = Loader.new(@results)
    loader.update_database
    @results = []
  end

  def transform_data(row)
    sanitize_input(row)
    add_full_address(row)

    return row
  end

  def sanitize_input(row)
    row['inspection_date'] = row['inspection_date'] ? Date.strptime(row['inspection_date'], '%m/%d/%Y').to_s : row['inspection_date']
    row['grade_date'] = row['grade_date'] ? Date.strptime(row['grade_date'], '%m/%d/%Y').to_s : row['grade_date']
    row['record_date'] = row['record_date'] ? Date.strptime(row['record_date'], '%m/%d/%Y').to_s : row['record_date']
    row.each { |k,v| row[k] =  v ? v.gsub("'", "''") : "NULL" }
  end

  def add_full_address(row)
    row['address'] = "#{row['building']} #{row['street']} #{row['boro']}, NY #{row['zipcode']}"
  end

end
