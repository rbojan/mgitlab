# mgitlab

**mgitlab** (or multi gitlab) is a companion for the GitLab CLI of your
choice which currently supports

* `mgitlab sync`: sync (git clone/pull) your Projects and Groups to a local path
* `mgitlab vars`: print GitLab CI/CD Variables of Groups and Projects in a tree

Motivation: open source my private swiss-army knife for GitLab which is useful
when you are working with multiple projects/groups and/or multiple GitLab instances.

Under the hood `mgitlab` uses [NARKOZ/gitlab](https://github.com/NARKOZ/gitlab)
Ruby wrapper and CLI for the GitLab REST API.

## Installation

### Via `gem install`

```sh
gem install mgitlab
```

### Via `Gemfile` and `bundle install`

Add this line to your application's Gemfile:

```ruby
gem 'mgitlab'
```

And then execute:

```sh
bundle install
```

## Usage

Configure GitLab credentials using ENV variables:

```sh
export GITLAB_API_ENDPOINT=https://gitlab.example.com/api/v4
export GITLAB_API_PRIVATE_TOKEN="***"
```

### `mgitlab sync <local_base_path>`

This command assumes that you have a `<local_base_path>` per GitLab instance
that you want to sync.

Example for two GitLab instances and their respective `local_base_path`:

```txt
~/projects/current/gitlab.example.com
~/projects/current/gl.company.com
```

Switch between GitLab instances by setting the `GITLAB_API_ENDPOINT` and
`GITLAB_API_PRIVATE_TOKEN` ENV variables.

You can control which projects/groups you want to include/exclude via
`MGITLAB_SYNC_INCLUDE` and `MGITLAB_SYNC_EXCLUDE` ENV variables.

Examples

Sync all projects/groups to `~/projects/current/gitlab.example.com`:

```sh
mgitlab sync ~/projects/current/gitlab.example.com
```

Sync only projects/groups with `devops/infra` in the path of the project/group
located in your GitLab instance (here: `gitlab.example.com`)
to `~/projects/current/gitlab.example.com`:

```sh
$ export MGITLAB_SYNC_INCLUDE=devops/infra

$ mgitlab sync ~/projects/current/gitlab.example.com
GITLAB_API_ENDPOINT set to https://gitlab.example.com/api/v4
Local base path set to /Users/rbojan/projects/current/gitlab.example.com
Detected MGITLAB_SYNC_INCLUDE=devops/infra

Check https://gitlab.example.com/devops/infra/kubernetes ...
Create project/group /Users/rbojan/projects/current/gitlab.example.com/devops/infra ...
Clone https://gitlab.example.com/devops/infra/kubernetes into /Users/rbojan/projects/current/gitlab.example.com/devops/infra ...
```

### `mgitlab vars <gitlab_path>`

Print GitLab CI/CD Variables of Groups and Projects in a tree.

```
mgitlab vars devops
mgitlab vars devops/infra 
```

Example:

```sh
$ mgitlab vars devops/infra/kubernetes
GITLAB_API_ENDPOINT set to https://gitlab.example.com/api/v4
Get GitLab Groups and Projects ...
Build tree in devops/infra/kubernetes ...
-- devops (group)
   CIAO_URL
   CIAO_USER
   CIAO_PASSWORD
---- devops/infra (group)
     VAULT_ADDR
     VAULT_ROLE_ID
     VAULT_SECRET_ID
------ devops/infra/kubernetes (project)
       TF_VAR_ssh_private_key_path
       TF_VAR_ssh_public_key_path
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/rbojan/mgitlab>.
This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/mgitlab/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mgitlab project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mgitlab/blob/master/CODE_OF_CONDUCT.md).

## Maintainer

<https://github.com/rbojan>

