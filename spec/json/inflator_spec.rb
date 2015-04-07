require 'spec_helper'
require 'oj'
require 'benchmark'

describe Json::Inflator do

  shared_examples 'fixture check' do |mode|

    let(:sample_hash) { read_json_fixture fixture_path }

    specify 'is processable' do
      expect{
        processor = Json::Inflator::Parser.new
        processor.process! sample_hash, mode
      }.not_to raise_error
    end

    describe 'references are valid' do

      let(:decycled_hash) { read_json_fixture fixture_path }
      let(:recycled_hash) { read_json_fixture fixture_path }

      specify 'is valid' do
        processor = Json::Inflator::Parser.new
        result = processor.process! recycled_hash, mode

        recycle_validator = RecycleValidator.new decycled_hash: decycled_hash, 
          recycled_hash: result, context: self, mode: mode, parser: processor

        recycle_validator.validate
      end

    end
  end

  # Units are miliseconds, please provide miliseconds
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
        processor = Json::Inflator::Parser.new
        processor.process! sample_hash, mode
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
        processor = Json::Inflator::Parser.new
        processor.process! sample_hash, mode
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
        processor = Json::Inflator::Parser.new
        processor.process! sample_hash, mode
      end
    }

    it_behaves_like 'performance check', "inflate - #{ mode } with oj parse", 
      m_min_time, m_max_time
  end

  [ 
    'recycled/sample1.json', 
    'recycled/sample2.json'
  ].each do | fpath |

    context "with #{ fpath }" do
      let(:fixture_path) { fpath }
      it_behaves_like 'fixture check', :j_path

      # These are miliseconds
      it_behaves_like 'inflate algorithm performance', :j_path, 0, 1
      it_behaves_like 'inflate w/json parse performance', :j_path, 0, 1
      it_behaves_like 'inflate w/oj parse performance', :j_path, 0, 1
    end

  end


  [ 
    'recycled/sample3.json'
  ].each do | fpath |

    context "with #{ fpath }" do
      let(:fixture_path) { fpath }
      it_behaves_like 'fixture check', :static_reference

      # These are miliseconds
      it_behaves_like 'inflate algorithm performance', :static_reference, 0, 200
      it_behaves_like 'inflate w/json parse performance', :static_reference, 0, 500
      it_behaves_like 'inflate w/oj parse performance', :static_reference, 0, 350
    end

  end


end
