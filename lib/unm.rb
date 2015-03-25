require "unm/version"
require 'httparty'
module Unm

  class Calendar
    BaseUrl = URI 'http://unmevents.unm.edu/Eventlist.aspx'
    Formats = ["CSV", "ICAL", "XML"]

    def initialize(from_date, to_date, format = "CSV")
      @from_date, @to_date   = check_date from_date, to_date
      @format = check_format format
    end

    def get
      build_params
      @calendar ||= HTTParty.get(@url).body
    end

    private

    def build_params
      @url = URI BaseUrl
      @url.query = URI.encode_www_form [["download", "download"],
                                        ["fromdate", @from_date],
                                        ["todate"  , @to_date  ],
                                        ["dlType"  , @format   ]]
    end

    def check_format format
      raise "Unknown format" unless Formats.include? format.upcase
      format.upcase
    end

    def check_date from_date, to_date
      raise "Please do not span more than one year" if to_date - from_date > 365
      raise "to_date must be after from_date"       if from_date > to_date
      [from_date.strftime("%m%d%Y"), to_date.strftime("%m%d%Y")]
    end 

  end

end
