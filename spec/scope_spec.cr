require "./spec_helper"

describe Scope do
  describe "#assign" do
    it "should throw when variable identifiers are invalid" do
      scope = Scope.new
      expect_raises(Exception) { scope.assign("saf123?", "hello") } #because it's not a method it wont take ? at the end
      expect_raises(Exception) { scope.assign("123saf", "hello") }
    end

    it "should store local variables" do
      scope = Scope.new
      scope.assign("a", 1)
      scope.assign("b", ["hello", 123] of BaseValidType)
      scope.assign("c", "hello world")
      scope.lookup("a").should eq(1)
      scope.lookup("b").should eq(["hello", 123])
      scope.lookup("c").should eq("hello world")
    end
  end


  describe "#lookup" do
    it "should throw when loading an undefined variable" do
      scope = Scope.new
      expect_raises(Exception) { scope.lookup("bababooey") }
    end
  end
end
