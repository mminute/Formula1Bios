require_relative './WriteJSObject'

def compose_export(driver_bios)
      "module.exports =\n" +
      write_js_object(driver_bios) +
      ";\n"
end