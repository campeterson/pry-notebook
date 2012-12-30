# encoding: UTF-8

require "helper"

describe Pry::Notebook::Pry do
  before do
    @pry = Pry::Notebook::Pry.new
    @out = []
    @pry.subscribe('test', @out)
  end

  def find_entry(type)
    entry = @out.find { |e| e[:type] == type }

    refute entry.nil?,
      "Couldn't find entry of type #{type.inspect} in #{@pry.output.inspect}"

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

    find_entry(:output) do |value|
      value.must_match /_in_/
    end
  end

  it "captures continued expressions" do
    @pry.eval "def x"

    find_entry(:continuation) do |value|
      value.must_equal "def x\n"
    end

    @pry.eval "!"
  end

  it "doesn't use color" do
    @pry.eval "ls"

    find_entry(:output) do |value|
      value.wont_match /^\e\[/
    end
  end

  it "captures arbitrary output to $stdout" do
    @pry.eval "puts 'hey'"

    find_entry(:output) do |value|
      value.must_equal "hey\n"
    end
  end
end
