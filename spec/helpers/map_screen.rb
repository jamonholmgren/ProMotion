class TestMapScreen < PM::MapScreen

  start_position latitude: 35.090648651123, longitude: -82.965972900391, radius: 4
  title "Gorges State Park, NC"

  def get_title
    self.title
  end

  def promotion_annotation_data
    @promotion_annotation_data
  end

  def on_load
    # self.tap_counter = 0
  end

  def will_appear
    update_annotation_data
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

end
