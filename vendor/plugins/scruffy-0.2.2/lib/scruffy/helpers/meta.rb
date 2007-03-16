module Scruffy::MetaAttributes
    def singleton_class
      (class << self; self; end)
    end
end