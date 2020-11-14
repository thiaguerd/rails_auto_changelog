class Commit
  include Base

  attr_reader :sha1, :message, :files, :parents, :parent

  def initialize(sha1, parent: true)
    @sha1 = sha1
    @parent = parent
    @message = `git show -s --format=%s #{@sha1}`.strip
    @files = `git diff-tree --no-commit-id --name-only -r #{sha1}`.split("\n")
    load_parents if @parent
  end

  def sha1_short
    sha1[0..6]
  end

  def changes
    content = `git log -1 --stat --oneline #{sha1} -- ':!*.md'`.split("\n")[1..].map(&:strip)
    return if content.empty?

    [
      '',
      '````',
      content,
      '````',
      ''
    ]
  end

  def merge?
    @parents.size == 2 && message.downcase.start_with?('merge ')
  end

  def to_s
    [commit_head, changes]
  end

  def original_branch
    return unless parent

    branch = nil
    `git branch --contains #{parents.last.sha1} `.split("\n").each do |candidate|
      break if branch

      candidate = candidate.strip.split(' ').last
      branch = candidate if message.include?(candidate)
    end

    branch
  end

  private

  def load_parents
    @parents = []
    `git cat-file -p #{sha1} | awk 'NR > 1 {if(/^parent/){print $2; next}{exit}}'`.split("\n").each do |commit_id|
      @parents << Commit.new(commit_id, parent: false)
    end
  end

  def commit_head
    "### [[#{sha1_short}]](#{commit_link}) **#{message}**"
  end

  def commit_link
    "#{repo_url}/commit/#{sha1}"
  end
end
