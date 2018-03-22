def replace_odd_chars(str)
    empty_string = ""
    chars_to_replace = {
        "'": empty_string,
        ",": empty_string,
        ".": empty_string,
        "á": "a",
        "ä": "a",
        "ç": "c",
        "è": "e",
        "é": "e",
        "í": "i",
        "ñ": "n",
        "ó": "o",
        "ô": "o",
        "ö": "o",
        "ø": "o",
        "ú": "u",
        "ü": "u",
        "š": "s",
    }

    stringified_chars_to_replace = chars_to_replace.keys.map { |s| s.to_s }

    clean_string = []

    str.split(//).each { |ltr|
        if stringified_chars_to_replace.include?(ltr)
            clean_string.push(chars_to_replace[ltr.to_sym])
        else
            clean_string.push(ltr)
        end
    }

    clean_string.join('')
end
