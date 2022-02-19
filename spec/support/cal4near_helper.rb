shared_context 'setup moc google event' do
  # 2022 1/1 10:00 - 11:00
  let(:event_params_1) {
    {
      start: google_event_date_time(DateTime.new(2022, 1, 1, 10, 00, 00)),
      end:   google_event_date_time(DateTime.new(2022, 1, 1, 11, 00, 00))
    }
  }
  # 2022 1/2 13:00 - 14:00
  let(:event_params_2) {
    {
      start: google_event_date_time(DateTime.new(2022, 1, 2, 13, 00, 00)),
      end:   google_event_date_time(DateTime.new(2022, 1, 2, 14, 00, 00))
    }
  }
  let(:moc_objs) {
    [
      google_event(**event_params_1),
      google_event(**event_params_2),
    ]
  }
end