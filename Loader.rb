require 'sqlite3'

class Loader
  def initialize(data = [])
    @data = data
    setup_db if !database_exists?
  end

  def setup_db
    puts 'creating database.'
    SQLite3::Database.new( "development.sqlite3" ) do |db|
      db.execute(
      "CREATE TABLE `dohmh_inspections` (
        `camis` int(10) NOT NULL,
        `dba` varchar(255) DEFAULT NULL,
        `address` varchar(255) DEFAULT NULL,
        `boro` varchar(255) DEFAULT NULL,
        `building` int(10) NOT NULL,
        `street` varchar(255) DEFAULT NULL,
        `zipcode` int(10) NOT NULL,
        `phone` varchar(10) DEFAULT NULL,
        `action` varchar(255) DEFAULT NULL,
        `violation_code` varchar(255) DEFAULT NULL,
        `violation_description` varchar(255) DEFAULT NULL,
        `critical_flag` varchar(255) DEFAULT NULL,
        `cuisine_description` varchar(255) DEFAULT NULL,
        `inspection_date` date NOT NULL,
        `score` int(10) DEFAULT NULL,
        `grade` varchar(10) DEFAULT NULL,
        `grade_date` date DEFAULT NULL,
        `inspection_type` varchar(255) DEFAULT NULL,
        `record_date` date DEFAULT NULL,
        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (camis, inspection_date, violation_code)
      );")
    end
  end

  def database_exists?
    SQLite3::Database.new( "development.sqlite3" ) do |db|
      result = db.execute("SELECT name FROM sqlite_master WHERE name='dohmh_inspections'")
      return result.length < 1 ? false : true
    end
  end

  def delete_db
    puts "deleting database."
    SQLite3::Database.new( "development.sqlite3" ) do |db|
      db.execute('DROP TABLE dohmh_inspections')
    end
  end

  def update_database
    puts 'inserting records into database.'
    SQLite3::Database.new( "development.sqlite3" ) do |db|
      record_values.each_slice(100) do |chunk|
        db.execute("INSERT OR REPLACE INTO dohmh_inspections
        #{keys_for_rows}
        VALUES #{chunk.join(', ')};")
      end
    end

  end

  def keys_for_rows
    "(#{@data.first.keys.join(', ')})"
  end

  def record_values
    values = []
    @data.each do |row|
      values << "(#{row.values.map{|v| "'#{v}'" }.join(', ')})"
    end
    values
  end

end
