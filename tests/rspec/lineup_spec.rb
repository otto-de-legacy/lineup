require 'rspec'
require 'dimensions'
require 'fileutils'
require_relative '../../lib/lineup'

describe '#screeshot_recorder' do

  BASE_URL = 'https://www.otto.de'
  SCREENSHOTS = "#{Dir.pwd}/screenshots/"

  #after(:each) { FileUtils.rmtree SCREENSHOTS }

  it 'opens a URL and takes mobile/tablet/desktop screenshots' do
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.record_screenshot('base')

    expect(
        File.exist? ("#{Dir.pwd}/screenshots/frontpage_640_base.png")
    ).to be(true)

    expect(
        File.exist? ("#{Dir.pwd}/screenshots/frontpage_800_base.png")
    ).to be(true)

    expect(
        File.exist? ("#{Dir.pwd}/screenshots/frontpage_1180_base.png")
    ).to be(true)

  end

  it 'takes a screenshot a desired resolution' do
    width = '320' #min width firefox as of Sep 2015
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.resolutions(width)
    lineup.record_screenshot('base')
    imagewidth = Dimensions.width("#{Dir.pwd}/screenshots/frontpage_#{width}_base.png")

    expect(imagewidth).to be < (width.to_i + 10) #depending on the browser, there may be frames in the window. the screenshot represents the width of the viewport though

  end

  it 'takes screenshots of different pages, if specified' do
    urls = '/, multimedia, sport'
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.urls(urls)
    lineup.resolutions('1180')
    lineup.record_screenshot('base')

    expect(
        File.exist? ("#{Dir.pwd}/screenshots/frontpage_1180_base.png")
    ).to be(true)

    expect(
        File.exist? ("#{Dir.pwd}/screenshots/multimedia_1180_base.png")
    ).to be(true)

  end

  it 'raises and exception if, parameters are changed after the base screenshot' do
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.urls('/')
    lineup.resolutions('400')
    lineup.record_screenshot('base')

    expect{
      lineup.use_headless true
    }.to raise_error ArgumentError

  end

  it 'compares a base and a new screenshot and detects no difference if images are the same' do
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.urls('/shoppages/begood')
    lineup.resolutions('400')
    lineup.record_screenshot('base')
    lineup.record_screenshot('new')
    expect(
      lineup.compare('base', 'new')
    ).to eq([])

  end

  it 'compares a base and a new screenshot and returns the difference if the images are NOT the same' do
    width = '600'
    base_site = 'multimedia'
    new_site = 'sport'
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.urls(base_site)
    lineup.resolutions(width)
    lineup.record_screenshot('base')
    FileUtils.mv "#{Dir.pwd}/screenshots/#{base_site}_#{width}_base.png", "#{Dir.pwd}/screenshots/#{new_site}_#{width}_base.png"
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.urls(new_site)
    lineup.resolutions(width)
    lineup.record_screenshot('new')
    expect(
        lineup.compare('base', 'new').first.last
    ).to be_within(15).of(20) #this works toady (12.3 on 2015/09), but the pages may some day look more or less alike, then these values can be changed
  end

end