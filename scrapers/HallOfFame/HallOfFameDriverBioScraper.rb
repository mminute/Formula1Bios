require 'nokogiri'

class HallOfFameDriverBioScraper
    attr_reader :driver_bio

    def initialize(driver_bio)
        @driver_bio = driver_bio
    end

    def parse_bio
        bio_html = driver_bio[:bio]
        doc = Nokogiri::HTML(bio_html)
        
        strapline_text = doc.css('h5.strapline').text.strip
        paragraphs = doc.css('div.parbase')

        paragraph_text = paragraphs.map { |par|
            par.children.map { |child|
                child.text.strip
            }.join("\n")
        }.join("\n")

        [strapline_text, paragraph_text].join("\n")
    end
end