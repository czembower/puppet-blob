Puppet::Type.type(:blob_get).provide(:default) do
  desc 'Retrieves an object from Azure Blob storage'

  def create
    blob_uri = URI("https://#{@resource[:account]}.blob.core.windows.net/#{@resource[:blob_path]}")

    if @resource[:azcopy] == false
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
                     "powershell -command $env:AZCOPY_AUTO_LOGIN_TYPE = 'MSI';" \
                     "$env:AZCOPY_MSI_CLIENT_ID = '#{@resource[:client_id]}';" \
                     "C:/ProgramData/azcopy/bin/azcopy.exe copy #{blob_uri} '#{@resource[:path]}'"
                   else
                     escaped_path = @resource[:path].gsub(%r{ }, '\ ')
                     "AZCOPY_AUTO_LOGIN_TYPE='MSI' " \
                     "AZCOPY_MSI_CLIENT_ID='#{@resource[:client_id]}' " \
                     "/opt/azcopy/bin/azcopy copy #{blob_uri} #{escaped_path}"
                   end
      Puppet::Util::Execution.execute(azcopy_cmd)
    end

    wait_for_lock_cmd = 'powershell -command $lock=$True;' \
                        "While ($lock){If([System.IO.File]::Exists('#{@resource[:path]}')){Try{$stream=[System.IO.File]::Open('#{@resource[:path]}','Open','Write');" \
                        '$stream.Close();' \
                        '$stream.Dispose();' \
                        '$lock=$False}Catch{$lock=$True;Start-Sleep 1}}}'

    Timeout::timeout(30, Timeout::Error) do
      Puppet::Util::Execution.execute(wait_for_lock_cmd) if Facter.value(:osfamily) == 'windows'
    end

    if @resource[:unzip] == true && @resource[:mkdir] == true
      unzip_dir_name = File.basename(@resource[:path], File.extname(@resource[:path]))
      working_path = File.dirname(@resource[:path]) + '/' + unzip_dir_name
      Dir.mkdir(working_path)
    else
      working_path = File.dirname(@resource[:path])
    end

    Dir.chdir(working_path)

    unzip_cmd = if Facter.value(:osfamily) == 'windows'
                  "powershell -command Add-Type -Assembly 'System.IO.Compression.Filesystem';" \
                  "[System.IO.Compression.ZipFile]::ExtractToDirectory('#{@resource[:path]}', '#{working_path}')"
                else
                  escaped_path = working_path.gsub(%r{ }, '\ ')
                  "unzip #{escaped_path}"
                end

    Puppet::Util::Execution.execute(unzip_cmd) unless @resource[:unzip] == false

    if Facter.value(:osfamily) == 'windows'
      wait_for_post_unzip_lock_cmd = 'powershell -command $lock=$True;' \
                                     "While ($lock){If([System.IO.File]::Exists('#{@resource[:file_asset]}')){Try{$stream=[System.IO.File]::Open('#{@resource[:file_asset]}','Open','Write');" \
                                     '$stream.Close();' \
                                     '$stream.Dispose();' \
                                     '$lock=$False}Catch{$lock=$True;Start-Sleep 1}}}'

      Timeout::timeout(30, Timeout::Error) do
        Puppet::Util::Execution.execute(wait_for_post_unzip_lock_cmd, :failonfail => false) unless @resource[:unzip] == false
      end
    end
  end

  def destroy
    File.unlink(@resource[:file_asset])
  end

  def exists?
    File.exist?(@resource[:file_asset])
  end
end
