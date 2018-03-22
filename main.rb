require 'open-uri'
require_relative './utils/CreateDirIfNeeded'
require_relative './scrapers/HallOfFameIndexScraper'

# Env constants
currentDir = Dir.getwd

# Configuration
current_season = '2018'
index_url = 'https://www.formula1.com/en/championship/drivers.html'
hall_of_fame_url = 'https://www.formula1.com/en/championship/drivers/hall-of-fame.html'

# Filename suffix
index_dot_html = '/index.html'
# Directories
index_file_dir = currentDir + "/html/indexFiles/#{current_season}"
hall_of_fame_file_dir = currentDir + "/html/indexFiles/hallOfFame"
# Filenames
index_filename = index_file_dir + index_dot_html
hall_of_fame_filename = hall_of_fame_file_dir + index_dot_html

# Create directories
[index_file_dir, hall_of_fame_file_dir].each { |dirName|
    create_dir_if_needed(dirName)
}

if File.exist?(index_filename)
    season_index_file = File.read(index_filename)
else
    season_index_file = open(index_url).read
    IO.write(index_file_dir + '/index.html', season_index_file)
end

if File.exist?(hall_of_fame_filename)
    hall_of_fame_file = File.read(hall_of_fame_filename)
else
    hall_of_fame_file = open(hall_of_fame_url).read
    IO.write(hall_of_fame_file_dir + '/index.html', hall_of_fame_file) 
end

hallOfFameDriverUrls = HallOfFameIndexScraper.new(hall_of_fame_file).find_drivers
