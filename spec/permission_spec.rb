require 'spec_helper'

describe AccessGranted::Permission do
  subject { AccessGranted::Permission }

  describe "#matches_conditions?" do
    it "matches when no conditions given" do
      perm = subject.new(true, :read, String)
      expect(perm.matches_conditions?(String)).to eq(true)
    end

    it "matches proc conditions" do
      sub = double("Element", published?: true)
      perm = subject.new(true, :read, sub.class, nil, {}, proc {|el| el.published? })
      expect(perm.matches_conditions?(sub)).to eq(true)
    end

    it "does not match proc conditions when given a class instead of an instance" do
      sub = double("Element", published?: true)
      perm = subject.new(true, :read, sub.class, nil, {}, proc {|el| el.published? })
      expect(perm.matches_conditions?(sub.class)).to eq(true)
    end
  end

  describe "#matches_hash_conditions?" do
    it "matches condition hash is empty" do
      perm = subject.new(true, :read, String)
      expect(perm.matches_hash_conditions?(String)).to eq(true)
    end

    it "matches when conditions given" do
      sub = double("Element", published: true)
      perm = subject.new(true, :read, sub, nil, { published: true })
      expect(perm.matches_hash_conditions?(sub)).to eq(true)
    end

    it "does not match if one of the conditions mismatches" do
      sub = double("Element", published: true, readable: false)
      perm = subject.new(true, :read, sub, nil, { published: true, readable: true })
      expect(perm.matches_hash_conditions?(sub)).to eq(false)
    end
  end

  describe "#matches_action?" do
    it "matches if actions are identical" do
      perm = subject.new(true, :read, String)
      expect(perm.matches_action?(:read)).to_not be_nil
    end
  end

  describe "#matches_subject?" do
    it "matches if subjects are identical" do
      perm = subject.new(true, :read, String)
      expect(perm.matches_subject? String).to eq(true)
    end

    it "matches if class is equal to subject" do
      perm = subject.new(true, :read, String)
      expect(perm.matches_subject? "test").to eq(true)
    end

    it "matches if superclass is equal to subject" do
      perm = subject.new(true, :read, Object)
      expect(perm.matches_subject? "test").to eq(true)
    end

    it "matches if any ancestor is equal to subject" do
      perm = subject.new(true, :read, BasicObject)
      expect(perm.matches_subject? "test").to eq(true)
    end

    it "does not match if any descendant is equal to subject" do
      perm = subject.new(true, :read, String)
      expect(perm.matches_subject? Object.new).to eq(false)
    end
  end
end
