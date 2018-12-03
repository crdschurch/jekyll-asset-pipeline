require 'spec_helper'

RSpec.describe 'Jekyll::AssetPipeline::Hooks' do

  before do
    @site = JekyllHelper.scaffold
    ENV['BUILD_ASSETS'] = 'true'
    @hook = Jekyll::AssetPipeline::Hooks.new(@site)
  end

  it 'should set default config values' do
    expect(@site.config['asset_dest']).to eq('assets')
    expect(@site.config['keep_files']).to include('assets')
  end

  it 'sets build_assets to true' do
    expect(@site.config['build_assets']).to eq(nil)
    @hook.init_build
    expect(@site.config['build_assets']).to eq(true)
  end

  it 'stores a reference to the hash file' do
    expect(@site.config['asset_hash']).to eq(nil)
    @hook.init_build
    expect(@site.config['asset_hash']).to_not eq(nil)
  end

end
