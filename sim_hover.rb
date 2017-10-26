alt = 200.0
des_alt = 180.0

d = HoverData.new({
  altitude: alt,
  error: alt - des_alt,
  derivative: 3.1,
  integral: 23.1,
  throttle: 0.2,
  fuel: 239.34
})

print "sending"
begin
  while true do
    sleep 0.5
    ActionCable.server.broadcast("ksp", "hover" => d.to_json)
    print "."

    diff = rand(-4.0..4.0)
    d.data[:altitude] += diff
    d.data[:error] = diff
    d.data[:derivative] = diff / 0.5
    d.data[:integral] += diff
    d.data[:throttle] = (d.data[:throttle] + rand(-0.1..0.1)).clamp(0.0, 1.0)
    d.data[:fuel] -= rand(0.001...0.1)
  end
ensure
  ActionCable.server.broadcast("ksp", "nothing" => {})
end
