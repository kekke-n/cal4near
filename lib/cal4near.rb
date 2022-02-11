# frozen_string_literal: true

require_relative "cal4near/version"

module Cal4near
  class Error < StandardError; end

  def self.list
    # Initialize the API
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    start_date = DateTime.now
    end_date = DateTime.now.next_day(30)
    # Fetch the next 10 events for the user
    calendar_id = "primary"
    response = service.list_events(calendar_id,
                                   single_events: true,
                                   order_by: "startTime",
                                   time_min: start_date.rfc3339,
                                   time_max: end_date.rfc3339
    )
    puts "Upcoming events:"
    puts "No upcoming events found" if response.items.empty?
    busy_list = []
    response.items.each do |event|
      start_date_time = event.start.date || event.start.date_time
      end_date_time = event.end.date || event.end.date_time

      # start endが両方ともdate型の場合は終日の予定
      is_all_date = (event.start.date && event.end.date)

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

      if !is_all_date
        busy_list << {
          start: event.start.date_time,
          end: event.end.date_time
        }
      end
    end

    # 空き時間を検索する時間の範囲
    start_hour = 9
    end_hour = 19

    puts "Free time:"

    result = {}
    (start_date.to_date..end_date.to_date).each do |date|
      result[date] ||= {}

      start_work_time = Time.new(date.year, date.month, date.day, start_hour, 0, 0)
      end_work_time = Time.new(date.year, date.month, date.day, end_hour, 0, 0)

      start_work_time.to_i.step(end_work_time.to_i, 60*60).each_cons(2) do |c_time_int, n_time__int|
        current_time = Time.at(c_time_int)
        next_time = Time.at(n_time__int)

        # 現時刻より前はスキップ
        next if current_time.to_datetime < DateTime.now

        free = true
        result[date][current_time] = {}

        busy_list.each do |busy|
          busy_start = busy[:start]
          busy_end = busy[:end]
          current_datetime = current_time.to_datetime
          next_datetime = next_time.to_datetime

          if current_datetime < busy_end && busy_start < next_datetime
            free = false
            break
          end
        end

        result[date][current_time][:free] = free
      end
    end
    result
  end

  def self.stdout
    result = list
    wdays = %w(日 月 火 水 木 金 土)
    # 出力
    result.each do |date, times|
      min_time = max_time = nil
      spans = []
      times.each do |time, info|
        min_time ||= time
        max_time = time
        if info[:free]
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

      puts "#{date.strftime("%Y/%m/%d")}(#{wdays[date.wday]}) #{spans.join(", ")}"
    end
  end

  require "google/apis/calendar_v3"
  require "googleauth"
  require "googleauth/stores/file_token_store"
  require "date"
  require "fileutils"

  OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
  APPLICATION_NAME = "Google Calendar API Ruby Quickstart".freeze
  CREDENTIALS_PATH = "credentials.json".freeze
  # The file token.yaml stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  TOKEN_PATH = "token.yaml".freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

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
end
