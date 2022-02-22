shared_context 'setup moc google event' do
  let(:today) { DateTime.now }
  let(:tomorrow) { today.next_day(1) }
  let(:tomorrow_ymd) { [tomorrow.year, tomorrow.month, tomorrow.day] }
  let(:day_after_tomorrow) { today.next_day(2) }
  let(:day_after_tomorrow_ymd) {
    [day_after_tomorrow.year, day_after_tomorrow.month, day_after_tomorrow.day] }
  let(:in_three_days) { today.next_day(3) }

  # 2022 1/1 10:00 - 11:00
  let(:event_params_1) {
    {
      start: google_event_date_time(DateTime.new(*(tomorrow_ymd + [10, 00, 00, "+09:00"]))),
      end:   google_event_date_time(DateTime.new(*(tomorrow_ymd + [11, 00, 00, "+09:00"])))
    }
  }
  # 2022 1/2 13:00 - 14:00
  let(:event_params_2) {
    {
      start: google_event_date_time(DateTime.new(*(day_after_tomorrow_ymd + [13, 00, 00, "+09:00"]))),
      end:   google_event_date_time(DateTime.new(*(day_after_tomorrow_ymd + [14, 00, 00, "+09:00"])))
    }
  }
  let(:moc_google_events) {
    [
      google_event(**event_params_1),
      google_event(**event_params_2),
    ]
  }
end

def google_event(**params)
  Google::Apis::CalendarV3::Event.new(**params)
end

def google_event_date_time(date_time=DateTime.now)
  Google::Apis::CalendarV3::EventDateTime.new(
    date_time: date_time,
    time_zone: "Asia/Tokyo"
  )
end
