# frozen_string_literal: true
require 'spec_helper'

describe Cal4near do
  it "has a version number" do
    expect(Cal4near::VERSION).not_to be nil
  end

  context ".events" do
    include_context 'setup moc google event'

    let(:start_date) { DateTime.now }
    let(:end_date) { DateTime.now.next_day(30) }

    before do
      allow(Cal4near).to receive(:events).and_return(moc_google_events)
    end

    subject { Cal4near.events(start_date, end_date) }

    it "return correct count objects" do
      expect(subject.length).to eq moc_google_events.length
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
end
