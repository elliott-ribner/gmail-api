require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'fileutils'
# http://stackoverflow.com/questions/25396463/how-to-send-message-using-gmail-api-with-ruby-google-api-client
require 'mime'
include MIME

APPLICATION_NAME = 'Gmail API Quickstart'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "gmail-quickstart.json")
SCOPE = 'https://www.googleapis.com/auth/gmail.readonly'

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization request via InstalledAppFlow.
# If authorization is required, the user's default browser will be launched
# to approve the request.
#
# @return [Signet::OAuth2::Client] OAuth2 credentials
def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  file_store = Google::APIClient::FileStore.new(CREDENTIALS_PATH)
  storage = Google::APIClient::Storage.new(file_store)
  auth = storage.authorize

  if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
    app_info = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
    flow = Google::APIClient::InstalledAppFlow.new({
      :client_id => app_info.client_id,
      :client_secret => app_info.client_secret,
      :scope => SCOPE})
    auth = flow.authorize(storage)
    puts "Credentials saved to #{CREDENTIALS_PATH}" unless auth.nil?
  end
  auth
end

# Initialize the API
client = Google::APIClient.new(:application_name => 'python-email')
client.authorization = authorize
gmail_api = client.discovered_api('gmail', 'v1')

# Show the user's labels
results = client.execute!(
  :api_method => gmail_api.users.labels.list,
  :parameters => { :userId => 'me' })

puts "Labels:"
puts "No labels found" if results.data.labels.empty?
results.data.labels.each { |label| puts "- #{label.name}" }


# http://stackoverflow.com/questions/25396463/how-to-send-message-using-gmail-api-with-ruby-google-api-client
msg = Mail.new
msg.date = Time.now
msg.subject = 'subject info'
msg.body = Text.new('body content')
msg.from = {'elr886@gmail.com' => 'Elliott Ribner'}
msg.to   = {
    'elliottlribner@gmail.com' => 'elliott ribner'
}
@email = @google_api_client.execute(
    api_method: @gmail.users.messages.to_h['gmail.users.messages.send'],
    body_object: {
        raw: Base64.urlsafe_encode64(msg.to_s)
    },
    parameters: {
        userId: 'me',
    }
)
