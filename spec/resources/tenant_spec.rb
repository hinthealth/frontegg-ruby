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
end
