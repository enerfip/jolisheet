require "rails_helper"

RSpec.describe BaseSpreadsheet do
  class DummySpreadsheet < BaseSpreadsheet
    sheet_name "some sheet"

    column "Id", :id
    column "Other field", ->(resource) { resource.test_field }, sets: [:marketing]
    money "Amount", :amount, sets: [:accounting]
    bool "Bool field", :bool_field, sets: [:accounting, :marketing]
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

  context "specifying both `only` and `except` option" do
    subject { DummySpreadsheet.new(collection, only: ["Id"], except: ["Other field"]) }
    it "raises" do
      expect { subject }.to raise_error "You must specify only one of :only or :expect if you want to customize columns list"
    end
  end

  context "specifying `only` option" do
    subject { DummySpreadsheet.new(collection, only: ["Id", "Other field", "Unknown field"]) }
    it "renders only selected, existing columns" do
      expect(subject.header).to eq ["Id", "Other field"]
      expect(subject.data).to eq [["1", "field"], ["2", "field2"]]
    end
  end

  context "specifying `except` option" do
    subject { DummySpreadsheet.new(collection, expect: ["Id", "Other field", "Unknown field"]) }
    it "renders all columns but specified columns" do
      expect(subject.header).to eq ["Amount", "Bool field", "date"]
      expect(subject.data).to eq [[100.0, "NON", "01/12/2012"], [0.0, "OUI", "-"]]
    end
  end

  describe "#sets" do
    it { expect(DummySpreadsheet.sets).to match_array [:accounting, :marketing] }
  end

  describe "#available_columns" do
    it {
      expect(DummySpreadsheet.available_columns).to eq ["Id","Other field","Amount","Bool field","date"]
      expect(DummySpreadsheet.available_columns(:marketing)).to eq ["Other field","Bool field"]
      expect(DummySpreadsheet.available_columns(:accounting)).to eq ["Amount","Bool field"]
    }
  end

  describe "#generate_xls" do
    it "creates rows with header and body" do
      expect(subject.generate_xls).to be_kind_of String
    end
  end
end
