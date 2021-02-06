# frozen_string_literal: true

require 'mgitlab/version'
require 'gitlab'
require 'thor'

module Mgitlab
  class Helpers
    def self.configure_gitlab_client
      endpoint = ENV.fetch('GITLAB_API_ENDPOINT', '')
      private_token = ENV.fetch('GITLAB_API_PRIVATE_TOKEN', '')

      if endpoint == '' || private_token == ''
        puts 'ERROR: GITLAB_API_ENDPOINT and/or GITLAB_API_PRIVATE_TOKEN not set'
        exit 1
      else
        Gitlab.endpoint = endpoint
        Gitlab.private_token = private_token
        puts "GITLAB_API_ENDPOINT set to #{endpoint}"
      end
    end
  end

  class CLI < Thor
    desc 'sync <local_base_path>', 'sync to <local_base_path>'
    def sync(local_base_path)
      Helpers.configure_gitlab_client

      local_base_path = local_base_path.length.zero? ? '.' : local_base_path.to_s
      puts "Local base path set to #{File.expand_path(local_base_path)}"

      ENV['MGITLAB_SYNC_EXCLUDE'] ||= ''
      words_exclude = ENV['MGITLAB_SYNC_EXCLUDE'].split(',')
      puts "Detected MGITLAB_SYNC_EXCLUDE=#{ENV['MGITLAB_SYNC_EXCLUDE']}" if words_exclude.any?

      ENV['MGITLAB_SYNC_INCLUDE'] ||= ''
      words_include = ENV['MGITLAB_SYNC_INCLUDE'].split(',')
      puts "Detected MGITLAB_SYNC_INCLUDE=#{ENV['MGITLAB_SYNC_INCLUDE']}" if words_include.any?

      projects = Gitlab.projects(membership: true)

      projects.auto_paginate do |project|
        path = File.expand_path(File.join(local_base_path, project.path_with_namespace))
        namespace_path = File.expand_path(File.join(local_base_path, project.namespace.full_path))
        puts "\nCheck #{project.web_url} ..."

        if words_include.any?
          unless words_include.any? { |word| path.include?(word) }
            puts "Project #{project.web_url} not included"
            next
          end
        end

        if words_exclude.any? { |word| path.include?(word) }
          puts "Project #{project.web_url} excluded"
        else
          if File.directory? path
            puts "Try to pull in #{path} ..."
            `cd #{path} && git pull`
          else
            puts "Create project/group #{namespace_path} ..."
            `mkdir -p #{namespace_path}`
            puts "Clone #{project.web_url} into #{namespace_path} ..."
            `mkdir -p #{namespace_path} && cd #{namespace_path} && git clone #{project.ssh_url_to_repo}`
          end
        end
      end
    end

    desc 'vars <gitlab_path>', 'print vars in <gitlab_path>'
    def vars(gitlab_path)
      Helpers.configure_gitlab_client

      puts 'Get GitLab Groups and Projects ...'
      groups = Gitlab.groups(membership: true).auto_paginate
      projects = Gitlab.projects(membership: true).auto_paginate

      puts "Build tree in #{gitlab_path} ..."
      groups_and_projects = []
      groups.each do |g|
        groups_and_projects << { kind: 'group', full_path: g.full_path } if g.full_path.include?(gitlab_path)
      end
      projects.each do |p|
        if p.path_with_namespace.include?(gitlab_path)
          groups_and_projects << { kind: 'project', full_path: p.path_with_namespace }
        end
      end

      # Add parent directories
      folders = gitlab_path.split('/')
      (1..(folders.length - 1)).each do |i|
        groups_and_projects << { kind: 'group', full_path: folders.first(i).join('/') }
      end

      groups_and_projects_sorted = groups_and_projects.sort_by { |h| h[:full_path] }

      groups_and_projects_sorted.each do |n|
        offset = n[:full_path].scan(%r{/}).length + 1
        offset_str = '--' * offset
        offset_str_var = '  ' * offset + ''
        puts "#{offset_str} #{n[:full_path]} (#{n[:kind]})"
        if n[:kind] == 'project'
          Gitlab.variables(n[:full_path]).auto_paginate.each do |v|
            puts "#{offset_str_var} #{v.key}"
          end
        else
          Gitlab.group_variables(n[:full_path]).auto_paginate.each do |v|
            puts "#{offset_str_var} #{v.key}"
          end
        end
      end
    end

    def self.exit_on_failure?
      true
    end
  end
end
