alt = 70.0
speed = 0.0
pitch = 90.0

d = OrbitData.new({
  altitude: alt,
  speed: speed,
  pitch: pitch,
  stage: "stage 1"
})

print "sending"
begin
  while true do
    sleep 0.5
    ActionCable.server.broadcast("ksp", "orbit" => d.to_json)
    print "."

    diff = 1.0
    d.data[:speed] += diff
    d.data[:altitude] += d.data[:speed]
    d.data[:pitch] -= 0.05
    d.data[:stage] =
      case d.data[:altitude]
      when 0.0...50.0 then "stage 1"
      when 50.0...150.0 then "stage 2"
      when 150...1000.0 then "stage 3"
      else "stage 4"
      end
  end
ensure
  ActionCable.server.broadcast("ksp", "nothing" => {})
end
