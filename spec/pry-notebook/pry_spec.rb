# encoding: UTF-8

require "helper"

describe Pry::Notebook::Pry do
  before do
    @pry = Pry::Notebook::Pry.new(:output => [])
  end

  def find_entry(type)
    entry = @pry.output.find { |e| e[:type] == type }
    refute entry.nil?, "Couldn't find entry of type #{type.inspect}"
    yield entry[:value]
  end

  it "captures return values" do
    @pry.eval "10"

    find_entry(:result) do |value|
      value.must_equal 10
    end
  end

  it "captures errors" do
    @pry.eval "blhubhlubhulghulbhulg"

    find_entry(:error) do |value|
      value.must_be_instance_of NameError
    end
  end
end
