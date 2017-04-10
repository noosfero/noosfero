require 'csv'

class Noosfero::FriendlyMIME
  VERSION = '1.0.2'

  class << self
    attr_accessor :mimes

    # Loads all mime names and extensions to a memory
    #
    def load
      self.mimes = {}
      CSV.foreach(File.expand_path(File.join(File.dirname(__FILE__), 'mimes.csv')), :headers => false) do |row|
        self.mimes[row[0]] = row[2]
      end
    end

    # Finds MIME friendly name by extension or MIME type
    #
    # @example
    #   Friendly::MIME.find 'application/zip'
    #
    #   or
    #
    #   Friendly::MIME.find '.zip'
    #
    def find(mime)
      return nil if mime.nil?
      self.mimes[mime.to_s.downcase] || '.'+mime.split('/').last
    end
  end
end

Noosfero::FriendlyMIME.load
