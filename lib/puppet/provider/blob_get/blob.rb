Puppet::Type.type(:blob_get).provide(:default) do
  desc 'Retrieves an object from Azure Blob storage'

  def create
    if !azcopy
      metadata_uri = URI('http://169.254.169.254')
      connection = Net::HTTP.new(metadata_uri.host, metadata_uri.port)

      resource = "/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2F#{@resource[:account]}.blob.core.windows.net%2F&client_id=#{@resource[:client_id]}"

      header = { 'Metadata' => 'true' }
      request_and_headers = Net::HTTP::Get.new(resource, header)

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
            raise Puppet::Error, "Blob Service Response: #{blob_response.code}: #{blob_response.body}"
          end
          open(@resource[:path].to_s, 'wb') do |file|
            blob_response.read_body do |chunk|
              file.write(chunk)
            end
          end
        end
      end
    else
      azcopy_cmd = if Facter.value(:osfamily) == 'windows'
              escaped_path = @resource[:path].gsub(%r{ }, '` ')
              "powershell -command C:/ProgramData/azcopy/bin/azcopy.exe copy #{blob_uri} #{escaped_path}"
            else
              escaped_path = @resource[:path].gsub(%r{ }, '\ ')
              "/opt/azcopy/bin/azcopy copy #{blob_uri} #{escaped_path}"
            end
      Puppet::Util::Execution.execute(azcopy_cmd)
    end

    Dir.chdir(File.dirname(@resource[:path]))
    cmd = if Facter.value(:osfamily) == 'windows'
            escaped_path = @resource[:path].gsub(%r{ }, '` ')
            "powershell -command Expand-Archive #{escaped_path}"
          else
            escaped_path = @resource[:path].gsub(%r{ }, '\ ')
            "unzip #{escaped_path}"
          end

    Puppet::Util::Execution.execute(cmd) unless @resource[:unzip] == false
  end

  def destroy
    File.unlink(@resource[:file_asset])
  end

  def exists?
    File.exist?(@resource[:file_asset])
  end
end
