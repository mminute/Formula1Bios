def create_dir_if_needed(dir)
    checkedDir = ''
    dir.split('/').each { |subDir|
        if subDir.length > 0
            fullSubdir = checkedDir + '/' + subDir
            if !Dir.exist?(fullSubdir)
                Dir.mkdir(fullSubdir)
            end
            checkedDir = fullSubdir
        end
    }
end
