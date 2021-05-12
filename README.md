# Jolisheet

This is a small DSL on top of Spreadsheet gem, for easier basic spreadsheet definition

## Example


```ruby

class ProjectsSpreadsheet < Jolisheet::Base
  sheet_name "Projects"

  column "ID",                           :id
  column "Name",                         :name, sets: [:marketing, :accounting]
  column "Owner",                        ->(r) { r.user_account.legal_name }
  money  "Goal",                         :target, sets: [:marketing]
  date   "Start date",                   :collect_start_date, sets: [:marketing]
  date   "End date",                     :collect_end_date, sets: [:marketing]
  money  "Amount collected",             ->(r) { r.total_subscriptions }, sets: [:accounting]
end
```

### Usage

```ruby

  spreadsheet = ProjectsSpreadsheet.new Project.all
  send_data spreadsheet.generate_xls, filename: "projects.xls"
```

#### Selecting or excluding columns

```ruby

  spreadsheet = ProjectsSpreadsheet.new Project.all, only: ["ID", "Owner"]
  send_data spreadsheet.generate_xls, filename: "projects.xls"

  spreadsheet = ProjectsSpreadsheet.new Project.all, except: ["ID", "Owner"]
  send_data spreadsheet.generate_xls, filename: "projects.xls"

  spreadsheet = ProjectsSpreadsheet.new Project.all, only: ProjectsSpreadsheet.available_columns(:marketing) # Will export only fields that are included in the `:marketing` set
  send_data spreadsheet.generate_xls, filename: "projects.xls"

```

#### Listing available_columns and sets

```ruby
  ProjectsSpreadsheet.available_columns
  # => ["ID","Name","Owner","Goal","Start date","End date","Amount collected"]
  ProjectsSpreadsheet.available_columns(:marketing)
  # => ["Goal","Start date","End date"]
  ProjectsSpreadsheet.sets
  # => [:marketing, :accounting]
```
