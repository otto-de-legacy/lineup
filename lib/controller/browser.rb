require 'watir'
require 'watir-webdriver'
include Selenium
require 'fileutils'
require 'headless'

class Browser

  def initialize(baseurl, urls, resolutions, path, firefox)
    @absolute_image_path = path
    FileUtils.mkdir_p @absolute_image_path
    @baseurl = baseurl
    @urls = urls
    @resolutions = resolutions
    @firefox = firefox
  end

  def record(version)
    browser_loader
    @urls.each do |url|
      @resolutions.each do |width|
        screenshot_recorder(width, url, version)
      end
    end

    @browser.close
    @headless.destroy if @headless
  end

  private

  def browser_loader
    if @firefox
      @browser = Watir::Browser.new :firefox
    else
      @headless = Headless.new
      @headless.start
      @browser = Watir::Browser.start @baseurl
    end
  end

  def screenshot_recorder(width, url, version)
    filename = "#{@absolute_image_path}/#{name(url)}_#{width}_#{version}.png"
    @browser.driver.manage.window.resize_to(width, 1000)
    @browser.cookies.clear
    puts "#{@baseurl}/#{url}"
    @browser.goto("#{@baseurl}/#{url}")
    @browser.screenshot.save( File.expand_path(filename))
  end

  def name(page)
    if page == '/'
      name = 'storefront'
    else #remove forward slash
      name = page.gsub(/\//, "")
    end
    name
  end

end
