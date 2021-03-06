require 'fileutils'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/calendar_v3'
require 'time'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Ruby Quickstart'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials', "tokens.yaml")
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' +
         'resulting code after authorization'
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

# Initialize the API
service = Google::Apis::CalendarV3::CalendarService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

today = Date.today.strftime('%Y-%m-%dT00:00:00+09:00')
tomorrow = (Date.today + 1).strftime('%Y-%m-%dT00:00:00+09:00')
puts "#{today} 〜 #{tomorrow}"
result = service.list_events('ja.japanese#holiday@group.v.calendar.google.com', time_min: today, time_max: tomorrow)
if result.items.count == 0
  puts 'Today is not holiday.'
else
  puts result.items.first.summary
  puts result.items.first.start
end

result = service.list_events('ja.japanese#holiday@group.v.calendar.google.com', time_min: '2015-09-21T00:00:00+09:00', time_max: '2015-09-22T00:00:00+09:00')
puts '2015-09-21T00:00:00+09:00 〜 2015-09-22T00:00:00+09:00'
puts result.items.first.summary
