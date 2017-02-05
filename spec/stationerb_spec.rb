require 'spec_helper'

describe Stationerb do
  it 'has a version number' do
    expect(Stationerb::VERSION).not_to be nil
  end

  context 'Configuration' do

    it 'has a default configuration' do
      expect(Stationerb.configuration).to_not be_nil
    end

    it 'has a default built_in_views_path' do
      gem_lib_view = File.expand_path(File.join(__FILE__, "..", "..", "lib", "views"))
      expect(Stationerb.configuration.built_in_views).to eq(gem_lib_view)
    end

    it 'has a default font' do
      expect(Stationerb.configuration.font).to_not be_nil
    end

    it 'has no default user views' do
      expect(Stationerb.configuration.views).to be_nil
    end

    #it 'can configure a font' do
    #  Stationerb.configure do |config|
    #    config.font = "123fontABC"
    #  end
    #  expect(Stationerb.configuration.font).to eq("123fontABC")
    #end
  end

  context 'Builder' do

  end

end
