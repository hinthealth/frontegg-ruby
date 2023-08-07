## Frontegg Ruby Library

This is a ruby lib that allows to use the [Frontegg API](https://docs.frontegg.com/reference/getting-started-with-your-api)

### Setup

To install using bundler:
```
gem 'frontegg', github: 'hinthealth/frontegg'
```


```ruby
Frontegg.configure do |config|
  config.client_id = 'your_client_id'
  config.api_key =  'your_api_key'
  config.log_enabled = false
end
```

### Usage

#### Create user

```ruby
Frontegg::User.new.create(
  tenant_id:, # required
  email:, # required
  name:, # required
  metadata:,
  password:,
)
```

#### Migrate existing user

```ruby
Frontegg::User.new.migrate_existing(
  tenant_id:, # required
  email:, # required
  name:, # required
  metadata:,
  password_hash:,
  mfa_code:,
)
```

#### Add user to tenant

```ruby
Frontegg::User.new(frontegg_user_id).add_to_tenant(tenant_id)
```


#### Switch user tenant

```ruby
Frontegg::User.new(frontegg_user_id).switch_tenant(tenant_id)
```

#### Delete user

```ruby
Frontegg::User.new(frontegg_user_id).delete(tenant_id:) # tenant is optional
```


#### Retrieve user

```ruby
Frontegg::User.new(frontegg_user_id).retrieve(tenant_id:) # tenant is optional
```

#### Make super user

```ruby
Frontegg::User.new(frontegg_user_id).make_superuser # tenant is optional
```


#### Verify user

```ruby
Frontegg::User.new(frontegg_user_id).verify
```

#### Expire sessions

```ruby
Frontegg::User.new(frontegg_user_id).expire_sessions(session_id) # session_id is optional
```
