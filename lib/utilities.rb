module Utilities

  class Utilities
    # Get a system setting. Always in record 1
    def self.system_setting(key)
      Setting.find('1').send(key)
    end
  end

end
