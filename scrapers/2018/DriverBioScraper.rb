class DriverBioScraper
    attr_reader :driver_bios

    def initialize(driver_bios)
        @driver_bios = driver_bios
    end

    def parse_bios
        [:bio, :yearByYear].each_with_object({}) { |bio_type, parsed_bios|
            bio_html = driver_bios[bio_type]

            if bio_html
                doc = Nokogiri::HTML(bio_html)
                paragraphs = doc.css('div.parbase')

                text = paragraphs.map { |par|
                    par.children.map { |child|
                        child.text.strip
                    }.join("\n")
                }.join("\n")

                parsed_bios[bio_type] = text
            end
        }
    end
end