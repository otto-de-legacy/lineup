require 'watir'
require 'watir-webdriver'
include Selenium
require 'fileutils'
require 'headless'
require_relative '../helper'

class Browser

  def initialize(baseurl, urls, resolutions, path, headless, wait, cookie = false)
    @absolute_image_path = path
    FileUtils.mkdir_p @absolute_image_path
    @baseurl = baseurl
    @urls = urls
    @resolutions = resolutions
    @headless = headless
    @wait = wait
    @cookie = cookie
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
    begin #Timeout::Error
      Timeout::timeout(10) { @browser.close }
    rescue Timeout::Error
      browser_pid = @browser.driver.instance_variable_get(:@bridge).instance_variable_get(:@service).instance_variable_get(:@process).pid
      ::Process.kill('KILL', browser_pid)
      sleep 1
    end
    sleep 5 # to prevent xvfb to freeze
  end

  private

  def browser_loader
    if @headless
      @browser = Watir::Browser.new :phantomjs
    else
      @browser = Watir::Browser.new :firefox
    end
  end

  def screenshot_recorder(width, url, version)
    filename = Helper.filename(@absolute_image_path, url, width, version)
    @browser.driver.manage.window.resize_to(width, 1000)

    url = Helper.url(@baseurl, url)
    @browser.goto url
    if @cookie
      @browser.cookies.clear
      @browser.cookies.add(@cookie[:name], @cookie[:value], domain: @cookie[:domain], path: @cookie[:path], expires: Time.now + 7200, secure: @cookie[:secure])
      @browser.goto url
    end
    sleep @wait if @wait
    @browser.screenshot.save( File.expand_path(filename))
  end

end
