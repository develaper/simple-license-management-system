# License Management System

## Description
A comprehensive License Management System that enables administrators to manage accounts, users, products, subscriptions, and licenses. This system allows administrators to assign licenses to users based on subscriptions to products, track the available and used licenses, and ensure proper validation of license assignments.


## Development Notes and Decisions
This section captures important notes and decisions made during the development of the License Management System to describe the thought process and workflow.

## Getting Started

### System Requirements

- Ruby 3.2.2
- Rails 7.1
- PostgreSQL (with UUID support)
### Setup

1. Clone the repository:
```bash
git clone git@github.com:develaper/simple-license-management-system.git
cd simple-license-management-system
```

2. Install dependencies:
```bash
bundle install
```

3. Setup database:
```bash
rails db:create
rails db:migrate
```

### Running Tests

The project uses RSpec for testing. To run the test suite:

```bash
bundle exec rspec
```

Test coverage reports are automatically generated and can be found in the `coverage` directory.

## License

This project is licensed under the MIT License.
