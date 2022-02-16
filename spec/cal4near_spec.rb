# frozen_string_literal: true

RSpec.describe Cal4near do
  it "has a version number" do
    expect(Cal4near::VERSION).not_to be nil
  end

  context "list" do
    it "list" do
      expect(Cal4near.list.class).to eq Hash
    end
  end
end
