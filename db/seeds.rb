require 'rubygems'
require 'nokogiri'
require 'json'
require 'open-uri'
require 'pry-byebug'

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
      route_distance: trail['div']['div'][2]['span'][0]['#text'],
      description: trail['div']['div'][3]['#text'],
      time_needed: trail['div']['div'][2]['span'][2]['#text']
    }
    if trail['div']['div'][2]['span'][2]['#text'].instance_of?(NilClass)
      trail_hash[:time_needed] = trail['div']['div'][2]['span'][2]
    end
    unless trail['a'][1]['figure']['div']['div'][0]['div']['div'][1]['div']['div']['img'].instance_of?(NilClass)
      trail_hash[:photo] = trail['a'][1]['figure']['div']['div'][0]['div']['div'][1]['div']['div']['img']['@src']
    end
    trail_hash[:route_distance] = trail_hash[:route_distance].split('route_distance: ')[1]
    trail_hash[:time_needed] = trail_hash[:time_needed].split('Est. ')[1]
    locations << trail_hash
  end
  return locations
end

def seeding_items
  filepath = File.join(__dir__, 'data/checklist.json')
  serialized_locations = File.read(filepath)
  items_json = JSON.parse(serialized_locations)

  # puts items_json
  puts "*** items Json parsed ***"

    items_json["checklist"].each do |category, category_item|
      # category.each do |required, required_item|
      #   puts "#{required}: #{required_item}"
      # end
      category_item.each do |required, required_array|
        # puts required_item
        required_array.each do |item_name|

          item = Item.create!(name: item_name)
          # puts "Item: #{item.name} is created"
          item.tag_list.add(category)

          # puts "tag category: #{category} added to item: #{item.name}"

          case required
          when "cold_weather" || "snow_weather"
            item.tag_list.add("required")
            item.tag_list.add(required)
            # puts "tag: #{required} and 'required' added to item: #{item.name}"

          else
            item.tag_list.add(required)
            # puts "tag: 'required' added to item: #{item.name}"
          end
          item.save
        end
      end
    end
end

def seeding_checklists
  trip = Trip.first
  items = Item.tagged_with("required")
  items.each do |item|
    checklist = Checklist.create(trip: trip, checked:false, item: item)
  end
end

def seeding_emergency_contacts
  EmergencyContact.create!(name: "Bheemuscles", email: "bhee_muscles@hero.com", phone_no:"+65 9999 9999", user: User.first )
  puts "First emergency contact created ☑"
  EmergencyContact.create!(name: "Bestie Ng", email: "bestie_2010@friendster.com", phone_no:"+65 9109 9678", user: User.first )
  puts "Second emergency contact created ☑"
end
# End of methods section

# Start of seeding
puts "Seeding database.."

# Removing old data
puts "Deleting existing database.. 💣"
Trail.destroy_all
User.destroy_all
Item.destroy_all

puts "Deleted!"

# static data
puts "Creating the manual trails 🛤"
puts "Routeburn Track 🥾"
routeburn = Trail.create!(
  name: "Routeburn Track",
  description: "Routeburn Track is a 32.2 kilometer heavily trafficked point-to-point trail located near Glenorchy, Otago, New Zealand that features a lake and is rated as difficult. The trail offers a number of activity options and is best used from October until May.",
  location: "Fiordland National Park",
  time_needed: "4D3N",
  route_distance: "33km"
)

puts "Creating checkpoints for Routeburn 🚩"
routeburn_checks = {
  point_0: ["Routeburn Shelter", -44.718018, 168.274247, 483],
  point_1: ["Routeburn Flats Hut & Camp", -44.725466, 168.214794, 705],
  point_2: ["Routeburn Falls Hut", -44.725819, 168.198392, 993],
  point_3: ["Lake Mackenzie Hut", -44.767611, 168.173198, 909],
  point_4: ["The Divide Shelter & Car Park", -44.824875, 168.117152, 528],
}

previous_checkpoint = nil
routeburn_checks.each do |key, value|
  checkpoint = Checkpoint.new(
    name: value[0],
    latitude: value[1],
    longitude: value[2],
    elevation: value[3],
  )

  checkpoint.previous_checkpoint = previous_checkpoint unless previous_checkpoint.nil?

  checkpoint.trail = routeburn
  checkpoint.save!

  previous_checkpoint = checkpoint
end

puts "Routeburn done ✅"

puts "Mount Ollivier Summit via Mueller Hut 🥾"
mueller = Trail.create!(
  name: "Mount Ollivier Summit via Mueller Hut Route",
  description: "Mount Ollivier Summit via Mueller Hut Route is a 11.6 kilometer moderately trafficked out and back trail located near Mount Cook Village, Canterbury, New Zealand that features a great forest setting and is only recommended for very experienced adventurers. The trail offers a number of activity options.",
  location: "Aoraki/Mount Cook National Park",
  time_needed: "3D2N",
  route_distance: "11.6km"
)

puts "Creating checkpoints for Mueller 🚩"
mueller_checks = {
  point_0: ["Kea Point Trailhead", -43.71875, 170.0926, 773],
  point_1: ["Mueller Hut", -43.72091834, 170.065166961, 1805],
  point_3: ["Mount Ollivier", -43.7333, 170.0667, 1883],
  point_5: ["Kea Point Trailhead", -43.71875, 170.0926, 773],
}

previous_checkpoint = nil
mueller_checks.each do |key, value|
  checkpoint = Checkpoint.new(
    name: value[0],
    latitude: value[1],
    longitude: value[2],
    elevation: value[3]
  )

  checkpoint.previous_checkpoint = previous_checkpoint unless previous_checkpoint.nil?

  checkpoint.trail = mueller
  checkpoint.save!

  previous_checkpoint = checkpoint
end

puts "Mueller done ✅"
puts "End of manual trails 👌"

# Creating a static user instance
puts "Creating our first user.. 🧔"
User.create!(
    first_name: "Geetha",
    last_name: "Bheema",
    email: "geebee@gmail.com",
    password: "password",
    active: "true"
  )
puts "Standard user Geetha created! ✅"

puts "Creating a temp user... 😬"
User.create!(
    email: "placeholder@email.com",
    password: "placeholder",
    active: "false"
  )
puts "Temp user created! ✅"

seeding_emergency_contacts

# Creating the first trip for first user
puts "Booking a trip for our first user 📑"
STATUS = ["upcoming", "ongoing", "return"]
trip = Trip.create!(
  trail: Trail.first,
  user: User.first,
  start_date: Date.today,
  end_date: Date.today + 2,
  no_of_people: 1,
  status: STATUS[0],
  cooking: true,
  camping: true,
  last_seen_photo: "",
  last_photo: Date.today,
  emergency_contact: EmergencyContact.first,
  release_date_time: DateTime.new(Date.today.year, Date.today.month, Date.today.day + 2, 9)
)
file = URI.open('https://source.unsplash.com/1920x1080/?avatar')
puts "Attaching photo to trip"
trip.photo.attach(io: file, filename: "#{trip.trail.name}_photo.jpg", content_type: "image/jpg")

puts "Trip has been booked!"
puts "Creating emergency contact for our first user"
seeding_emergency_contacts
puts "emergency contact created! ✅"

# extracting from json files
puts "extracting information from json files.."
trail_seed = seeding_trails

puts "infomation extracted!"

# Creating instance models here
puts "creating trails.."
trail_seed.each do |trail|
  Trail.create!(
    name: trail[:name],
    description: trail[:description],
    location: trail[:location],
    time_needed: trail[:time_needed],
    route_distance: trail[:route_distance]
  )
end
puts "Trails created!"
puts "Seeding complete!"

# method for Item seeding


puts "********START: Seeding items*************"
seeding_items
puts "********END: Seeding items***************"


puts "********START: Seeding checklist************"
seeding_checklists
puts "********END: Seeding checklist*************"

# End of seeding
