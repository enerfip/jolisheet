module Jolisheet
  class Base
    attr_reader :collection, :chosen_columns

    def self.sheet_name(sh_name = nil)
      return @sheet_name if sh_name.nil?
      @sheet_name = sh_name
    end

    def self.available_columns
      columns.map { |col| col[:label] }
    end

    def self.columns
      @columns ||= []
    end

    def self.column(label, definition, formatter = nil)
      if definition.kind_of?(Symbol)
        local_definition = ->(resource, _sheet) { resource.public_send(definition) }
      else
        local_definition = definition
      end
      self.columns << { label: label, definition: local_definition, formatter: formatter || :bypass }
    end

    def self.date(label, definition)
      column(label, definition, :date)
    end

    def self.money(label, definition)
      column(label, definition, :money)
    end

    def self.bool(label, definition)
      column(label, definition, :bool)
    end

    def initialize(collection, only: nil, except: nil)
      if [only, except].reject(&:nil?).size > 1
        raise "You must specify only one of :only or :expect if you want to customize columns list"
      end

      @chosen_columns = self.class.available_columns & only if only.present?
      @chosen_columns = self.class.available_columns - except if except.present?

      @collection = collection
    end

    def sheet_name
      self.class.sheet_name
    end

    def generate_xls
      create_body

      data_to_send = StringIO.new
      book.write data_to_send
      data_to_send.string
    end

    def create_body
      sheet.row(0).concat header
      data.each.with_index do |item, id|
        sheet.row(id+1).concat item
      end
    end

    def data
      collection.to_a.map(&method(:row))
    end

    def header
      chosen_columns
    end

    def row(resource)
      definitions.map { |definition|
        if definition[:definition].arity == 2
          __send__("format_#{definition[:formatter]}", definition[:definition].call(resource, self))
        else
          __send__("format_#{definition[:formatter]}", definition[:definition].call(resource))
        end
      }
    end

    private

    def format_bypass(value)
      value.to_s
    end

    def format_money(value)
      value.to_f / 100
    end

    def format_date(value)
      if value.respond_to? :strftime
        value.strftime("%d/%m/%Y")
      else
        "-"
      end
    end

    def format_bool(value)
      if [1, "1", true].include? value
        "OUI"
      else
        "NON"
      end
    end

    def sheet
      @sheet ||= book.create_worksheet name: sheet_name
    end

    def book
      @book ||= Spreadsheet::Workbook.new
    end

    def definitions
      self.class.columns.select { |col| chosen_columns.include? col[:label] }
    end
  end
end
