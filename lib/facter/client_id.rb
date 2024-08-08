Facter.add(:client_id) do
  setcode do
    begin
      Facter.value(:az_metadata)['compute']['tagsList'].select { |k| k['name'] == 'clientId' }[0]['value']
    rescue
      'unavailable'
    end
  end
end
