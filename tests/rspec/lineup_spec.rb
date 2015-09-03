require 'rspec'
require 'dimensions'
require_relative '../../lib/lineup'

describe '#screeshot_recorder' do

  it 'opens a URL and takes mobile/tablet/desktop screenshots' do
    lineup = Lineup::Screenshot.new(
        'https://www.otto.de'
    )
    lineup.record_screenshot('base')
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/storefront_640_base.png")
    ).to be(true)
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/storefront_800_base.png")
    ).to be(true)
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/storefront_1180_base.png")
    ).to be(true)
  end

  it 'takes a screenshot a desired resolution' do

    width = '320' #min width firefox as of Sep 2015

    lineup = Lineup::Screenshot.new(
        'https://www.otto.de'
    )
    lineup.resolutions(width)
    lineup.record_screenshot('base')
    imagewidth = Dimensions.width("#{Dir.pwd}/screenshots/storefront_#{width}_base.png")
    expect(imagewidth).to be < (width.to_i + 10) #depending on the browser, there may be frames in the window. the screenshot represents the width of the viewport though
  end

  it 'takes screenshots of different pages, if specified' do

    urls = '/,multimedia,sport'

    lineup = Lineup::Screenshot.new(
        'https://www.otto.de'
    )
    lineup.urls(urls)
    lineup.resolutions('1180')
    lineup.record_screenshot('base')
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/storefront_1180_base.png")
    ).to be(true)
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/multimedia_1180_base.png")
    ).to be(true)

  end

end