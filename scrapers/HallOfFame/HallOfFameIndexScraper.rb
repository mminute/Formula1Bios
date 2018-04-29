require 'nokogiri'
require_relative '../../utils/StripSeasons'
require_relative '../../utils/ReplaceOddCharacters'

class HallOfFameIndexScraper
    attr_reader :doc

    def initialize(indexFile)
        html = indexFile
        @doc = Nokogiri::HTML(html)
    end

    def find_drivers
        doc.css('div.group.article-columns a').map { |node|
            primaryKey =
                replace_odd_chars(
                    strip_seasons(node.css('h4').text))
                .downcase.strip.gsub(/\s+/, '-')
                
            {
                primaryKey: primaryKey,
                hallOfFameUrl: node.attributes['href'].value,
            }
        }
    end
end
