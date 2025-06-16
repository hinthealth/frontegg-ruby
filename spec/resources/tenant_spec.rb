require 'spec_helper'

RSpec.describe Frontegg::Tenant, mock_frontegg: true do
  let(:frontegg_url) { 'https://api.frontegg.com' }
  let(:tenant_id) { 'tenant_123' }
  let(:tenant_resource) { Frontegg::Tenant.new(tenant_id) }

  describe '#create' do
    subject(:response) { tenant_resource.create(name: 'example') }

    before do
      stub_request(:post, "#{frontegg_url}/tenants/resources/tenants/v1")
        .with(body: { tenantId: tenant_id, name: 'example', website: nil, logoUrl: nil, isReseller: false,
                      metadata: {}.to_json })
        .to_return(status: 200)
    end

    it 'creates tenant successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#update' do
    subject(:response) { tenant_resource.update(name: 'another name') }

    before do
      stub_request(:put, "#{frontegg_url}/tenants/resources/tenants/v1/#{tenant_id}")
        .with(body: { name: 'another name', website: nil, logoUrl: nil, isReseller: false, metadata: {}.to_json })
        .to_return(status: 200)
    end

    it 'updates tenant successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#retrieve' do
    subject(:response) { tenant_resource.retrieve }

    before do
      stub_request(:get, "#{frontegg_url}/tenants/resources/tenants/v1/#{tenant_id}")
        .to_return(status: 200)
    end

    it 'retrieves tenant successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#list' do
    subject(:response) { tenant_resource.list }

    before do
      stub_request(:get, "#{frontegg_url}/tenants/resources/tenants/v2?_filter&_limit")
        .to_return(status: 200)
    end

    it 'retrieves tenants successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#add_parent_tenant' do
    subject(:response) { tenant_resource.add_parent_tenant(parent_id: 'parent_id') }

    before do
      stub_request(:post, "#{frontegg_url}/tenants/resources/hierarchy/v1")
        .to_return(status: 200)
    end

    it 'adds parent tenant successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#remove_parent_tenant' do
    subject(:response) { tenant_resource.remove_parent_tenant(parent_id: 'parent_id') }

    before do
      stub_request(:delete, "#{frontegg_url}/tenants/resources/hierarchy/v1")
        .to_return(status: 200)
    end

    it 'removes parent tenant successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#create_invite' do
    let(:base_metadata) { { custom_field: 'custom_value' } }
    let(:user_id) { 'usr_123' }
    let(:expires_in_minutes) { 60 }
    let(:should_send_email) { true }
    let(:api_path) { "#{frontegg_url}/identity/resources/tenants/invites/v1" }

    # Default subject calling with all parameters
    subject(:response) do
      tenant_resource.create_invite(
        user_id: user_id,
        expires_in_minutes: expires_in_minutes,
        should_send_email: should_send_email,
        metadata: base_metadata
      )
    end

    let(:full_expected_body) do
      {
        tenantId: tenant_id,
        userId: user_id,
        expiresInMinutes: expires_in_minutes,
        shouldSendEmail: should_send_email,
        metadata: base_metadata
      }
    end

    let(:minimal_expected_body) do
      {
        tenantId: tenant_id,
        metadata: base_metadata
      }
    end

    shared_context 'stubbed_api_call' do |status:, body_to_match:, response_body: {}|
      before do
        stub_request(:post, api_path)
          .with(body: body_to_match)
          .to_return(status: status, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })
      end
    end

    context 'when invitation is created successfully with all parameters' do
      include_context 'stubbed_api_call', status: 201, body_to_match: :full_expected_body, response_body: { id: 'invite_123' }

      it 'returns a successful response' do
        expect(response.status).to eq 201
      end

      it 'calls the API with the correct parameters' do
        response # Trigger the request
        expect(a_request(:post, api_path).with(body: full_expected_body)).to have_been_made.once
      end
    end

    context 'when invitation is created successfully with only metadata' do
      subject(:response) { tenant_resource.create_invite(metadata: base_metadata) } # Override subject
      include_context 'stubbed_api_call', status: 201, body_to_match: :minimal_expected_body, response_body: { id: 'invite_456' }


      it 'returns a successful response' do
        expect(response.status).to eq 201
      end

      it 'calls the API with minimal parameters' do
        response # Trigger the request
        expect(a_request(:post, api_path).with(body: minimal_expected_body)).to have_been_made.once
      end
    end

    context 'when invitation is created successfully with should_send_email as false' do
      subject(:response) do
        tenant_resource.create_invite(
          should_send_email: false,
          metadata: base_metadata
        )
      end
      let(:current_expected_body) do
        {
          tenantId: tenant_id,
          shouldSendEmail: false,
          metadata: base_metadata
        }
      end
      include_context 'stubbed_api_call', status: 201, body_to_match: :current_expected_body, response_body: { id: 'invite_789' }

      it 'returns a successful response' do
        expect(response.status).to eq 201
      end

      it 'calls the API with shouldSendEmail as false' do
        response
        expect(a_request(:post, api_path).with(body: current_expected_body)).to have_been_made.once
      end
    end

    context 'when API returns an error (e.g., invalid input)' do
      # For error cases, the request body being sent is still the full one by default subject
      include_context 'stubbed_api_call', status: 400, body_to_match: :full_expected_body, response_body: { error: 'Invalid input' }

      it 'returns an error response' do
        expect(response.status).to eq 400
      end
    end

    context 'when API returns a server error' do
      include_context 'stubbed_api_call', status: 500, body_to_match: :full_expected_body, response_body: { error: 'Server error' }

      it 'returns an error response' do
        expect(response.status).to eq 500
      end
    end
  end
end
