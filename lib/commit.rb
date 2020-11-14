class Commit
  attr_accessor :sha1, :message

  def initialize(sha1)
    @sha1 = sha1
    @message = `git show -s --format=%s #{@sha1}`.strip
  end

  def sha1_short
    sha1[0..6]
  end

  def to_s
    [commit_head, changes]
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

  private

  def commit_head
    "### [[#{sha1_short}]](#{commit_link}) **#{message}**"
  end

  def commit_link
    "https://github.com/gifttalentos/gift/commit/#{sha1}"
  end
end
