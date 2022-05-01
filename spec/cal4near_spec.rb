# frozen_string_literal: true
require 'spec_helper'

describe Cal4near do
  it "has a version number" do
    expect(Cal4near::VERSION).not_to be nil
  end

  context ".free_busy_times" do
    include_context 'setup moc google event'

    let(:start_date) { DateTime.now.next_day(1) }
    let(:end_date) { DateTime.now.next_day(30) }
    let(:params) {
      {
        start_date: start_date,
        end_date: end_date
      }
    }

    before do
      allow(Cal4near).to receive(:events).and_return(moc_google_events)
    end

    let(:free_busy_times) { Cal4near.free_busy_times(**params) }

    context 'tomorrow' do
      let(:subject_date) { free_busy_times[tomorrow.strftime("%Y-%m-%d")] }
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

  context ".format" do
    include_context 'setup moc google event'

    let(:start_date) { DateTime.now.next_day(1) }
    let(:end_date) { DateTime.now.next_day(30) }

    before do
      allow(Cal4near).to receive(:events).and_return(moc_google_events)
    end

    let(:max_date_count) { 3 }
    let(:wdays) { %w(日 月 火 水 木 金 土) }
    let(:params) {
      {
        start_date: start_date,
        end_date: end_date,
        start_hour: Cal4near::START_HOUR,
        end_hour: Cal4near::END_HOUR,
        max_date_count: max_date_count
      }
    }
    let(:free_busy_times) {

      Cal4near.free_busy_times(**params) }
    let(:cal4_format) { Cal4near.format(free_busy_times, is_free) }

    let(:day1_format) { "#{tomorrow.strftime('%Y/%m/%d')}(#{wdays[tomorrow.wday]})" }
    let(:day2_format) { "#{day_after_tomorrow.strftime('%Y/%m/%d')}(#{wdays[day_after_tomorrow.wday]})" }
    let(:day3_format) { "#{in_three_days.strftime('%Y/%m/%d')}(#{wdays[in_three_days.wday]})" }

    context "free" do
      let(:is_free) { true }
      it 'show free times.' do
        expect(cal4_format).to eq <<~"EOS".chomp
         #{day1_format} 9:00-10:00, 11:00-18:00
         #{day2_format} 9:00-13:00, 14:00-18:00
         #{day3_format} 9:00-18:00
        EOS
      end
    end

    context "busy" do
      let(:is_free) { false }
      it 'show busy times.' do
        expect(cal4_format).to eq <<~EOS.chomp
         #{day1_format} 10:00-11:00
         #{day2_format} 13:00-14:00
         #{day3_format}
        EOS
      end
    end

  end
end
