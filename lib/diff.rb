class Diff
  attr_accessor :commits, :changes, :options, :branchs, :files

  def initialize(options = {})
    @options = options
    @changes = `git diff --stat=100 #{options[:start]}..#{options[:end]} -- ':!*.md'`
    load_commits
    load_files_changed
  end

  def to_s
    out = ["# #{new_version}", '']
    out << changes_to_s
    out << branchs_to_s
    out << commits_to_s
    out << files_changed_to_s
    out
  end

  private

  def new_version
    current_branch = `git branch --show-current`.strip
    split = current_branch.split('/')
    if split.first == 'release'
      split.last
    else
      'x.x.x'
    end
  end

  def files_changed_to_s
    out = []
    roots = files.collect { |file| file.tags.first }
    roots.each do |root|
      out << ["## #{root}"]
      out << files_changed_of_tag(root, 0)
    end
    out
  end

  def files_changed_of_tag(tag, index = 0)
    out = index.zero? ? [] : ['', "### #{tag}"]

    files.select { |x| x.tags[index] == tag }.each do |file|
      next_tag = file.tags[index + 1]
      out << if next_tag
               files_changed_of_tag(next_tag, index + 1)
             else
               file.to_s(options)
             end
    end
    out
  end

  def branchs_to_s
    Branchs.new(commits.select(&:merge?)).to_s
  end

  def load_files_changed
    paths = []
    @files = []
    commits.reject(&:merge?).each do |commit|
      paths += commit.files
    end
    paths.uniq!.each do |path|
      @files << FileChanged.new(path)
    end
  end

  def commits_to_s
    [
      '## Commits',
      '',
      commits.reject(&:merge?).collect(&:to_s)
    ]
  end

  def changes_to_s
    ['## Changes', '', '````', changes, '````', '']
  end

  def load_commits
    @commits = []
    `git rev-list #{options[:start]}..#{options[:end]}`.split("\n").each do |commit_id|
      @commits << Commit.new(commit_id)
    end
  end
end
