require 'watir'
require 'watir-webdriver'
include Selenium
require 'fileutils'
require 'headless'
require_relative '../recorder'

class Browser

  def initialize(baseurl, urls, resolutions, path, headless)
    @absolute_image_path = path
    FileUtils.mkdir_p @absolute_image_path
    @baseurl = baseurl
    @urls = urls
    @resolutions = resolutions
    @headless = headless
  end

  def record(version)
    browser_loader
    @urls.each do |url|
      @resolutions.each do |width|
        screenshot_recorder(width, url, version)
      end
    end
  end

  def end
    @browser.close
    @headless.destroy if @headless
  end

  private

  def browser_loader
    if @headless
      @headless = Headless.new
      @headless.start
    end
    @browser = Watir::Browser.new :firefox
  end

  def screenshot_recorder(width, url, version)
    filename = Recorder.filename(@absolute_image_path, url, width, version)
    @browser.driver.manage.window.resize_to(width, 1000)
    @browser.cookies.clear
    url = Recorder.url(@baseurl, url)
    @browser.goto url
    @browser.screenshot.save( File.expand_path(filename))
  end

end
