class KspChannel < ApplicationCable::Channel
  def subscribed
    stream_from "ksp" unless current_user == :publisher
    transmit({"hover" => {foo: 'bazzle'}}.to_json)
  end

  def unsubscribed
    puts "current_user: #{current_user}"
  end

  def hover(data)
    return unless user_can_publish?

    ActionCable.server.broadcast("ksp", {"hover" => data})
  end

  def orbit(data)
    return unless user_can_publish?

    ActionCable.server.broadcast("ksp", {"orbit" => data})
  end

  def crash(data)
    return unless user_can_publish?

    ActionCable.server.broadcast("ksp", {"crash" => data})
  end

  private
  def user_can_publish?
    puts "testing if user can publish: #{current_user.inspect}"
    current_user == :publisher
  end
end
