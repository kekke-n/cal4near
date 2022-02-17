# frozen_string_literal: true

RSpec.describe Cal4near do
  it "has a version number" do
    expect(Cal4near::VERSION).not_to be nil
  end

  context ".events" do
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

    let(:start_date) { DateTime.now }
    let(:end_date) { DateTime.now.next_day(30) }

    before do
      allow(Cal4near).to receive(:events).and_return(moc_objs)
    end

    subject { Cal4near.events(start_date, end_date) }

    it "return correct count objects" do
      expect(subject.length).to eq moc_objs.length
    end

    context 'first event' do
      let(:subject_event) { subject[0] }

      it "start.date_time is correct" do
        expect(subject_event.start.date_time).to eq DateTime.new(2022, 1, 1, 10, 00, 00)
      end

      it "start.end_time is correct" do
        expect(subject_event.end.date_time).to eq DateTime.new(2022, 1, 1, 11, 00, 00)
      end
    end

    context 'second event' do
      let(:subject_event) { subject[1] }

      it "start.date_time is correct" do
        expect(subject_event.start.date_time).to eq DateTime.new(2022, 1, 2, 13, 00, 00)
      end

      it "start.end_time is correct" do
        expect(subject_event.end.date_time).to eq DateTime.new(2022, 1, 2, 14, 00, 00)
      end
    end
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
end
