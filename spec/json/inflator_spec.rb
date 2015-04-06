require 'spec_helper'
require 'benchmark'

describe Json::Inflator do

  shared_examples 'fixture check' do

    let(:sample_hash) { read_json_fixture fixture_path }

    specify 'is processable' do
      expect{
        processor = Json::Inflator::Parser.new
        processor.process! sample_hash
      }.not_to raise_error
    end

    describe 'references are valid' do

      let(:decycled_hash) { read_json_fixture fixture_path }
      let(:recycled_hash) { read_json_fixture fixture_path }

      specify 'is valid' do
        processor = Json::Inflator::Parser.new
        processor.process! recycled_hash

        recycle_validator = RecycleValidator.new decycled_hash: decycled_hash, 
          recycled_hash: recycled_hash, context: self

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
      p (time * 1000)
      expect( time ).to be_between(min_time, max_time)
    end

  end

  shared_examples 'inflate algorithm performance' do | m_min_time, m_max_time |

    let(:time) {
      sample_hash = read_json_fixture(fixture_path)
      Benchmark.realtime do
        processor = Json::Inflator::Parser.new
        processor.process! sample_hash
      end      
    }
    
    it_behaves_like 'performance check', 'inflate', m_min_time, m_max_time
  end

  shared_examples 'inflate w/json parse performance' do |m_min_time, m_max_time|

    let(:time) {
      Benchmark.realtime do
        sample_hash = read_json_fixture(fixture_path)
        processor = Json::Inflator::Parser.new
        processor.process! sample_hash
      end
    }

    it_behaves_like 'performance check', 'inflate with json parse', 
      m_min_time, m_max_time
  end

  [ 
    'recycled/sample1.json', 
    'recycled/sample2.json', 
    'recycled/sample3.json' 
  ].each do | fpath |

    context "with #{ fpath }" do
      let(:fixture_path) { fpath }
      it_behaves_like 'fixture check'
      # These are miliseconds
      it_behaves_like 'inflate algorithm performance', 0, 1
      it_behaves_like 'inflate w/json parse performance', 0, 250
    end

  end

end
