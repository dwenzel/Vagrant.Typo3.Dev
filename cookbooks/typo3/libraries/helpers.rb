module FileHelper
  # check if a files sha checksum equals a given checksum
  def self.equals_checksum(sha1_checksum, path_to_file) 
    sha1_checksum == Digest::SHA1.file(path_to_file).hexdigest
  end
end


