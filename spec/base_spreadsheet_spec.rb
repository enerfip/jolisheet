require "rails_helper"

RSpec.describe BaseSpreadsheet do
  class DummySpreadsheet < BaseSpreadsheet
    sheet_name "some sheet"

    column "Id", :id
    column "Other field", ->(resource) { resource.test_field }
    money "Amount", :amount
    bool "Bool field", :bool_field
    date "date", :date
  end

  let(:collection) {
    [
      double(id: 1, date: Time.zone.local(2012, 12, 1), test_field: "field", amount: 100_00, bool_field: false),
      double(id: 2, date: nil, test_field: "field2", amount: nil, bool_field: 1)
    ]
  }
  subject { DummySpreadsheet.new(collection) }

  it { expect(DummySpreadsheet.columns.size).to eq 5 }
  it "renders data" do
    expect(subject.data).to eq [["1", "field", 100.0, "NON", "01/12/2012"], ["2", "field2", 0.0, "OUI", "-"]]
  end

  it "renders header" do
    expect(subject.header).to eq ["Id", "Other field", "Amount", "Bool field", "date"]
  end

  it "knows sheet name" do
    expect(subject.sheet_name).to eq "some sheet"
  end

  describe "#generate_xls" do
    it "creates rows with header and body" do
      expect(subject.generate_xls).to be_kind_of String
    end
  end
end
