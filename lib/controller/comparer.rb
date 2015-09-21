require 'pxdoppelganger'
require 'json'

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

  def json(path)
    generate_json(path)
  end

  private

  def compare_images
    self.difference = []
    @urls.each do |url|
      @resolutions.each do |width|
        base_name = Helper.filename(
            @absolute_image_path,
            url,
            width,
            @base
        )
        new_name = Helper.filename(
            @absolute_image_path,
            url,
            width,
            @new
        )
        images = PXDoppelganger::Images.new(
            base_name,
            new_name
        )
        if images.difference > 1e-03 # for changes bigger than 1 per 1.000; otherwise we see mathematical artifacts
          diff_name = Helper.filename(
              @difference_path,
              url,
              width,
              'DIFFERENCE'
          )
          images.save_difference_image diff_name
          result = [
                    url: url,
                    width: width,
                    difference: images.difference,
                    diff_file: diff_name
          ]
          self.difference << result
        end
      end
    end
  end

  def generate_json(path)
    difference.each do |result|
      json = result.first.to_json
      file = File.open(
          "#{path}/log.json","a"
      )
      file.write(json)
      file.close
    end

  end


end