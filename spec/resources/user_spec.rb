require 'spec_helper'

RSpec.describe Frontegg::User, mock_frontegg: true do
  let(:frontegg_url) { 'https://api.frontegg.com' }
  let(:user_id) { 'idp_123' }
  let(:tenant_id) { 'tenant_123' }
  let(:user_resource) { Frontegg::User.new(user_id) }

  describe '#create' do
    let(:create_url) { "#{frontegg_url}/identity/resources/users/v1/" }

    before do
      stub_request(:post, create_url)
        .to_return(status: 200)
    end

    context 'with no skip_invite_email param' do
      subject(:create_user) do
        Frontegg::User.new.create(
          email: 'example@example.com',
          name: 'John Doe',
          tenant_id: tenant_id
        )
      end

      it 'creates user with skipInviteEmail set to true' do
        create_user
        assert_requested(:post, create_url, body: hash_including(skipInviteEmail: true))
      end
    end

    context 'with skip_invite_email param set to false' do
      subject(:create_user) do
        Frontegg::User.new.create(
          email: 'example@example.com',
          name: 'John Doe',
          tenant_id: tenant_id,
          skip_invite_email: skip_invite_email
        )
      end
      let(:skip_invite_email) { false }

      it 'creates user with skipInviteEmail set to false' do
        create_user
        assert_requested(:post, create_url, body: hash_including(skipInviteEmail: false))
      end
    end
  end

  describe '#add_to_tenant' do
    let(:tenant_path) { "#{frontegg_url}/identity/resources/users/v1/#{user_id}/tenant" }

    before do
      stub_request(:post, tenant_path)
        .to_return(status: 200)
    end

    context 'with no skip_invite_email param' do
      subject(:add_to_tenant) do
        user_resource.add_to_tenant(tenant_id)
      end

      it 'adds user to tenant with skipInviteEmail set to true' do
        add_to_tenant
        assert_requested(:post, tenant_path, body: { tenantId: tenant_id, skipInviteEmail: true })
      end
    end

    context 'with skip_invite_email param set to false' do
      subject(:add_to_tenant) do
        user_resource.add_to_tenant(tenant_id, skip_invite_email: false)
      end

      it 'adds user to tenant with skipInviteEmail set to false' do
        add_to_tenant
        assert_requested(:post, tenant_path, body: { tenantId: tenant_id, skipInviteEmail: false })
      end
    end
  end

  describe '#switch_tenant' do
    subject(:response) { user_resource.switch_tenant(tenant_id) }

    before do
      stub_request(:put, "#{frontegg_url}/identity/resources/users/v1/#{user_id}/tenant")
        .to_return(status: 200)
    end

    it 'switches tenant successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#make_superuser' do
    subject(:response) { user_resource.make_superuser }

    before do
      stub_request(:put, "#{frontegg_url}/identity/resources/users/v1/#{user_id}/superuser")
        .to_return(status: 200)
    end

    it 'makes user super user successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#retrieve' do
    subject(:response) { user_resource.retrieve(tenant_id:) }

    before do
      stub_request(:get, "#{frontegg_url}/identity/resources/users/v1/#{user_id}")
        .to_return(status: 200)
    end

    it 'retrieves user successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#delete' do
    subject(:response) { user_resource.delete }

    before do
      stub_request(:delete, "#{frontegg_url}/identity/resources/users/v1/#{user_id}")
        .to_return(status: 200)
    end

    it 'deletes user successfully' do
      expect(response.status).to eq 200
    end
  end

  describe '#migrate_existing' do
    let(:migrate_url) { "#{frontegg_url}/identity/resources/migrations/v1/local" }
    subject(:response) do
      Frontegg::User.new.migrate_existing(
        email: 'example@example.com',
        name: 'John Doe',
        password_hash: 'password_hash',
        metadata: {},
        tenant_id: tenant_id
      )
    end

    before do
      stub_request(:post, migrate_url)
        .to_return(status: 200, body: { id: user_id }.to_json)
    end

    it 'migrates user successfully' do
      expect(response.status).to eq 200
      expect(response.body).to include('id')
    end

    context 'when roles are provided' do
      subject(:response) do
        Frontegg::User.new.migrate_existing(
          email: 'example@example.com',
          name: 'John Doe',
          password_hash: 'password_hash',
          metadata: {},
          tenant_id: tenant_id,
          role_ids: ['role_123']
        )
      end

      it 'migrates user successfully' do
        expect(response.status).to eq 200
        assert_requested(:post, migrate_url, body: hash_including(roleIds: ['role_123']))
      end
    end
  end

  describe '#accept_invitation' do
    subject(:response) do
      Frontegg::User.new.accept_invitation(
        user_id: user_id,
        token: 'token',
      )
    end

    before do
      stub_request(:post, "#{frontegg_url}/identity/resources/users/v1/invitation/accept")
        .to_return(status: 200, body: { id: user_id }.to_json)
    end

    it 'migrates user successfully' do
      expect(response.status).to eq 200
      expect(response.body).to include('id')
    end
  end

  describe '#add_role' do
    let(:role_id) { 'role_123' }

    context 'when tenant_id is provided' do
      subject(:response) { user_resource.add_role(role_id, tenant_id: tenant_id) }

      before do
        stub_request(:post, "#{frontegg_url}/identity/resources/users/v1/#{user_id}/roles")
          .with(headers: { 'frontegg-tenant-id' => tenant_id })
          .with(body: { roleIds: [role_id] })
          .to_return(status: 200)
      end

      it 'adds role successfully' do
        expect(response.status).to eq 200
      end
    end

    context 'when tenant_id is not provided' do
      subject(:response) { user_resource.add_role(role_id) }

      before do
        stub_request(:post, "#{frontegg_url}/identity/resources/users/v1/#{user_id}/roles")
          .with(body: { roleIds: [role_id] })
          .to_return(status: 200)
      end

      it 'adds role successfully' do
        expect(response.status).to eq 200
      end
    end
  end
end
