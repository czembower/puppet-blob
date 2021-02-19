Puppet::Type.newtype(:blob_get) do
  @doc = 'Azure Blob'

  ensurable do
    desc 'Whether object should be present/absent on the local filesystem (default: present)'

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)
  end

  newparam(:path) do
    isnamevar
    desc 'Where to store the object on the local system'
  end

  newparam(:account) do
    desc 'Azure Storage Account name'
  end

  newparam(:client_id) do
    desc 'The Client ID of the associated user-managed identity'
  end

  newparam(:blob_path) do
    desc 'Path to the object in the form of [container]/[path]/[to]/[object]'
  end

  newparam(:unzip) do
    desc 'Whether to unzip downloaded Blob object'
    defaultto(:false)
  end

  newparam(:creates) do
    desc 'File object created by the unzip process'
  end

  newparam(:file_asset) do
    desc 'Ensurable file object to be managed, based on "creates" parameter'
  end
end
