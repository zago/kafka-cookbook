# encoding: utf-8

require 'spec_helper'

describe 'kafka::source' do
  let :chef_run do
    ChefSpec::Runner.new(step_into: %w(kafka_download kafka_install)) do |node|
      node.set[:kafka][:install_method] = :source
    end.converge(described_recipe)
  end

  it 'downloads remote source release of Kafka' do
    expect(chef_run).to create_kafka_download("#{Chef::Config[:file_cache_path]}/kafka-0.8.0-src.tgz").with({
      source: 'https://archive.apache.org/dist/kafka/0.8.0/kafka-0.8.0-src.tgz',
      checksum: 'f4b7229671aba98dba9a882244cb597aab8a9018631575d28e119725a01cfc9a',
      md5_checksum: '46b3e65e38f1bde4b6251ea131d905f4',
      mode: '644'
    })

    expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/kafka-0.8.0-src.tgz").with({
      source: 'https://archive.apache.org/dist/kafka/0.8.0/kafka-0.8.0-src.tgz',
      checksum: 'f4b7229671aba98dba9a882244cb597aab8a9018631575d28e119725a01cfc9a',
      mode: '644'
    })
  end

  it 'validates download' do
    expect(chef_run).not_to run_ruby_block('kafka-validate-download')

    remote_file = chef_run.remote_file("#{Chef::Config[:file_cache_path]}/kafka-0.8.0-src.tgz")
    expect(remote_file).to notify('ruby_block[kafka-validate-download]').immediately
  end

  it 'compiles Kafka source' do
    expect(chef_run).to run_execute('compile-kafka').with_cwd('/opt/kafka/build')
  end

  it 'installs compiled Kafka source' do
    expect(chef_run).to run_kafka_install('/opt/kafka')

    expect(chef_run).to run_execute('install-kafka')
  end
end
