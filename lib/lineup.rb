require 'rubygems'
require_relative 'controller/browser'
require_relative 'controller/comparer'

module Lineup

  attr_accessor :difference

  class Screenshot

    def initialize(baseurl)

      # the base URL is the root url (in normal projects the frontpage or for us storefront)
      # while the base url is passed in, defaults for other values are set, too
      #
      # for us the base url is https://www.otto.
      #
      # the base url needs to be a string and cannot be an empty sting

      raise "base URL needs to be a string" unless baseurl.is_a? String
      raise "base URL is needed, cannot be empty" if baseurl == ''

      @baseurl = baseurl

      # the urls are combined with the root url and give the absolute url of the pages to be tested
      # see more in the according method below
      # the default value is the baseurl itself, represented by a forward slash

      urls('/')

      # the resolutions can be as many as desired, we use a mobile, a tablet and a desktop resolution
      # by default this is 640px, 800px and 1180px width
      # see more in the according method below

      resolutions('640, 800, 1180')

      # this sets the path where to store the screenshots, by default this is the current directory
      # see more in the according method below

      filepath_for_images("#{Dir.pwd}/screenshots")

      # using selenium in a headless environment vs firefox.
      # by default in headless
      # see more in according method below

      use_headless(true)

      # this is the path where to save the difference images of two not alike screenshots
      # by default the current directory, like for the other images
      # see more in according method below

      difference_path("#{Dir.pwd}/screenshots")
    end


    def urls(urls)

      # all urls to be tested are defined here
      # they need to be passed as a comma separated string (with or without whitespaces)
      #
      # e.g "/, /multimedia, /sport"
      #
      # if it is not a string or the string is empty an exception is raised

      raise "url for screenshots needs to be a string" unless urls.is_a? String
      raise "url for screenshots cannot be <empty string>" if urls == ''

      # after the base screenshots are taken, the urls cannot be changed, an exception would be raised

      raise_base_screenshots_taken('The urls')

      #we remove whitespaces from the urls, replace ; by , and generate an array, splitted by comma

      begin
        @urls= clean(urls).split(",")
      rescue NoMethodError
        raise "urls must be in a comma separated string"
      end
    end



    def resolutions(resolutions)

      # all resolutions to be tested are defined here
      # they need to be passed as a comma separated string (with or without whitespaces)
      #
      # e.g "400, 800, 1200"
      #
      # if its not a string or the string is empty an exception is raised

      raise "resolutions for screenshots needs to be a string" unless resolutions.is_a? String
      raise "the resolutions for screenshot cannot be <empty string>" if resolutions == ''

      # after the base screenshots are taken, the resolutions cannot be changed, an exception would be raised

      raise_base_screenshots_taken('The resolutions')

      #we remove whitespaces from the urls, replace ; by , and generate an array of integers

      begin
        @resolutions = clean(resolutions).split(",").map { |s| s.to_i }
      rescue NoMethodError
        raise "resolutions must be in a comma separated string"
      end
    end



    def filepath_for_images(path)

      # if required an absolute path to store all images can be passed here.
      # at the path a file "screenshots" will be generated
      #
      # e.g '/home/finn/pictures/otto'
      #
      # if its not a string or the string is empty an exception is raised

      raise "path for screenshots needs to be a string" unless path.is_a? String
      raise "the path for the screenshots cannot be <empty string>" if path == ''

      # after the base screenshots are taken, the path cannot be changed, an exception would be raised

      raise_base_screenshots_taken('The path')

      # the path is one string. we just assign the variable
      
      @screenshots_path = path
    end

    
    
    def use_headless(boolean)

      # if required the headless environment can we skipped and firefox used for the screenshots
      #
      # e.g use_headless = false
      #
      # if its not a boolean an exception is raised

      raise "use_headless can only be true or false" unless boolean == !!boolean

      # after the base screenshots are taken, the browser cannot be changed, an exception would be raised

      raise_base_screenshots_taken('The browser type (headless)')

      # sometimes packages are missing on ubuntu to run the headless environment, installing these should resolve it:
      # sudo apt-get install -y xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic xvfb x11-apps  imagemagick

      @headless = boolean
    end



    def difference_path(path)

      # if required an absolute path to store all difference images can be passed here.
      # in most usecases you may want to save them along with the base and new images
      #
      # e.g '/home/finn/pictures/otto'
      #
      # if its not a string or the string is empty an exception is raised

      raise "path for difference images needs to be a string" unless path.is_a? String
      raise "the path for the difference images cannot be <empty string>" if path == ''

      # assign the variable

      @difference_path = path
    end



    def load_json_config(path)

      # loads all possible configs from a json file.
      # in this file all parameters need to be set
      # an example configuration is
      # '{"urls":"/multimedia, /sport","resolutions":"600,800,1200","filepath_for_images":"~/images/","use_headless":true,"difference_path":"#/images/diff"}'

      #open the file and parse JSON format
      configuration = JSON.parse(File.read(path))

      # write to method above
      urls(configuration["urls"])
      resolutions(configuration["resolutions"])
      filepath_for_images(configuration["filepath_for_images"])
      use_headless(configuration["use_headless"])
      difference_path(configuration["difference_path"])

      # the method calls set the variables for the parameters, we return an array with all of them.
      # for the example above it is:
      # [["/multimedia", "/sport"], [600, 800, 1200], "~/images/", true, "#/images/diff"]
      [@urls, @resolutions, @screenshots_path, @headless, @difference_path]
    end



    def record_screenshot(version)

      # to take a screenshot we have all parameters given from the methods above (or set to default values)
      # selenium is started in
      #   @headless or firefox
      # and takes a screenshot of the urls
      #   @baseurl/@url[0], @baseurl/@url[1], etc...
      # and takes a screenshot for each url for all given resolutions
      #   @resolutions[0], @resolutions[1], etc...
      # and saves the screenshot in the file
      #   @screenshot_path

      browser = Browser.new(@baseurl, @urls, @resolutions, @screenshots_path, @headless)

      # the only argument missing is if this is the "base" or "new" screenshot, this can be
      # passed as an argument. The value does not need to be "base" or "new", but can be anything

      browser.record(version)

      # this will close the browser and terminate the headless environment

      browser.end

      # this flag is set, so that parameters like resolution or urls cannot be changed any more

      @got_base_screenshots = true
    end



    def compare(base, new)

      # this compares two previously taken screenshots
      # the "base" and "new" variable need to be the same as previously assigned
      # as "variable" in the method "record_screenshot"!
      # all other information are constants and are passed along

      @comparer = Comparer.new(base, new, @difference_path, @baseurl, @urls, @resolutions, @screenshots_path)

      # this gives back an array, which as one element for each difference image.
      # [ {diff_1}, {diff_2}, ...]
      # while each diff is a hash with keys:
      # {url: <url>, width: <width in px>, difference: <%of changed pixel>, diff_file: <file path>}

      @comparer.difference
    end

    def json(path)

      # json output can be saved if needed. A path is required to save the file

      raise "screenshots need to be compared before json output can be gernerated" unless @comparer

      # the array from @comparer.difference is saved as json

      @comparer.json(path)

    end

  private

    def raise_base_screenshots_taken(value)
      if @got_base_screenshots
        raise ArgumentError, "#{value} cannot be changed after first set of screenshots were taken"
      end
    end

    def clean(urls)
      urls.gsub(' ', '').gsub(';',',')
    end

  end

end
