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

  it "captures and inspects return values" do
    @pry.eval "'10'"

    find_entry(:result) do |value|
      value.must_equal "\"10\""
    end
  end

  it "captures errors" do
    @pry.eval "blhubhlubhulghulbhulg"

    find_entry(:error) do |value|
      assert_match /^NameError/, value
      assert_match /`blhubhlubhulghulbhulg'/, value
    end
  end

  it "captures command output" do
    @pry.eval "ls"

    find_entry(:pry_output) do |value|
      assert_match /_in_/, value
    end
  end
end
