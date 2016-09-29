require 'open-uri'
require 'csv'
require 'sqlite3'

class Extractor

  def initialize(url = "https://data.cityofnewyork.us/api/views/43nn-pn8j/rows.csv?accessType=DOWNLOAD")
    @url = url
    @results = []
  end

  def download_records
    File.open("temp.csv", "wb") do |saved_file|
      puts 'downloading, please be patient as this may take a few minutes...'
      open(@url, "rb") do |read_file|
        saved_file.write(read_file.read)
      end
      puts 'download complete!'
    end
  end

  def build_results_array
    puts "scanning records and distilling data"
    CSV.foreach("temp.csv", :headers => true) do |csv_obj|
      @results << transform_data(csv_obj.to_h)
    end
    puts "completed building array of #{@results.length} records."
  end

  def transform_data(row)
    sanitize_input(row)
    add_full_address(row)

    return row
  end

  def sanitize_input(row)
    row.each do |k,v|
      v ||= "NULL"
      v.gsub("'", "''")
      k.gsub(" ", "_")
    end
  end

  def add_full_address(row)
    row['ADDRESS'] = "#{row['BUILDING']} #{row['STREET']} #{row['BORO']}, NY #{row['ZIPCODE']}"
  end

end

extractor = Extractor.new()
# extractor.download_records
extractor.build_results_array
