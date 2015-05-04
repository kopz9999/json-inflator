require 'spec_helper'
require 'oj'
require 'benchmark'

describe Json::Inflator do

  shared_examples 'fixture check' do |mode|

    let(:sample_hash) { read_json_fixture fixture_path }

    specify 'is processable' do
      result = nil
      expect{
        result = sample_hash.inflate_json! settings: { mode: mode }
      }.not_to raise_error
      expect( result ).not_to be_empty
    end

  end

  shared_examples 'integration test' do |mode|

    let(:original_json_string) { read_fixture fixture_path }

    specify 'it matches original string' do
      original_decycled_hash = JSON
        .parse(original_json_string, :max_nesting => 3000 )
      recycled_hash = original_decycled_hash
        .inflate_json! settings: { mode: mode }
      decycled_hash = recycled_hash
        .deflate_json! settings: { mode: mode }
      result_json_string = decycled_hash.to_json :max_nesting => 3000
      # Strip out $id and $ref from both strings
      result_json_string_copy = result_json_string.clone
      original_json_string_copy = original_json_string.clone
      [ result_json_string_copy, original_json_string_copy ].each do |str|
        str.gsub!( /\"\$id\"\:(\")?([0-9]+)(\")?/, '' )
        str.gsub!( /\"\$ref\"\:(\")?([0-9]+)(\")?/, '' )
      end
      expect( result_json_string_copy )
        .to eq original_json_string_copy
    end

  end

  # Units are milliseconds, please provide milliseconds
  shared_examples 'performance check' do | your_test, m_min_time, m_max_time |

    # Unit transform
    min_time = m_min_time / 1000.0
    max_time = m_max_time / 1000.0

    specify "#{your_test} takes between #{m_min_time} and #{m_max_time} ms" do
      expect( time ).to be_between(min_time, max_time), 
        "#{ time * 1000 } ms not in range( #{ m_min_time }, #{ m_max_time } ) ms"
    end

  end

  shared_examples 'inflate algorithm performance' do |mode, 
                                                        m_min_time, m_max_time|
    let(:time) {
      sample_hash = read_json_fixture(fixture_path)
      Benchmark.realtime do
        result = sample_hash.inflate_json! settings: { mode: mode }
      end
    }
    
    it_behaves_like 'performance check', "inflate - #{ mode }", 
      m_min_time, m_max_time
  end

  shared_examples 'inflate w/json parse performance' do |mode, 
                                                          m_min_time, m_max_time|
    let(:time) {
      Benchmark.realtime do
        sample_hash = read_json_fixture(fixture_path)
        result = sample_hash.inflate_json! settings: { mode: mode }
      end
    }

    it_behaves_like 'performance check', "inflate - #{ mode } with json parse", 
      m_min_time, m_max_time
  end

  shared_examples 'inflate w/oj parse performance' do |mode, 
                                                        m_min_time, m_max_time|
    let(:time) {
      Benchmark.realtime do
        json = read_fixture(fixture_path)
        sample_hash = Oj.load(json)
        result = sample_hash.inflate_json! settings: { mode: mode }
      end
    }

    it_behaves_like 'performance check', "inflate - #{ mode } with oj parse", 
      m_min_time, m_max_time
  end

  describe 'sample 1' do
    let(:fixture_path) { 'recycled/sample1.json' }
    it_behaves_like 'fixture check', :j_path
    it_behaves_like 'integration test', :j_path
  end

  describe 'sample 2' do
    let(:fixture_path) { 'recycled/sample2.json' }
    it_behaves_like 'fixture check', :j_path
    it_behaves_like 'integration test', :j_path
  end

  describe 'sample 3' do
    let(:fixture_path) { 'recycled/sample3.json' }
    it_behaves_like 'fixture check', :static_reference
    it_behaves_like 'integration test', :static_reference
    # These are milliseconds
    it_behaves_like 'inflate algorithm performance', :static_reference, 100, 220
    it_behaves_like 'inflate w/json parse performance', :static_reference, 300, 550
    it_behaves_like 'inflate w/oj parse performance', :static_reference, 250, 500
  end

end
