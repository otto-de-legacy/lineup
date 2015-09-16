require 'pxdoppelganger'

class Comparer

  attr_accessor :difference

  def initialize(base, new, baseurl, urls, resolutions, screenshot_path)
    @base = base
    @new = new
    @baseurl = baseurl
    @urls = urls
    @resolutions = resolutions
    @absolute_image_path = screenshot_path
    compare_images
  end

  private

  def compare_images
    self.difference = []
    @urls.each do |page|
      @resolutions.each do |width|
        puts 'START'
        base_name = Recorder.filename(@absolute_image_path, page, width, @base)
        new_name = Recorder.filename(@absolute_image_path, page, width, @new)
        puts base_name
        puts new_name
        images = PXDoppelganger::Images.new(
            base_name,
            new_name
        )
        puts images.difference
        images.save_difference_image base_name
        self.difference << images.difference
      end
    end
  end

end