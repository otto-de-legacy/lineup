require 'rspec'
require 'dimensions'
require 'fileutils'
require 'json'
require_relative '../../lib/lineup'

describe '#screeshot_recorder' do

  BASE_URL = 'https://www.otto.de'
  SCREENSHOTS = "#{Dir.pwd}/screenshots/"

  after(:each) { FileUtils.rmtree SCREENSHOTS }

  it 'loads all configuration from a json file' do
    # Given
    file = "#{Dir.pwd}/test_configuration.json"
    FileUtils.rm file if (File.exists? file)
    json = '{"urls":"page1, page2","resolutions":"13,42","filepath_for_images":"some/path","use_phantomjs":true,"difference_path":"some/difference/image/path"}'
    save_json(json, file)

    # When
    lineup = Lineup::Screenshot.new(BASE_URL)

    # Then
    expect(
        lineup.load_json_config(file)
    ).to eq([['page1', 'page2'], [13,42], 'some/path', true, 'some/difference/image/path'])

    # cleanup:
    FileUtils.rm file if (File.exists? file)
  end

  it 'opens a URL and takes mobile/tablet/desktop screenshots' do
    # Given
    lineup = Lineup::Screenshot.new(BASE_URL)

    # When
    lineup.record_screenshot('base')

    # Then
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/base_frontpage_640.png")
    ).to be(true)
    # And
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/base_frontpage_800.png")
    ).to be(true)
    # And
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/base_frontpage_1180.png")
    ).to be(true)

  end

  it 'takes a screenshot a desired resolution' do
    # Given
    width = '320' #min width firefox as of Sep 2015
    lineup = Lineup::Screenshot.new(BASE_URL)

    # When
    lineup.resolutions(width)

    # Then
    lineup.record_screenshot('base')
    imagewidth = Dimensions.width("#{Dir.pwd}/screenshots/base_frontpage_#{width}.png")
    expect(
        imagewidth
    ).to be < (width.to_i + 10) #depending on the browser:
    # 'width' set the browser to a certain width. The browser itself may then have some frame/border
    # that means, that the viewport is smaller than the width of the browser, thus the image will be a
    # bit smaller then 'width'. To compensate it, we have a +10 here.

  end

  it 'takes screenshots of different pages, if specified' do
    # Given
    urls = '/, multimedia, sport'
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.resolutions('1180')
    lineup.urls(urls)

    # When
    lineup.record_screenshot('base')

    # Then
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/base_frontpage_1180.png")
    ).to be(true)

    expect(
        File.exist? ("#{Dir.pwd}/screenshots/base_multimedia_1180.png")
    ).to be(true)

  end

  it 'raises and exception if, parameters are changed after the base screenshot' do
    # Given
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.urls('/')
    lineup.resolutions('400')

    # When
    lineup.record_screenshot('base')
    expect{
      lineup.use_phantomjs true

      # Then
    }.to raise_error ArgumentError

  end

  it 'compares a base and a new screenshot and detects no difference if images are the same' do
    # Given
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.urls('/shoppages/begood')
    lineup.resolutions('400')
    lineup.record_screenshot('base')
    lineup.record_screenshot('new')

    expect(
      # When
      lineup.compare('base', 'new')

      # Then
    ).to eq([])

  end

  it 'compares a base and a new screenshot and returns the difference if the images are NOT the same as json log' do
    # Given
    width = '600'
    base_site = 'multimedia'
    new_site = 'sport'
    json_path = "#{Dir.pwd}"
    json_file = "#{json_path}/log.json"

    # And Given
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.urls(base_site)
    lineup.resolutions(width)
    lineup.record_screenshot('base')
    FileUtils.mv "#{Dir.pwd}/screenshots/base_#{base_site}_#{width}.png", "#{Dir.pwd}/screenshots/base_#{new_site}_#{width}.png"
    # change the url and go to a different page, in this way we ensure a conflict and thus a result from the comparison
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.urls(new_site)
    lineup.resolutions(width)

    # When
    lineup.record_screenshot('new')

    # Then
    # the output will be similar to the values here:
    # [
    #   {
    #     :url => 'sport',
    #     :width => 600,
    #     :difference => 0.7340442722738748,
    #     :base_file => '/home/myname/lineup/tests/respec/screenshots/base_sport_600.png'
    #     :new_file =>  '/home/myname/lineup/tests/respec/screenshots/new_sport_600.png'
    #     :diff_file => '/home/myname/lineup/tests/rspec/screenshots/DIFFERENCE_sport_600.png'
    #   }
    # ]
    #
    expect(
        (lineup.compare('base', 'new').first)[:url]
    ).to eq('sport')
    # And
    expect(
        (lineup.compare('base', 'new').first)[:width]
    ).to eq(600)
    # And
    result = (lineup.compare('base', 'new').first)[:difference]
    expect(
        result
    ).to be_within(15).of(20) # 'compare' returns the difference of pixel between the screenshots in %
    # 15-20% of pixel works toady (12.3 on 2015/09) for the difference between sport and multimedia page of OTTO.de,
    # but the pages may some day look more or less alike, then these values can be changed
    # And
    expect(
        (lineup.compare('base', 'new').first)[:base_file]
    ).to include("/lineup/tests/rspec/screenshots/base_sport_600.png")
    # And
    expect(
        (lineup.compare('base', 'new').first)[:new_file]
    ).to include("/lineup/tests/rspec/screenshots/new_sport_600.png")
    # And
    expect(
        (lineup.compare('base', 'new').first)[:difference_file]
    ).to include("/lineup/tests/rspec/screenshots/DIFFERENCE_sport_600.png")

    # And When
    lineup.save_json(json_path)
    
    # Then
    expect(
        File.exist? json_file
    ).to be(true)
    # And
    expect(
        File.read json_file
    ).to include("\"difference\":#{result},")

    # cleanup:
    FileUtils.rm json_file if (File.exists? json_file)
  end

  private

  def save_json(json, file)
    file = File.open(
        file, 'a'
    )
    file.write(json)
    file.close
  end

end