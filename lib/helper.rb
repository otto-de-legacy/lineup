module Helper
  extend self

  def filename(path, url, width, version)
    "#{path}/#{name(url)}_#{width}_#{version}.png"
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