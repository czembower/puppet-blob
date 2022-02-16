Facter.add(:client_id) do
  setcode do
    if Facter.value(:az_meta) != 'unavailable'
      Facter.value(:az_meta)['compute']['tagsList'].select { |k| k['name'] == 'clientId' }[0]['value']
    else
      'unavailable'
    end
  end
end
