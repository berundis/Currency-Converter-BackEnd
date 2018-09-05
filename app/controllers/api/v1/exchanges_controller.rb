require 'net/http'
require 'open-uri'

class Api::V1::ExchangesController < ApplicationController

  @@exchange_array = []

  def index
    render json: Exchange.all, status: 200
  end

  def create
    name = exchange_params[:name]
    need_fetch = true
    value = nil
    @@exchange_array.each do |exchange|
      if exchange[:name] == name
        if Time.now - exchange[:created_at] < 1.minute
          value = exchange[:value]
          need_fetch = false
        else
          @@exchange_array.delete(exchange)
        end
      end
    end

    if need_fetch
      url = "https://free.currencyconverterapi.com/api/v6/convert?q=#{name}&compact=y"
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      value =  JSON(response.body)[exchange_params[:name]]['val']
      @@exchange_array << {name: name, value: value, created_at: Time.now}
    end
    answer = value.to_f * exchange_params[:value].to_f

    render json: answer.round(2), status: 200
  end

  private

  def exchange_params
    params.require(:exchange).permit(:value, :name)
  end

end
