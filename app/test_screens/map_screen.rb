class TestMapScreen < PM::MapScreen

  attr_accessor :infinite_loop_points, :request_complete

  start_position latitude: 35.090648651123, longitude: -82.965972900391, radius: 4
  title "Gorges State Park, NC"

  def promotion_annotation_data
    @promotion_annotation_data
  end

  def annotation_data
    # Partial set of data from "GPS Map of Gorges State Park": http://www.hikewnc.info/maps/gorges-state-park/gps-map
    @data ||= [{
      longitude: -82.965972900391,
      latitude: 35.090648651123,
      title: "Rainbow Falls",
      subtitle: "Nantahala National Forest",
    },{
      longitude: -82.966093558105,
      latitude: 35.092520895652,
      title: "Turtleback Falls",
      subtitle: "Nantahala National Forest",
    },{
      longitude: -82.95916,
      latitude: 35.07496,
      title: "Windy Falls"
    },{
      longitude: -82.943031505056,
      latitude: 35.102516828489,
      title: "Upper Bearwallow Falls",
      subtitle: "Gorges State Park",
    },{
      longitude: -82.956244328014,
      latitude: 35.085548421623,
      title: "Stairway Falls",
      subtitle: "Gorges State Park",
    }]
  end

  def lookup_infinite_loop
    self.request_complete = false
    self.look_up_address address: "1 Infinite Loop" do |points, error|
      self.request_complete = true
      self.infinite_loop_points = points
    end
  end

end
