# frozen_string_literal: true

require 'spec_helper'

describe OmniAuth::Strategies::Oktaoauth do

  subject { described_class.new({}) }

  let(:base_url) { 'https://your-org.okta.com' }

  describe '#client' do
    let(:client_options) do
      {
        site: base_url,
        authorize_url: "#{base_url}/oauth2/v1/authorize",
        token_url: "#{base_url}/oauth2/v1/token",
        response_type: 'id_token',
      }
    end

    subject do
      described_class.new(nil, {
        client_id: 'client-id',
        client_secret: 'client-secret',
        client_options:,
      })
    end

    it 'has default site' do
      expect(subject.client.site).to eq(base_url)
    end

    context 'with configured client options' do
      it 'uses the configured site' do
        expect(subject.options.client_options.site).to eq(base_url)
      end

      it 'uses the configured authorize URL' do
        expect(subject.options.client_options.authorize_url).to eq("#{base_url}/oauth2/v1/authorize")
      end

      it 'uses the configured token URL' do
        expect(subject.options.client_options.token_url).to eq("#{base_url}/oauth2/v1/token")
      end

      it 'uses the configured response type' do
        expect(subject.options.client_options.response_type).to eq('id_token')
      end
    end
  end

  describe '#callback_path' do
    it 'has the correct callback path' do
      expect(subject.callback_path).to \
      eq('/auth/oktaoauth/callback')
    end
  end

  describe '#callback_url' do
    let(:redirect_uri) { 'https://app.example.com/users/auth/oktaoauth/callback' }
    subject { described_class.new(nil, { redirect_uri: }) }

    it 'uses the configured redirect URI' do
      expect(subject.callback_url).to eq(redirect_uri)
    end
  end

  describe '#uid' do
    before :each do
      allow(subject).to receive(:raw_info) { { 'sub' => 'uid' } }
    end

    it 'returns the id from raw_info' do
      expect(subject.uid).to eq('uid')
    end
  end

  describe '#info' do
    before :each do
      allow(subject).to receive(:raw_info) { {} }
    end

    context 'has the necessary fields' do
      it { expect(subject.info).to have_key :name }
      it { expect(subject.info).to have_key :email }
      it { expect(subject.info).to have_key :first_name }
      it { expect(subject.info).to have_key :last_name }
      it { expect(subject.info).to have_key :image }
    end
  end

  describe 'extra' do
    before :each do
      subject.options.skip_jwt = true
      subject.options.skip_info = false
      allow(subject).to receive(:raw_info) { { :foo => 'bar' } }
      allow(subject).to receive(:oauth2_access_token).and_return(
        OAuth2::AccessToken.new(subject.client, 'id-token')
      )
    end

    it { expect(subject.extra[:raw_info]).to eq({ foo: 'bar' }) }
  end

  describe 'id_token' do
  end

  describe 'raw_info' do
  end
end
