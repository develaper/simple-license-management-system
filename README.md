# License Management System

## Description
A comprehensive License Management System that enables administrators to manage accounts, users, products, subscriptions, and licenses. This system allows administrators to assign licenses to users based on subscriptions to products, track the available and used licenses, and ensure proper validation of license assignments.


## Development Notes and Decisions
This section captures important notes and decisions made during the development of the License Management System to describe the thought process and workflow.
The description of the task divided in User Stories fits perfectly my usual development approach, where I like to divide the work into separated and well defined PRs for each feature or entity.

 PR1. [Adding an Account](https://github.com/develaper/simple-license-management-system/pull/4):
  I will use UUID as primary keys for better data portability and to avoid sequential ID exposure.
  Implementing both model-level and database-level validations for the Account name ensures data integrity across all application layers while providing immediate user feedback and protecting against data inconsistencies.

 PR2. [Adding a Product](https://github.com/develaper/simple-license-management-system/pull/5):
  This PR introduces the Product model, allowing for the management of products within the system. Similar to the Account model, UUIDs are used as primary keys, and validations are implemented to ensure data integrity.

 PR3. [Adding a User](https://github.com/develaper/simple-license-management-system/pull/6):
  The User model is introduced in this PR, establishing a relationship with the Account model. Each user belongs to an account, and UUIDs are used for primary keys. Validations ensure that user data is accurate and complete. The specs for the validation might look a bit verbose but I rather have explicit tests for each validation case instead of using shared examples or loops, as it improves readability and makes it easier to identify specific test failures.

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
