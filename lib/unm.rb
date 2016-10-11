require "unm/version"
require 'httparty'
require 'nokogiri'
require 'singleton'
module Unm

  class Calendar
    BaseUrl = URI('http://unmevents.unm.edu/Eventlist.aspx')
    Formats = ["CSV", "ICAL", "XML"]

    def initialize(from_date, to_date, format = "CSV")
      @from_date, @to_date   = check_date(from_date, to_date)
      @format = check_format(format)
    end

    def get
      build_params
      @calendar ||= HTTParty.get(@url).body
    end

    private

    def build_params
      @url = URI(BaseUrl)
      @url.query = URI.encode_www_form [["download", "download"],
                                        ["fromdate", @from_date],
                                        ["todate"  , @to_date  ],
                                        ["dlType"  , @format   ]]
    end

    def check_format(format)
      raise "Unknown format" unless Formats.include? format.upcase
      format.upcase
    end

    def check_date(from_date, to_date)
      raise "Please do not span more than one year" if to_date - from_date > 365
      raise "to_date must be after from_date"       if from_date > to_date
      [from_date.strftime("%m%d%Y"), to_date.strftime("%m%d%Y")]
    end

  end

  class Courses

    include Singleton

    class << self

      def get
        return @catalog if @catalog
        subjects = HTTParty.get("http://catalog.unm.edu/catalogs/2016-2017/subjects-and-courses.xml")["data"]["subjects"]["subject"]
        @catalog = subjects.map do |subject|
          courses = subject["course"]
          name    = subject["subjectName"]
          { name => [courses].flatten.map do |course|
            course_name = name + " " + course["name"]
            course_page = Nokogiri::HTML.parse(HTTParty.get(URI.escape course["path"])) rescue course["path"]
            course_title = course_page.css('h1').first.text rescue "Error loading course title. check #{{course['path']}}."
            description = course_page.css('.content > p').first.text rescue "Error loading description. Check #{course["path"]}."
            prerequisites = find_prerequisites(course_page) rescue "Error loading prerequisites. Check #{course["path"]}."
            hours = course_page.css('b').text.match(/\(\D*(\d).*\)/)[1].to_i rescue "Error loading hours. Check #{course["path"]}."
            { "name" => course_name, "title" => course_title, "description" => description, "prerequisites" => prerequisites, "hours" => hours }
          end }
        end
      end

      def find_prerequisites(site)
        start  = site.css("hr").first
        finish = site.css("hr")[1]
        prerequisites = []
        until start == finish
          prerequisites << start.text.split("- ").last if start.css('a').any?
          start = start.next_element
        end
        prerequisites
      end

    end

    private_class_method :find_prerequisites

  end

  class Directory

    include Singleton

    BaseUrl = 'http://directory.unm.edu/index.php'

    def self.find(search_term, field = 'uid', exact: false)
      page = HTTParty.post(BaseUrl, body: { search_other_name: field, search_other_value: search_term })
      results = Nokogiri::HTML.parse(page).css('tr').drop(1).map do |row|
        Hash[[:name, :title, :contact].zip(row.css('td').map { |cell| cell.children.map(&:text).reject(&:empty?) })]
      end
      exact ? results.find { |result| result[:contact].any? { |email| email.split('@').first == search_term } } : results
    end

  end

  class BarRole
    include Singleton

    def self.check(candidate, bar_role = "STU_GEN_RPTS_COHORT_ANALYTICS")
      base_uri = "http://baa.unm.edu/rest/auth/netid/"
      auth =  { username: Unm.configuration.netid, password: Unm.configuration.password }
      HTTParty.get(URI.join(base_uri, candidate + "/", "accessRole/", bar_role), basic_auth: auth).body == "Y"
    end

  end

  class Configuration
    attr_accessor :netid, :password
  end


  class << self

    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

  end

end
