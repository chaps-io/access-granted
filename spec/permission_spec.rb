require 'spec_helper'

describe AccessGranted::Permission do
  subject { AccessGranted::Permission }

  describe "#matches_conditions?" do
    it "matches when no conditions given" do
      perm = subject.new(true, :read, String)
      perm.matches_conditions?(String).should be_true
    end

    it "matches proc conditions" do
      sub = double("Element", published?: true)
      perm = subject.new(true, :read, sub.class, {}, proc {|el| el.published? })
      perm.matches_conditions?(sub).should be_true
    end
  end

  describe "#matches_hash_conditions?" do
    it "matches condition hash is empty" do
      perm = subject.new(true, :read, String)
      perm.matches_hash_conditions?(String).should be_true
    end

    it "matches when conditions given" do
      sub = double("Element", published: true)
      perm = subject.new(true, :read, sub, { published: true })
      perm.matches_hash_conditions?(sub).should be_true
    end

    it "does not match if one of the conditions mismatches" do
      sub = double("Element", published: true, readable: false)
      perm = subject.new(true, :read, sub, { published: true, readable: true })
      perm.matches_hash_conditions?(sub).should be_false
    end
  end

  describe "#matches_action?" do
    it "matches if actions are identical" do
      perm = subject.new(true, :read, String)
      perm.matches_action?(:read).should be_true
    end
  end

  describe "#matches_subject?" do
    it "matches if subjects are identical" do
      perm = subject.new(true, :read, String)
      expect(perm.matches_subject? String).to be_true
    end

    it "matches if class is equal to subject" do
      perm = subject.new(true, :read, String)
      expect(perm.matches_subject? "test").to be_true
    end
  end

  describe "#relevant?" do
    it "matches subject by class" do
      perm = subject.new(true, :read, String)
      perm.relevant?(:read, String).should be_true
    end

    it "matches subject by instance" do
      perm = subject.new(true, :read, String)
      perm.relevant?(:read, "text").should be_true
    end
  end
end
