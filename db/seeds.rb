require 'nokogiri'
require 'json'

# Methods for json extraction
def seeding_trails
  filepath = File.join(__dir__, 'data/trails.json')
  serialized_locations = File.read(filepath)

  locations = []

  trails_loc_json = JSON.parse(serialized_locations)
  trails_loc = trails_loc_json['div']['div'][1]['div']
  trails_loc.each_with_index do |trail, index|
    trail_hash = {
      id: index + 1,
      name: trail['div']['div'][0]['@title'],
      location: trail['div']['a']['@title'],
      distance: trail['div']['div'][2]['span'][0]['#text'],
      description: trail['div']['div'][3]['#text'],
      time_needed: trail['div']['div'][2]['span'][2]['#text']
    }
    if trail['div']['div'][2]['span'][2]['#text'].instance_of?(NilClass)
      trail_hash[:time_needed] = trail['div']['div'][2]['span'][2]
    end
    unless trail['a'][1]['figure']['div']['div'][0]['div']['div'][1]['div']['div']['img'].instance_of?(NilClass)
      trail_hash[:photo] = trail['a'][1]['figure']['div']['div'][0]['div']['div'][1]['div']['div']['img']['@src']
    end
    trail_hash[:distance] = trail_hash[:distance].split('Length: ')[1]
    trail_hash[:time_needed] = trail_hash[:time_needed].split('Est. ')[1]
    locations << trail_hash
  end
  return locations
end
# End of methods section

# Start of seeding
puts "Seeding database.."

# Removing old data
puts "Deleting existing database.."
User.destroy_all
Trail.destroy_all
Checkpoint.destroy_all
puts "Deleted!"

#extracting from json files
puts "extracting information from json files.."
trail_seed = seeding_trails

puts "infomation extracted!"

#Creating instance models here
puts "creating trails.."
trail_seed.each do |trail|
  Trail.create!(
    name: trail[:name],
    description: trail[:description],
    location: trail[:location],
    time_needed: trail[:time_needed],
    distance: trail[:distance]
  )
end
puts "Trails created!"

puts "Seeding complete!"
# End of seeding
