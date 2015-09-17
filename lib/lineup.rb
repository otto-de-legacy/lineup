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
      # by default the current directory
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
        @urls= urls.clean.split(",")
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
        @resolutions = resolutions.clean.split(",").map { |s| s.to_i }
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

      raise "use_headless can only be true or false" unless path.is_a? Boolean

      # after the base screenshots are taken, the browser cannot be changed, an exception would be raised

      raise_base_screenshots_taken('The browser type (headless)')

      # sometimes packages are missing on ubuntu to run the headless environment, installing these should resolve it:
      # sudo apt-get install -y xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic xvfb x11-apps  imagemagick

      @headless = boolean
    end

    def record_screenshot(version)
      browser = Browser.new(@baseurl, @urls, @resolutions, @screenshots_path, @headless)
      browser.record(version)
      browser.end
      @got_base_screenshots = true
    end

    def difference_path(path)
      @difference_path = path
    end

    def compare(base, new)
      comparer = Comparer.new(base, new, @difference_path, @baseurl, @urls, @resolutions, @screenshots_path)
      comparer.difference
    end

  private

    def raise_base_screenshots_taken(value)
      if @got_base_screenshots
        raise ArgumentError, "#{value} cannot be changed after first set of screenshots were taken"
      end
    end

    def clean
      gsub(' ', '').gsub(';',',')
    end

  end

end
