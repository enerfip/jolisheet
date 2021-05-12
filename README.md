# Jolisheet

This is a small DSL on top of Spreadsheet gem, for easier basic spreadsheet definition

## Example


```ruby

class ProjectsSpreadsheet < Jolisheet::Base
  sheet_name "Projects"

  column "ID",                           :id
  column "Name",                         :name
  column "Owner",                        ->(r) { r.user_account.legal_name }
  money  "Goal",                         :target
  date   "Start date",                   :collect_start_date
  date   "End date",                     :collect_end_date
  money  "Amount collected",             ->(r) { r.total_subscriptions }
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
```
