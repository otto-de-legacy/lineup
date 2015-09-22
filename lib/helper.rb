module Helper
  extend self

  def filename(path, url, width, version)
    "#{path}/#{version}_#{name(url)}_#{width}.png"
  end

  def url(base, url)
    ("#{base}/#{clean(url)}")
  end

  private

  def name(page)
    if page == '/'
      name = 'frontpage'
    else #remove forward slash
      name = page.gsub(/\//, "")
    end
    name
  end

  def clean(url)
    if url == '/' #avoid two dashes at the end, e.g. www.otto.de//
      ''
    else
      url
    end
  end

end