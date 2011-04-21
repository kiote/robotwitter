module Robotwitter
  class Path
  @@base = nil

  def self.set_base base
    @@base = base
  end

  def self.get_base
    @@base
  end
end
end
