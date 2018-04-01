require 'open-uri'
require_relative './scrapers/2018/DriverBioScraper'
require_relative './scrapers/2018/HallOfFameIndexScraper'
require_relative './scrapers/2018/SeasonIndexScraper'
require_relative './utils/CreateDirIfNeeded'

# Env constants
currentDir = Dir.getwd

# Configuration
current_season = '2018'
base_url = 'https://www.formula1.com'
index_url = base_url + '/en/championship/drivers.html'
hall_of_fame_url = base_url + '/en/championship/drivers/hall-of-fame.html'

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

currentSeasonDriverUrls = SeasonIndexScraper.new(season_index_file).find_drivers
# hallOfFameDriverUrls = HallOfFameIndexScraper.new(hall_of_fame_file).find_drivers

create_dir_if_needed(currentDir + "/html/driverBios")

# Create Data directory and season subdirectory to save data to
['data', current_season].each_with_object('') { |name, path|
    create_dir_if_needed(currentDir + path + "/#{name}")
    path << "/#{name}"
}

bio_key_mapping = {
    '/bio.html': :bio,
    '/year_by_year.html': :yearByYear,
}

current_driver_bios = currentSeasonDriverUrls.map { |driver|
    html_destination_dir = currentDir + "/html/driverBios/#{driver[:primaryKey]}"
    # HTML directory
    create_dir_if_needed(html_destination_dir)
    # DATA directory
    data_destination_dir = currentDir + "/data/#{current_season}/#{driver[:primaryKey]}"
    create_dir_if_needed(data_destination_dir)

    driver_html = { primaryKey: driver[:primaryKey] }

    ['/bio.html', '/year_by_year.html'].each { |f|
        destination_file = html_destination_dir + f

        bio_at_main_url = false

        if File.exist?(destination_file)
            driver_html[bio_key_mapping[f.to_sym]] = File.read(destination_file)
        else
            source_url = driver[bio_key_mapping[f.to_sym]]

            bio_file = nil
            begin
                bio_file = open(base_url + source_url).read
            rescue Exception => e
                # If 404, the bio lives on the main page for the driver
                # ex) https://www.formula1.com/en/championship/drivers/charles-leclerc.html
                if f === '/bio.html'
                    bio_at_main_url = true
                end
            end

            if bio_at_main_url
                bio_file = open(base_url + driver[:url]).read
            end
            
            if bio_file
               IO.write(destination_file, bio_file)
               driver_html[bio_key_mapping[f.to_sym]] = bio_file
            end
        end
    }

    driver_html
}

driver_bio_text = current_driver_bios.map { |driver_bios|
    bios = DriverBioScraper.new(driver_bios).parse_bios

    { primaryKey: driver_bios[:primaryKey] }.merge(bios)
}

# Write the bios to a file
driver_bio_text.each { |driver_bios|
    text_destination_dir = currentDir + "/data/#{current_season}/#{driver_bios[:primaryKey]}"

    test_has_bio = []

    [:bio, :yearByYear].each { |bio_type|
        file_destination = text_destination_dir + "/#{bio_type}.txt"
        if driver_bios[bio_type]
            if !File.exist?(file_destination)
                IO.write(file_destination, driver_bios[bio_type])
            end
        else
            test_has_bio << bio_type.to_s
        end
    }

    if test_has_bio.length > 0
        puts driver_bios[:primaryKey]
        puts "MISSING: #{test_has_bio.join(', ')}"
    end
}

# TODO: Download hall of fame bios
# TODO: create_nested_dirs
