module Base
  def repo_url
    base = `git remote get-url origin`.strip
    base.gsub!(/\.git$/, '')
    if base.start_with? 'http'
      base
    else
      base.gsub!('git@', 'https://')
      base.gsub!('.com:', '.com:/')
    end
  end
end
