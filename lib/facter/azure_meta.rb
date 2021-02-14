Facter.add(:az_meta) do
  setcode do
    metadataUri = URI('http://169.254.169.254')
    connection = Net::HTTP.new(metadataUri.host, metadataUri.port)
    header = {"Metadata" => "true"}
    requestAndHeaders = Net::HTTP::Get.new('/metadata/instance?api-version=2020-06-01', header)
    response = connection.request(requestAndHeaders)
    if response.code == '200'
      metadata = JSON.parse(response.body)
    else
      metadata = 'unavailable'
    end
    metadata
  end
end

Facter.add(:client_id) do
  setcode do
    if Facter.value(:az_meta) != 'unavailable'
      Facter.value(:az_meta)['compute']['tagsList'].select{ |k| k['name'] == 'clientId'}[0]['value']
    else
      'unavailable'
    end
  end
end