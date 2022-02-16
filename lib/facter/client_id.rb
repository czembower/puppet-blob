Facter.add(:client_id) do
  setcode do
    if Facter.value(:az_metadata) != 'unavailable'
      Facter.value(:az_metadata)['compute']['tagsList'].select { |k| k['name'] == 'clientId' }[0]['value']
    else
      'unavailable'
    end
  end
end
