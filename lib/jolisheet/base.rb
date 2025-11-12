module Jolisheet
  class Base
    attr_reader :collection, :chosen_columns
    attr_accessor :debug

    def self.sheet_name(sh_name = nil)
      return @sheet_name if sh_name.nil?

      @sheet_name = sh_name
    end

    def self.available_columns(set = nil)
      columns.select { |col| set.blank? || col[:sets].include?(set) }.map { |col| col[:label] }
    end

    def self.sets
      columns.flat_map { |col| col[:sets] }.uniq
    end

    def self.columns
      @columns ||= []
    end

    def self.column(label, definition, formatter = nil, sets: [])
      local_definition = if definition.is_a?(Symbol)
                           ->(resource, _sheet) { resource.public_send(definition) }
                         else
                           definition
                         end
      columns << { label: label, definition: local_definition, formatter: formatter || :bypass, sets: sets }
    end

    def self.date(label, definition, sets: [])
      column(label, definition, :date, sets: sets)
    end

    def self.money(label, definition, sets: [])
      column(label, definition, :money, sets: sets)
    end

    def self.bool(label, definition, sets: [])
      column(label, definition, :bool, sets: sets)
    end

    def initialize(collection, only: nil, except: nil)
      if [only, except].reject(&:nil?).size > 1
        raise 'You must specify only one of :only or :expect if you want to customize columns list'
      end

      @chosen_columns = self.class.available_columns & only if only.present?
      @chosen_columns = self.class.available_columns - except if except.present?
      @chosen_columns ||= self.class.available_columns
      @debug = false

      @collection = collection
    end

    def sheet_name
      self.class.sheet_name
    end

    def generate_xls
      create_body

      package.to_stream.read
    end

    def create_body
      add_worksheet do |sheet|
        sheet.add_row header
        collection.each_slice(500).with_index do |rows, index|
          puts "Processing rows #{rows.size * index} to #{rows.size * (index + 1)}" if debug
          rows.each do |resource|
            sheet.add_row row(resource)
          end
        end
      end
    end

    def data
      collection.to_a.map(&method(:row))
    end

    def header
      chosen_columns
    end

    def row(resource)
      definitions.map do |definition|
        if definition[:definition].arity == 2
          __send__("format_#{definition[:formatter]}", definition[:definition].call(resource, self))
        else
          __send__("format_#{definition[:formatter]}", definition[:definition].call(resource))
        end
      end
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
        value.strftime('%d/%m/%Y')
      else
        '-'
      end
    end

    def format_bool(value)
      if [1, '1', true].include? value
        'OUI'
      else
        'NON'
      end
    end

    def add_worksheet(&block)
      book.add_worksheet name: sheet_name do |sheet|
        block.call(sheet)
      end
    end

    def book
      @book ||= package.workbook
    end

    def package
      @package ||= Axlsx::Package.new
    end

    def definitions
      self.class.columns.select { |col| chosen_columns.include? col[:label] }
    end
  end
end
