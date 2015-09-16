require 'pxdoppelganger'

class Comparer

  attr_accessor :difference

  def initialize(base, new, difference_path, baseurl, urls, resolutions, screenshot_path)
    @base = base
    @new = new
    @baseurl = baseurl
    @urls = urls
    @resolutions = resolutions
    @absolute_image_path = screenshot_path
    @difference_path = difference_path
    compare_images
  end

  private

  def compare_images
    self.difference = []
    @urls.each do |page|
      @resolutions.each do |width|
        base_name = Recorder.filename(@absolute_image_path, page, width, @base)
        new_name = Recorder.filename(@absolute_image_path, page, width, @new)
        images = PXDoppelganger::Images.new(
            base_name,
            new_name
        )
        if images.difference > 1e-05 # for changes bigger than 1 per 10.000; otherwise we see mathematical artifacts
          diff_name = Recorder.filename(@difference_path, page, width, 'DIFFERENCE')
          images.save_difference_image diff_name
          result = [base_name, new_name, diff_name, images.difference]
          self.difference << result
        end
      end
    end
    difference
  end

end