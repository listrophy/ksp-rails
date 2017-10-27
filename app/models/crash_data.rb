class CrashData

  ATTRS = %i(throttle periapsis apoapsis stage orbitingBody warpFactor)

  attr_reader :data

  def initialize(data)
    str_attrs = ATTRS.map(&:to_s)
    @data = data.select {|k,_| str_attrs.include?(k.to_s)}
  end

  def as_json(options = nil)
    @data
  end
end
