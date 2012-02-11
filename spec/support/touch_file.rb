class TouchFile

  def call(data, job)
    File.open(data, 'w+')
  end

end
