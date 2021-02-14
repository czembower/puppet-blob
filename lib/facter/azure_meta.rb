Facter.add(:az_meta) do
  setcode do
    metadata_uri = URI('http://169.254.169.254')
    connection = Net::HTTP.new(metadata_uri.host, metadata_uri.port)
    header = { 'Metadata' => 'true' }
    request_and_headers = Net::HTTP::Get.new('/metadata/instance?api-version=2020-06-01', header)
    response = connection.request(request_and_headers)
    metadata = if response.code == '200'
                 JSON.parse(response.body)
               else
                 'unavailable'
               end
    metadata
  end
end

Facter.add(:client_id) do
  setcode do
    if Facter.value(:az_meta) != 'unavailable'
      Facter.value(:az_meta)['compute']['tagsList'].select { |k| k['name'] == 'clientId' }[0]['value']
    else
      'unavailable'
    end
  end
end
