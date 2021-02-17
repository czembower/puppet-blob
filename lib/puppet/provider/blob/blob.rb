Puppet::Type.type(:blob).provide(:get) do
  desc 'Retrieves an object from Azure Blob storage'

  def create
    metadata_uri = URI('http://169.254.169.254')
    connection = Net::HTTP.new(metadata_uri.host, metadata_uri.port)

    header = { 'Metadata' => 'true' }
    request_and_headers = Net::HTTP::Get.new("/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2F#{@resource[:account]}.blob.core.windows.net%2F&client_id=#{@resource[:client_id]}", header)

    response = connection.request(request_and_headers)
    token = JSON.parse(response.body)['access_token']

    if token.nil?
      raise Puppet::Error, 'No token received from Azure metadata service.'
    end

    blob_uri = URI("https://#{@resource[:account]}.blob.core.windows.net/#{@resource[:blob_path]}")

    Net::HTTP.start(blob_uri.host, blob_uri.port, :use_ssl => blob_uri.scheme == 'https') do |http|
      header = { 'Authorization' => "Bearer #{token}", 'x-ms-version' => '2017-11-09' }
      request = Net::HTTP::Get.new(blob_uri, header)
      http.request(request) do |blob_response|
        if blob_response.code != '200'
          raise Puppet::Error, "#{blob_response.code}"
        end
        open("#{@resource[:path]}", 'wb') do |file|
          blob_response.read_body do |chunk|
            file.write(chunk)
          end
        end
      end
    end
  
    if [:unzip]
      unzip(@resource[:path])
    end
  
    if [:mode]
      change_mode(@resource[:path])
    end
  end

  def destroy
    File.unlink(@resource[:path])
  end

  def exists?
    File.exist?(@resource[:path])
  end

  def change_mode(file)
    if Puppet::Util::Platform.windows?
      Puppet::Util::Windows::Security.set_mode(@resource[:mode], Puppet::FileSystem.path_string(@resource[:path]))
    else
      FileUtils.chmod_R(@resource[:mode], Puppet::FileSystem.path_string(@resource[:path]))
    end
  end

  def unzip(file)
    os.chdir(File.dirname(file))

    if Facter.value(:osfamily) == 'windows'
      cmd = "powershell -command Expand-Archive #{file}"
    else
      cmd = "unzip #{file}"
    end

    Puppet::Util::Execution.execute(cmd)
end
