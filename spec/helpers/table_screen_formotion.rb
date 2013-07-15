class TestFormotionScreen < PM::FormotionScreen

  title "Formotion Test"

  def table_data
    @data ||= {
      sections: [{
        title: "Currency",
        key: :currency,
        select_one: true,
        rows: [{
          title: "EUR",
          key: :eur,
          value: true,
          type: :check
        }, {
          title: "USD",
          key: :usd,
          type: :check
        }]
      }]
    }
  end

end
