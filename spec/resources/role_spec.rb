require 'spec_helper'

RSpec.describe Frontegg::Role, mock_frontegg: true do
  let(:frontegg_url) { 'https://api.frontegg.com' }
  let(:tenant_id) { 'tenant_123' }
  let(:role_resource) { described_class.new }

  describe '#find_by_key' do
    let(:role_key) { 'admin' }
    let(:roles_response) do
      [
        { 'key' => 'provider', 'id' => '1' },
        { 'key' => 'admin', 'id' => '2' },
        { 'key' => 'employee', 'id' => '3' }
      ]
    end

    before do
      stub_request(:get, "#{frontegg_url}/identity/resources/roles/v1")
        .with(headers: { 'frontegg-tenant-id' => tenant_id })
        .to_return(
          status: 200,
          body: roles_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    context 'when role exists' do
      subject(:response) { role_resource.find_by_key(role_key, tenant_id: tenant_id) }

      it 'finds the role by key' do
        expect(response).to eq(roles_response[1])
      end
    end

    context 'when role does not exist' do
      subject(:response) { role_resource.find_by_key('non_existent_role', tenant_id: tenant_id) }

      it 'returns nil' do
        expect(response).to be_nil
      end
    end
  end
end
