class KspChannel < ApplicationCable::Channel
  def subscribed
    stream_from "ksp" unless current_user == :publisher
    transmit({"hover" => {foo: 'bazzle'}}.to_json)
  end

  def unsubscribed
  end

  def hover(data)
    return unless user_can_publish?

    ActionCable.server.broadcast("ksp", {"hover" => HoverData.new(data).to_json})
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
    current_user == :publisher
  end
end
