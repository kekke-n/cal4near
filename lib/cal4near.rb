# frozen_string_literal: true

require_relative "cal4near/version"
require "google/apis/calendar_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "date"
require "fileutils"

module Cal4near
  class Error < StandardError; end

  OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
  APPLICATION_NAME = "Google Calendar API Ruby Quickstart".freeze
  CREDENTIALS_PATH = "credentials.json".freeze
  # The file token.yaml stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  TOKEN_PATH = "token.yaml".freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

  # 空き時間を検索する日時の範囲
  START_DATE = DateTime.now.next_day(1)
  END_DATE = DateTime.now.next_day(30)

  # 空き時間を検索する時間の範囲
  START_HOUR = 9
  END_HOUR = 19

  # カレンダーに登録されているイベントを取得
  # @param [DateTime] start_date 対象期間の開始日時
  # @param [DateTime] end_date 対象期間の終了日時
  # @return [Array] Google::Apis::CalendarV3::Eventのリスト
  def self.events(start_date, end_date)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    service.list_events(
      "primary",
      single_events: true,
      order_by: "startTime",
      time_min: start_date.rfc3339,
      time_max: end_date.rfc3339
    ).items
  end

  DATE_FORMAT = "%Y-%m-%d"
  DATE_TIME_FORMAT = "%Y-%m-%d %H:%M"

  # カレンダーの空き情報を取得
  # @return [Hash]
  # @example 返り値のサンプルは以下
  #  "2022-03-21"=> {"2022-03-21 09:00"=>{:free=>true}
  def self.free_busy_times(
    start_date = START_DATE,
    end_date = END_DATE,
    start_hour = START_HOUR,
    end_hour = END_HOUR,
    max_date_count = 100
  )
    busy_list = []
    events(start_date, end_date).each do |event|
      # start endが両方ともdate型の場合は終日の予定
      is_all_date = (event.start.date && event.end.date)

      # [デバッグ用]カレンダーイベントの情報を出力する
      # stdout_calendar_info(event, is_all_date)

      unless is_all_date
        busy_list << {
          start: event.start.date_time,
          end: event.end.date_time
        }
      end
    end

    # puts "Free time:"

    result = {}
    (start_date.to_date..end_date.to_date).each.with_index(1) do |date, i|
      break if i > max_date_count

      result[date.strftime(DATE_FORMAT)] ||= {} # YYYY-MM-DD

      start_work_time = Time.new(date.year, date.month, date.day, start_hour, 0, 0)
      end_work_time = Time.new(date.year, date.month, date.day, end_hour, 0, 0)

      step_secound = 60*60
      start_work_time.to_i.step(end_work_time.to_i, step_secound).each_cons(2) do |c_time_int, n_time_int|
        current_time = Time.at(c_time_int)
        next_time = Time.at(n_time_int)

        # 現時刻より前はスキップ
        next if current_time.to_datetime < DateTime.now

        date_key = date.strftime(DATE_FORMAT)
        time_key = current_time.strftime(DATE_TIME_FORMAT)
        result[date_key][time_key] = { free: true }

        busy_list.each do |busy|
          if current_time.to_datetime < busy[:end] && busy[:start] < next_time.to_datetime
            result[date_key][time_key][:free] = false
            break
          end
        end
      end
    end
    result
  end

  # @param [Hash] free_busy_times
  def self.format(times_info, is_free = true)
    result = times_info
    wdays = %w(日 月 火 水 木 金 土)
    # 出力
    date_time_info = result.map do |date, times|
      min_time = max_time = nil
      spans = []
      times.each do |time, info|
        time = DateTime.parse(time)
        min_time ||= time
        max_time = time
        if (is_free && info[:free]) || (!is_free && !info[:free])
          next
        else
          if min_time && max_time && min_time < max_time
            spans << "#{min_time.strftime("%-H:%M")}-#{max_time.strftime("%-H:%M")}"
          end
          min_time = max_time = nil
        end
      end

      if min_time && max_time && min_time < max_time
        spans << "#{min_time.strftime("%-H:%M")}-#{max_time.strftime("%-H:%M")}"
      end

      tmp_date = Date.parse(date)
      spans_text = spans.empty? ? "" : " #{spans.join(", ")}"
      "#{tmp_date.strftime("%Y/%m/%d")}(#{wdays[tmp_date.wday]})#{spans_text}"
    end

    date_time_info.join("\n")
  end

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def self.authorize
    client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
    token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
    authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
    user_id = "default"
    credentials = authorizer.get_credentials user_id
    if credentials.nil?
      url = authorizer.get_authorization_url base_url: OOB_URI
      puts "Open the following URL in the browser and enter the " \
         "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

  private

  def self.stdout_calendar_info(event, is_all_date)
    start_date_time = event.start.date || event.start.date_time
    end_date_time = event.end.date || event.end.date_time

    description =
      if is_all_date
        "#{start_date_time.strftime("%Y/%m/%d")} 終日"
      else
        if start_date_time.to_date == end_date_time.to_date
          "#{start_date_time.strftime("%Y/%m/%d %-H:%M")}-#{end_date_time.strftime("%-H:%M")}"
        else
          "#{start_date_time.strftime("%Y/%m/%d %-H:%M")}-#{end_date_time.strftime("%Y/%m/%d %-H:%M")}"
        end
      end
    puts "- [#{description}] #{event.summary} "
  end
end
