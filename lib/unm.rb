require "unm/version"
require 'httparty'
require 'nokogiri'
require 'singleton'
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

  class Courses

    include Singleton

    def self.get
      return @catalog if @catalog
      subjects = HTTParty.get("http://catalog.unm.edu/catalogs/2014-2015/subjects-and-courses.xml")["data"]["subjects"]["subject"]
      @catalog = subjects.map do |subject|
        courses = subject["course"]
        name    = subject["subjectName"]
        { name => [courses].flatten.map do |course|
          course_name = name + " " + course["name"]
          course_description = Nokogiri::HTML.parse(HTTParty.get(course["path"])).css('.content > p').first.text rescue course["path"]
          { "name" => course_name, "description" => course_description }
         end }
      end
    end

  end

end
