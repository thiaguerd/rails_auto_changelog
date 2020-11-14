class FileChanged
  attr_accessor :path, :tags

  RULES = [
    { tags: %i[Controller Config],    start: 'config/',             end: '.yml' },
    { tags: %i[Controller Lib],       start: 'lib/',                end: '.rb' },
    { tags: %i[Controller],           start: 'app/controllers/' },
    { tags: %i[DevOps Docker],        end: 'Dockerfile' },
    { tags: %i[JS Packs],             start: 'app/javascript/packs/' },
    { tags: %i[Tests Core],           path: 'spec/spec_helper.rb' },
    { tags: %i[View Pages],           start: 'app/views' },
    { tags: %i[View Pages],           start: 'config/locales/' },
    { tags: %i[View Tests],           start: 'spec/views/',         end: 'spec.rb' },
    { tags: %i[View Translations],    start: 'config/locales/',     end: '.yml' }
  ].freeze

  def initialize(path)
    @path = path
    tag_file
  end

  def to_s(options)
    [
      '',
      "#### #{path}",
      '',
      '````diff',
      `git diff #{options[:start]}..#{options[:end]} #{path}`.split("\n")[4..],
      '````'
    ]
  end

  private

  def tag_file
    RULES.each do |rule|
      next if @tags

      @tags = tag_rule(rule)
    end
    raise "file '#{path}' doesn't have a tag" unless @tags
  end

  def tag_rule(rule)
    return tag_rule_path(rule)      if rule[:path]
    return tag_rule_start_end(rule) if rule[:start] && rule[:end]
    return tag_rule_start(rule)     if rule[:start]
    return tag_rule_end(rule)       if rule[:end]
  end

  def tag_rule_path(rule)
    rule[:tags] if path == rule[:path]
  end

  def tag_rule_end(rule)
    rule[:tags] if path.end_with?(rule[:end])
  end

  def tag_rule_start_end(rule)
    rule[:tags] if path.start_with?(rule[:start]) && path.end_with?(rule[:end])
  end

  def tag_rule_start(rule)
    rule[:tags] if path.start_with?(rule[:start])
  end
end
