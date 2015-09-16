require 'rubygems'
require_relative 'controller/browser'
require_relative 'controller/comparer'

module Lineup

  attr_accessor :difference

  class Screenshot

    def initialize(baseurl)
      @baseurl = baseurl
      urls('/')
      resolutions('640, 800, 1180')
      filepath_for_images("#{Dir.pwd}/screenshots")
      use_headless(false)
      difference_path("#{Dir.pwd}/screenshots")
    end

    def urls(urls)
      raise "url for screenshot cannot be <empty string>" if urls == ''
      raise_base_screenshots_taken('The urls')
      begin
        @urls= urls.gsub(' ', '').split(",")
      rescue NoMethodError
        raise "urls must be in a "
      end
    end

    def resolutions(resolutions)
      raise_base_screenshots_taken('The resolutions')
      @resolutions = resolutions.split(",").map { |s| s.to_i }
    end

    def filepath_for_images(path)
      raise_base_screenshots_taken('The path')
      @screenshots_path = path
    end

    def use_headless(boolean)
      raise_base_screenshots_taken('The browser type (headless)')
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

  end

end
