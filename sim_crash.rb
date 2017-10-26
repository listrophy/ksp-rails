alt = 70.0
speed = 0.0
pitch = 90.0

throttle = 0.0
periapsis = 100_000.0
apoapsis = 100_000.0
stage = 1
orbitingBody = "Kerbin"
warpFactor = 1


d = CrashData.new({
  throttle: throttle,
  periapsis: periapsis,
  apoapsis: apoapsis,
  stage: stage,
  orbitingBody: orbitingBody,
  warpFactor: warpFactor
})

print "sending"
begin
  while true do
    sleep 0.5
    ActionCable.server.broadcast("ksp", "crash" => d.to_json)
    print "."

    diff = 1.0
    d.data[:throttle] += diff
    d.data[:periapsis] += d.data[:throttle]
    d.data[:apoapsis] -= d.data[:throttle]
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
