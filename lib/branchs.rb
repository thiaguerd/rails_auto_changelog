class Branchs
  include Base

  attr_accessor :commits

  def initialize(commits)
    @commits = commits
  end

  def to_s
    out = ['## Branchs', '']
    out << table_head
    out << table_separator
    commits.each do |commit|
      out << table_content(commit)
    end
    out << ''
    out
  end

  private

  def table_head
    "| #{'PR'.ljust(max_id_size)}| #{'Name'.ljust(max_name_size)}|"
  end

  def table_content(commit)
    "| #{pr_id(commit).ljust(max_id_size)}| #{commit.original_branch.ljust(max_name_size)}|"
  end

  def table_separator
    "|#{'-'.ljust(max_id_size + 1, '-')}|#{'-'.ljust(max_name_size + 1, '-')}|"
  end

  def max_id_size
    commits.collect { |x| pr_id(x).size }.max + 1
  end

  def max_name_size
    commits.collect { |x| x.original_branch.size }.max + 1
  end

  def pr_id(commit)
    id = commit.message.scan(/\d{1,}/).first
    "[##{id}](#{repo_url}/pull/#{id})"
  end
end
