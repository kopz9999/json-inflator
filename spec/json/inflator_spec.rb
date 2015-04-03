require 'spec_helper'

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

  [ 'recycled/sample1.json', 'recycled/sample2.json', 
    'recycled/sample3.json' ].each do | fpath |

    context "with #{ fpath }" do
      let(:fixture_path) { fpath }
      it_behaves_like 'fixture check'
    end

  end

end
