require 'open-uri'
require_relative './scrapers/2018/DriverBioScraper'
require_relative './scrapers/HallOfFame/HallOfFameDriverBioScraper'
require_relative './scrapers/HallOfFame/HallOfFameIndexScraper'
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
# Filenames
index_filename = index_file_dir + index_dot_html

# Create directories
create_dir_if_needed(index_file_dir)

if File.exist?(index_filename)
    season_index_file = File.read(index_filename)
else
    season_index_file = open(index_url).read
    IO.write(index_file_dir + '/index.html', season_index_file)
end

currentSeasonDriverUrls = SeasonIndexScraper.new(season_index_file).find_drivers

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

driver_bio_texts = current_driver_bios.map { |driver_bios|
    bios = DriverBioScraper.new(driver_bios).parse_bios

    { primaryKey: driver_bios[:primaryKey] }.merge(bios)
}

# Write the bios to a file
driver_bio_texts.each { |driver_bios|
    text_destination_dir = currentDir + "/data/#{current_season}/#{driver_bios[:primaryKey]}"

    missing_bios = []

    [:bio, :yearByYear].each { |bio_type|
        file_destination = text_destination_dir + "/#{bio_type}.txt"
        if driver_bios[bio_type]
            if !File.exist?(file_destination)
                IO.write(file_destination, driver_bios[bio_type])
            end
        else
            missing_bios << bio_type.to_s
        end
    }

    if missing_bios.length > 0
        puts driver_bios[:primaryKey]
        puts "MISSING: #{missing_bios.join(', ')}"
    end
}

# ========================================================
# ========================================================
# HALL OF FAME DRIVER BIOS
# ========================================================
# ========================================================

# Directories
hall_of_fame_file_dir = currentDir + "/html/indexFiles/hallOfFame"
hall_of_fame_filename = hall_of_fame_file_dir + index_dot_html
# Create directory
create_dir_if_needed(hall_of_fame_file_dir)

# Create Hall of Fame directories
['html', 'data'].each { |subDir|
    create_dir_if_needed(currentDir + "/#{subDir}/HallOfFame")
}

if File.exist?(hall_of_fame_filename)
    hall_of_fame_file = File.read(hall_of_fame_filename)
else
    hall_of_fame_file = open(hall_of_fame_url).read
    IO.write(hall_of_fame_file_dir + '/index.html', hall_of_fame_file) 
end

hallOfFameDriverUrls = HallOfFameIndexScraper.new(hall_of_fame_file).find_drivers

hall_of_fame_bios = hallOfFameDriverUrls.map { |driver|
    driver_html = { primaryKey: driver[:primaryKey] }

    destination_file = currentDir + "/html/HallOfFame/#{driver[:primaryKey]}.html"

    if File.exist?(destination_file)
        driver_html[:bio] = File.read(destination_file)
    else
        bio_file = open(base_url + driver[:url]).read
        IO.write(destination_file, bio_file)
        driver_html[:bio] = bio_file
    end

    driver_html
}

hall_of_fame_bio_texts = hall_of_fame_bios.map { |driver_bio|
    bio = HallOfFameDriverBioScraper.new(driver_bio).parse_bio

    { primaryKey: driver_bio[:primaryKey], bio: bio }
}

# Write the bios to a file
hall_of_fame_bio_texts.each { |driver_bio|
    text_destination = currentDir + "/data/HallOfFame/#{driver_bio[:primaryKey]}.txt"

    if !File.exist?(text_destination)
        IO.write(text_destination, driver_bio[:bio])
    end
}