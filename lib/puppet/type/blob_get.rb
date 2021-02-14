Puppet::Type.newtype(:blob_get) do
  @doc = 'Azure Blob'

  ensurable do
    desc 'whether file should be present/absent (default: present)'

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)
  end

  newparam(:path, :namevar => :true) do
    desc 'Where to store the object on the local system'
  end

  newparam(:account) do
    desc 'Azure Storage Account Name'
  end

  newparam(:client_id) do
    desc 'The client_id of the associated user-managed identity'
  end

  newparam(:blob_path) do
    desc 'Path to the object in the form of [container]/[path]/[to]/[object]'
  end

  #newparam(:mode) do
  #  desc 'Permissions that should be applied to the file after downloading'
  #  defaultto('0644')
  #end
end
