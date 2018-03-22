def create_dir_if_needed(dir)
    if !Dir.exist?(dir)
        Dir.mkdir(dir)
    end
end