#!/usr/bin/ruby
# Inputs : SDK version / patch

require 'json'

def fetch_input desc
    puts desc 
    gets.chomp
end

SDK_VERSION = ARGV.length > 0 ? ARGV[0] : fetch_input("Please input SDK version (ex : 22.06.0)")
PLUGIN_PATCH = (ARGV.length > 1 ? ARGV[1] : fetch_input("Please input SDK version (ex : 0)")).to_i
    
puts "Resolved SDK to #{SDK_VERSION}, plugin patch to #{PLUGIN_PATCH}"

# Make necessary changes for pod push
File.write('./config.json', JSON.pretty_generate({
    SDK_VERSION: SDK_VERSION,
    PLUGIN_PATCH: PLUGIN_PATCH
}))

PLUGIN_VERSION = "#{SDK_VERSION}.#{PLUGIN_PATCH}"

`git commit -am "Release #{PLUGIN_VERSION}"`
`git tag -a "#{PLUGIN_VERSION}" -m "#{PLUGIN_VERSION}" -f && git push origin #{PLUGIN_VERSION}`