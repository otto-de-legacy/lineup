require 'rubygems'
require_relative 'controller/browser'

module Lineup

  class Screenshot

    def initialize(baseurl)
      @baseurl = baseurl
      urls('/')
      resolutions('640, 800, 1180')
      filepath_for_images("#{Dir.pwd}")
      use_firefox(false)
    end

    def urls(urls)
      @urls= urls.gsub(' ', '').split(",")
    end

    def resolutions(resolutions)
      @resolutions = resolutions.split(",").map { |s| s.to_i }
    end

    def filepath_for_images(path)
      @path = "#{path}/screenshots"
    end

    def use_firefox(boolean)
      @firefox = boolean
    end

    def record_screenshot(version)
      browser = Browser.new(@baseurl, @urls, @resolutions, @path, @firefox)
      browser.record(version)
    end

  end

end
