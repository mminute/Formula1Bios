def write_js_object(ruby_hash)
    formatted = "{"
    ruby_hash.each { |k, v|
        if v.kind_of?(Array)
            val = v
        else
            val = "`#{v.gsub("'", '‘')}`"
        end
        formatted = formatted + " #{k}: #{val},"
    }

    formatted[0..-2] + ' },'
end
