require 'json'

# Read files on fixtures folder
def read_fixture( path )
  File.read("#{ fixtures_folder }/#{ path }")
end

def read_json_fixture( path )
  JSON.parse read_fixture( path ), :max_nesting => 3000
end

def fixtures_folder
  File.join(spec_folder, 'fixtures')
end

def spec_folder
  File.dirname(__FILE__)
end
