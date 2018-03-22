def strip_seasons(str)
    fixed_string = str
    [/\d{4}\–\d{4}/, /\d{4}/, /,/].each { |regularExp|
        fixed_string = fixed_string.gsub(regularExp, '').strip
    }

    fixed_string
        .gsub(/\s*-\s*$/, '')
        .gsub(/-$/, '').strip
end