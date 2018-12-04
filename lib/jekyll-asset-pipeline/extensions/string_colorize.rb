require 'active_support/inflector'
require 'pry'

String.class_eval do

  def colorize(color)
    "\e[#{String.color_codes[color.to_sym] || 0}m#{self}\e[0m"
  end

  class << self
    def colors
      color_codes.keys
    end

    def color_codes
      {
        red: 31,
        green: 32,
        yellow: 33,
        blue: 34,
        magenta: 35,
        cyan: 36
      }
    end
  end
end
