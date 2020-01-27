require 'rails_helper'

describe Badi::V1::Rooms do
  let!(:rooms) { create_list(:room, 15) }
  url = "/api/v1/rooms"

  describe 'GET /rooms?lat=x&lng=x&range=x' do
    # Good context
    context "URL Accepted" do

      it 'returns status code 200' do
        get "#{url}?lat=42.00001&lng=0.0000&range=500"
        expect(response).to have_http_status(200)
      end

      it 'returns status code 200' do
        get "#{url}?lat=42.00001&lng=0.0000&range=50.00&price=20.00"
        expect(response).to have_http_status(200)
      end

      it 'get latitude, longitude and range' do
        get "#{url}?lat=42.0000001&lng=0.0000&range=500"

        expect(request.params['lat'].to_f).to be_kind_of(Float)
        expect(request.params['lng'].to_f).to be_kind_of(Float)
        expect(request.params['range'].to_f).to be_kind_of(Float)
      end

      it 'get latitude, longitude, range and price price' do
        get "#{url}?lat=42.0000001&lng=0.0000&range=500&price=20"

        expect(request.params['lat'].to_f).to be_kind_of(Float)
        expect(request.params['lng'].to_f).to be_kind_of(Float)
        expect(request.params['range'].to_f).to be_kind_of(Float)
        expect(request.params['price'].to_f).to be_kind_of(Float)
      end

      let!(:room){ create_list(:room, 2, lat: 42.00301, lng: 0.003) }
      let!(:wrong_room){ create_list(:room, 2, lat: 43.00301, lng: 0.003) }

      it 'returns a room list' do
        get "#{url}?lat=42.0000001&lng=0.0000&range=500&price=20"
        expect(json).to_not be_empty
        expect(json.size).to eq(2)
      end
    end

    # Bad context
    context "URL Not Accepted" do
      it 'returns status code 400 no params' do
        get "#{url}"
        expect(response).to have_http_status(:bad_request)
      end

      it 'should contain an error message' do
        get "#{url}?lat=AA&lng=bb&range=-1&price=-2"
        expect(json.first["messages"].first.to_s) == "is required"
        expect(json.first["messages"].first.to_s) == "is invalid"
        expect(json.first["messages"].last.to_s) == "cannot be blank"
      end

      it 'returns status code 400 Invalid param name' do
        get "#{url}?lot=42.0000001&lng=0.0000&range=500:"
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns status code 400 Invalid number of params' do
        get "#{url}?lat=42.0000001&lng=0.0000:"
        expect(response).to have_http_status(:bad_request)
      end

      let!(:room){ create_list(:room, 2, lat: 43.00301, lng: 0) }
      it 'returns a void room list' do
        get "#{url}?lat=42.0000001&lng=0.0000&range=500&price=20"
        expect(json).to be_empty
      end

    end
  end
end
