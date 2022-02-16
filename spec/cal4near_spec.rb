# frozen_string_literal: true

RSpec.describe Cal4near do
  it "has a version number" do
    expect(Cal4near::VERSION).not_to be nil
  end

  context "list" do
    it "list" do
      allow(Cal4near).to receive(:events).and_return([google_event_mock])
      expect(Cal4near.list.class).to eq Hash
    end
  end

  def google_event_mock
    Google::Apis::CalendarV3::Event.new(
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: DateTime.now,
        time_zone: "Asia/Tokyo"
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: DateTime.now,
        time_zone: "Asia/Tokyo"
      )
    )
  end
end
