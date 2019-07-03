# 200% borrowed from https://github.com/waterlink/timecop.cr
# Just to make it pass on crystal 0.29.0 using  `.local` and `.utc`
#
typeof(Time.new)

struct Time
  def self.new
    return previous_def unless Timecop.active?
    Timecop.local
  end

  def self.local(location : Location = Location.local) : Time
    return previous_def unless Timecop.active?
    new
  end

  def self.utc
    return previous_def unless Timecop.active?
    new
  end
end

module Timecop
  extend self

  @@frozen : Time? = nil

  def local(location : Time::Location = Time::Location.local) : Time
    @@frozen || Time.local
  end

  def utc(location : Time::Location = Time::Location.local) : Time
    @@frozen || Time.utc
  end

  def freeze(at)
    @@frozen = at
  end

  def freeze(at, &blk)
    @@frozen = at
    yield
    reset
  end

  def reset
    @@frozen = nil
  end

  def active?
    @@frozen && true
  end
end
