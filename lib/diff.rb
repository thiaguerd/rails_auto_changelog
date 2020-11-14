class Diff
  attr_accessor :commits, :changes, :options, :branchs

  def initialize(options = {})
    @options = options
    @changes = `git diff --stat=100 #{options[:start]}..#{options[:end]} -- ':!*.md'`
    load_commits
  end

  def to_s
    out = []
    out << changes_to_s
    out << commits_to_s
    out
  end

  private

  def commits_to_s
    commits.collect(&:to_s)
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
