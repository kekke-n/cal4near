# frozen_string_literal: true
require 'spec_helper'

describe Cal4near do
  it "has a version number" do
    expect(Cal4near::VERSION).not_to be nil
  end

  context ".free_times" do
    include_context 'setup moc google event'

    let(:start_date) { DateTime.now }
    let(:end_date) { DateTime.now.next_day(30) }

    before do
      allow(Cal4near).to receive(:events).and_return(moc_google_events)
    end

    let(:free_times) { Cal4near.free_times(start_date, end_date) }

    context 'tomorrow' do
      let(:subject_date) { free_times[tomorrow.strftime("%Y-%m-%d")] }
      let(:subject_time) { subject_date["#{tomorrow.strftime("%Y-%m-%d")} #{time}"] }

      context '09:00' do
        let(:time) { '09:00' }
        it "is free." do
          expect(subject_time[:free]).to be true
        end
      end

      context '10:00' do
        let(:time) { '10:00' }
        it "is not free. (planed event)" do
          expect(subject_time[:free]).to be false
        end
      end

      context '11:00' do
        let(:time) { '11:00' }
        it "is free." do
          expect(subject_time[:free]).to be true
        end
      end
    end
  end
end
