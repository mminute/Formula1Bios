require_relative '../../utils/ReplaceOddCharacters'

class SeasonIndexScraper
    attr_reader :doc

    def initialize(indexFile)
        html = indexFile
        @doc = Nokogiri::HTML(html)
    end

    def find_drivers
        doc.css('div.driver-index-teasers a').map { |node|
            url = node.attributes['href'].value
            {
                url: url,
                profileBio: url[0..-6] + '/Biography.html',
                yearByYear:  url[0..-6] + '/Year_by_Year.html',
                primaryKey: replace_odd_chars(
                    node.css('h1.driver-name').text
                    .downcase.strip.gsub(/\s+/, '-')),
            }
        }
    end
end