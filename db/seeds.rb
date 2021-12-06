puts "Destroying all"
Trail.destroy_all
Checkpoint.destroy_all

puts "Creating the manual trails 🛤"
puts "Routeburn Track 1️⃣"
routeburn = Trail.create!(
  name: "Routeburn Track",
  description: "Routeburn Track is a 32.2 kilometer heavily trafficked point-to-point trail located near Glenorchy, Otago, New Zealand that features a lake and is rated as difficult. The trail offers a number of activity options and is best used from October until May.",
  location: "Fiordland National Park",
  time_needed: "4D3N",
  distance: "33km",
  start_lat: -44.718018,
  start_lon: 168.274247,
  end_lat: -44.824875,
  end_lon: 168.117152
)

puts "Creating checkpoints for Routeburn"
routeburn_checks = {
  point_1: ["Routeburn Flats Hut & Camp", -44.725466, 168.214794, "477m"],
  point_2: ["Routeburn Falls Hut", -44.725819, 168.198392, "972m"],
  point_3: ["Lake Mackenzie Hut", -44.767611, 168.173198, "891m"]
}

routeburn_checks.each do |key, value|
  checkpoint = Checkpoint.new(
    name: value[0],
    latitude: value[1],
    longitude: value[2],
    elevation: value[3]
  )
  checkpoint.trail = routeburn
  checkpoint.save
end

puts "Routeburn done ✅"

puts "Mount Ollivier Summit via Mueller Hut 2️⃣"
mueller = Trail.create!(
  name: "Mount Ollivier Summit via Mueller Hut Route",
  description: "Mount Ollivier Summit via Mueller Hut Route is a 11.6 kilometer moderately trafficked out and back trail located near Mount Cook Village, Canterbury, New Zealand that features a great forest setting and is only recommended for very experienced adventurers. The trail offers a number of activity options.",
  location: "Aoraki/Mount Cook National Park",
  time_needed: "2D1N",
  distance: "11.6km",
  start_lat: -43.71875,
  start_lon: 170.0926,
  end_lat: -43.71875,
  end_lon: 170.0926
)

puts "Creating checkpoints for Mueller"
mueller_checks = {
  point_1: ["Sealy Tarns", -43.71391808, 170.07001560, "1,298m"],
  point_2: ["Mueller Hut", -43.72091834, 170.065166961, "1,805m"],
  point_3: ["Mount Ollivier", -43.7333, 170.0667, "1,933m"],
  point_4: ["Sealy Tarns", -43.71391808, 170.07001560, "1,298m"]
}

mueller_checks.each do |key, value|
  checkpoint = Checkpoint.new(
    name: value[0],
    latitude: value[1],
    longitude: value[2],
    elevation: value[3]
  )
  checkpoint.trail = mueller
  checkpoint.save
end

puts "Mueller done ✅"

puts "End of manual trails 👌"