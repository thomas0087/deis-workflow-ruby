require 'securerandom'
require 'fileutils'
require 'httparty'
require 'json'

module DeisWorkflow
  class Client

    def initialize(uri, api_key)
      @api_key = api_key
      @controller_uri = uri
      @headers = { 'Authorization' => 'token %s' % @api_key, 'Content-Type' => 'application/json' }
    end

    # returns an api_key for that user
    def self.login(username, password, uri)
      HTTParty.post(
        "#{uri}/v2/auth/login/",
        :body => JSON.dump({
          :username => username,
          :password => password
        }),
        :headers => { 'Content-Type' => 'application/json' }
      ).parsed_response['token']
    end

    ### Cluster level methods

    def whoami
      get('/v2/auth/whoami').parsed_response['username']
    end
    
    def users_list
      get('/v2/users').parsed_response['results']
    end

    # registers a new user to the cluster
    # returns a generated password
    def register(username, email)
      password = SecureRandom.urlsafe_base64
      post('/v2/auth/register/', {
        :username => username,
        :password => password,
        :email    => email
      })
      # TODO handle the same user registering twice
      password
    end

    ### App level methods

    def apps_list_all
      get("/v2/apps").parsed_response
    end

    def app_exists?(app_name)
      get("#{app_path(app_name)}").success?
    end

    def app_create(app_name)
      post("/v2/apps", {
        :id => app_name
      }).success?
    end

    def app_logs(app_name)
      get("#{app_path(app_name)}/logs/").parsed_response
    end

    def app_releases(app_name)
      get("#{app_path(app_name)}/releases").parsed_response
    end

    ### App pod related methods

    def app_scale(app_name, pod_type, desired_pod_count)
      post("#{app_path(app_name)}/scale/", {
        pod_type.to_sym => desired_pod_count
      }).success?
    end

    def app_list_pods(app_name)
      get("#{app_path(app_name)}/pods/").parsed_response
    end

    def app_restart(app_name)
      post("#{app_path(app_name)}/pods/restart/").success?
    end

    ### App permissions methods

    def perms_create(app_name, username)
      post("#{app_path(app_name)}/perms/", {
        :username => username
      }).success?
    end

    def perms_delete(app_name, username)
      delete("#{app_path(app_name)}/perms/#{username}/").success?
    end

    def perms_list(app_name)
      get("#{app_path(app_name)}/perms/").parsed_response['users']
    end

    ### App config methods
    
    def config_list(app_name)
      get("#{app_path(app_name)}/config/").parsed_response['values']
    end

    # values should be a hash
    # unset by assigning values to nil
    def config_set(app_name, values)
      post("#{app_path(app_name)}/config/", {
        :values => values
      }).success?
    end

    def app_limit_set(app_name, limit_type, pod_type, limit)
      return false unless %w(memory cpu).include?(limit_type)
      post("#{app_path(app_name)}/config/", {
        limit_type => { pod_type => limit }
      }).success?
    end

    def app_limit_unset(app_name, limit_type, pod_type)
      return false unless %w(memory cpu).include?(limit_type)
      post("#{app_path(app_name)}/config/", {
        limit_type => { pod_type => nil }
      }).success?
    end


    private

    def app_path(app_name)
      "/v2/apps/#{app_name}"
    end

    def get(path)
      HTTParty.get(
        "#{@controller_uri}#{path}",
        :headers => @headers
      )
    end

    def post(path, body = nil)
      HTTParty.post(
        "#{@controller_uri}#{path}",
        :body => JSON.dump(body),
        :headers => @headers
      )
    end

    def delete(path)
      HTTParty.post(
        "#{@controller_uri}#{path}",
        :headers => @headers
      )
    end

  end
end
