require 'rspec'
require 'dimensions'
require 'fileutils'
require 'json'
require_relative '../../lib/lineup'

describe '#screeshot_recorder' do

  BASE_URL = 'https://www.google.de'
  SCREENSHOTS = "#{Dir.pwd}/screenshots/"

  after(:each) { FileUtils.rmtree SCREENSHOTS }

  it 'loads minimum configuration from a json file' do
    # Given
    file = "#{Dir.pwd}/test_configuration.json"
    FileUtils.rm file if (File.exists? file)
    json = '{"urls":"page1",
             "resolutions": "13",
             "filepath_for_images":"screenshots/path",
             "use_phantomjs":true,
             "difference_path":"screenshots/path/difference",
             "wait_for_asynchron_pages":5
             }'
    save_json(json, file)

    # When
    lineup = Lineup::Screenshot.new(BASE_URL)

    # Then
    expect(
        lineup.load_json_config(file)
    ).to eq([['page1'], [13], 'screenshots/path', true, 'screenshots/path/difference', 5, [], {}])

    # cleanup:
    FileUtils.rm file if (File.exists? file)
  end

  it 'loads all configuration from a json file' do
    # Given
    file = "#{Dir.pwd}/test_configuration.json"
    FileUtils.rm file if (File.exists? file)
    json = '{"urls":"page1, page2",
             "resolutions":"13,42",
             "filepath_for_images":"screenshots/path",
             "use_phantomjs":true,
             "difference_path":"screenshots/path/difference",
             "wait_for_asynchron_pages":5,
             "cookie_for_experiment":{
                                      "name":"cookie1",
                                      "value":"11111",
                                      "domain":".google.de",
                                      "path":"/",
                                      "secure":false
                                      },
             "cookies" : [{
                                      "name":"cookie2",
                                      "value":"22222",
                                      "domain":".google.de",
                                      "path":"/",
                                      "secure":false
                          },
                          {
                                      "name":"cookie3",
                                      "value":"33333",
                                      "domain":".google.de",
                                      "path":"/",
                                      "secure":false
                          }],
             "localStorage":{"myKey1":"myValue1","myKey2":"myValue2"}
             }'
    save_json(json, file)

    # When
    lineup = Lineup::Screenshot.new(BASE_URL)

    # Then
    expect(
        lineup.load_json_config(file)
    ).to eq([['page1', 'page2'], [13,42], 'screenshots/path', true, 'screenshots/path/difference', 5,
             [{:name=>"cookie2", :value=>"22222", :domain=>".google.de", :path=>"/", :secure=>false},
              {:name=>"cookie3", :value=>"33333", :domain=>".google.de", :path=>"/", :secure=>false},
              {:name=>"cookie1", :value=>"11111", :domain=>".google.de", :path=>"/", :secure=>false}],
             {"myKey1"=>"myValue1", "myKey2"=>"myValue2"}])

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
        File.exist? ("#{Dir.pwd}/screenshots/frontpage_640_base.png")
    ).to be(true)
    # And
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/frontpage_800_base.png")
    ).to be(true)
    # And
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/frontpage_1180_base.png")
    ).to be(true)

  end

  it 'opens a URL and takes mobile/tablet/desktop screenshots using firefox' do
    # Given
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.use_phantomjs false

    # When
    lineup.record_screenshot('base')

    # Then
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/frontpage_640_base.png")
    ).to be(true)
    # And
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/frontpage_800_base.png")
    ).to be(true)
    # And
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/frontpage_1180_base.png")
    ).to be(true)

  end

  it 'takes a screenshot at desired resolution' do
    # Given
    width = '700'
    lineup = Lineup::Screenshot.new(BASE_URL)

    # When
    lineup.resolutions(width)

    # Then
    lineup.record_screenshot('base')
    imagewidth = Dimensions.width("#{Dir.pwd}/screenshots/frontpage_#{width}_base.png")
    expect(
        imagewidth
    ).to be < (width.to_i + 10) #depending on the browser:
    # 'width' set the browser to a certain width. The browser itself may then have some frame/border
    # that means, that the viewport is smaller than the width of the browser, thus the image will be a
    # bit smaller then 'width'. To compensate it, we have a +10 here.

  end

  it 'takes screenshots of different pages, if specified' do
    # Given
    urls = '/, flights'
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.resolutions('1180')
    lineup.urls(urls)

    # When
    lineup.record_screenshot('base')

    # Then
    expect(
        File.exist? ("#{Dir.pwd}/screenshots/frontpage_1180_base.png")
    ).to be(true)

    expect(
        File.exist? ("#{Dir.pwd}/screenshots/flights_1180_base.png")
    ).to be(true)

  end

  it 'raises and exception if parameters are changed after the base screenshot' do
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
    lineup.urls('/')
    lineup.resolutions('400')
    lineup.wait_for_asynchron_pages(5)
    lineup.use_phantomjs(true)
    cookie =  {"name" => "CONSENT",
               "value" => "YES+DE.de+V7",
               "domain" => ".google.de",
               "path" => "/",
               "secure" => false}
    lineup.cookie_for_experiment(cookie)

    lineup.record_screenshot('base')
    lineup.record_screenshot('new')

    expect(
      # When
      lineup.compare('base', 'new')

      # Then
    ).to eq([])

  end

  it 'compares a base and a new screenshot when loading a json config and setting a cookie' do
    # Given
    file = "#{Dir.pwd}/test_configuration.json"
    FileUtils.rm file if (File.exists? file)

    json = '{"urls":"page1, page2",
             "resolutions":"13,42",
             "filepath_for_images":"screenshots/path",
             "use_phantomjs":true,
             "difference_path":"screenshots/path/difference",
             "wait_for_asynchron_pages":5,
             "cookie_for_experiment":{
                                      "name":"CONSENT",
                                      "value":"YES+DE.de+V7",
                                      "domain":".google.de",
                                      "path":"/",
                                      "secure":false
                                      },
             "cookies" : [{
                                      "name":"cookie2",
                                      "value":"22222",
                                      "domain":".google.de",
                                      "path":"/",
                                      "secure":false
                          },
                          {
                                      "name":"cookie3",
                                      "value":"33333",
                                      "domain":".google.de",
                                      "path":"/",
                                      "secure":false
                          }]
             }'
    save_json(json, file)
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.load_json_config(file)

    lineup.record_screenshot('base')
    lineup.record_screenshot('new')

    expect(
        # When
        lineup.compare('base', 'new')

        # Then
    ).to eq([])

    # cleanup:
    FileUtils.rm file if (File.exists? file)

  end

  it 'takes a screenshot when loading a json config and setting local storage key value pair containing single quotes' do
    # Given
    file = "#{Dir.pwd}/test_configuration.json"
    FileUtils.rm file if (File.exists? file)

    json = '{"urls":"page1",
             "resolutions":"200",
             "filepath_for_images":"screenshots/path",
             "use_phantomjs":true,
             "difference_path":"screenshots/path/difference",
             "wait_for_asynchron_pages":5,
             "localStorage": {"{\'mySpecialKey\'}":"{\'myvalue\':{\'value\':test,\'timestamp\':1467723066092}}"}
             }'
    save_json(json, file)
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.load_json_config(file)

    lineup.record_screenshot('base')
    # expect: no exception

    # cleanup:
    FileUtils.rm file if (File.exists? file)

  end

  it 'compares a base and a new screenshot when loading a json config and setting local storage key value pairs' do
    # Given
    file = "#{Dir.pwd}/test_configuration.json"
    FileUtils.rm file if (File.exists? file)

    json = '{"urls":"page1",
             "resolutions":"200",
             "filepath_for_images":"screenshots/path",
             "use_phantomjs":true,
             "difference_path":"screenshots/path/difference",
             "wait_for_asynchron_pages":5,
             "localStorage":{"\'myKey\'":"{\'myValue\'}","myKey2":"myValue2"}
             }'
    save_json(json, file)
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.load_json_config(file)

    lineup.record_screenshot('base')
    lineup.record_screenshot('new')

    expect(
        # When
        lineup.compare('base', 'new')

        # Then
    ).to eq([])

    # cleanup:
    FileUtils.rm file if (File.exists? file)

  end

  it 'compares a base and a new screenshot and returns the difference if the images are NOT the same as json log' do
    # Given
    width = '800'
    base_site = '?q=test'
    new_site = '?q=somethingelse'
    json_path = "#{Dir.pwd}"
    json_file = "#{json_path}/log.json"

    # And Given
    lineup = Lineup::Screenshot.new(BASE_URL)
    lineup.urls(base_site)
    lineup.resolutions(width)
    lineup.record_screenshot('base')
    FileUtils.mv "#{Dir.pwd}/screenshots/#{base_site}_#{width}_base.png", "#{Dir.pwd}/screenshots/#{new_site}_#{width}_base.png"
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
    #     :url => 'translate',
    #     :width => 800,
    #     :difference => 0.7340442722738748,
    #     :base_file => '/home/myname/lineup/tests/respec/screenshots/translate_600_base.png'
    #     :new_file =>  '/home/myname/lineup/tests/respec/screenshots/translate_600_new.png'
    #     :diff_file => '/home/myname/lineup/tests/rspec/screenshots/translate_600_DIFFERENCE.png'
    #   }
    # ]
    #
    expect(
        (lineup.compare('base', 'new').first)[:url]
    ).to eq('?q=somethingelse')
    # And
    expect(
        (lineup.compare('base', 'new').first)[:width]
    ).to eq(800)
    # And
    result = (lineup.compare('base', 'new').first)[:difference]
    expect(
        result
    ).to be > 0 # 'compare' returns the difference of pixel between the screenshots in %
    expect(
        (lineup.compare('base', 'new').first)[:base_file]
    ).to include("/lineup/tests/rspec/screenshots/?q=somethingelse_#{width}_base.png")
    # And
    expect(
        (lineup.compare('base', 'new').first)[:new_file]
    ).to include("/lineup/tests/rspec/screenshots/?q=somethingelse_#{width}_new.png")
    # And
    expect(
        (lineup.compare('base', 'new').first)[:difference_file]
    ).to include("/lineup/tests/rspec/screenshots/?q=somethingelse_#{width}_DIFFERENCE.png")

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