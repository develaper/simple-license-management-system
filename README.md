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
  In this PR, the UsersController is nested under Accounts (Accounts::UsersController) to reflect the domain structure — users exist within the scope of their account, not globally. This approach enforces data isolation, prevents cross-account access, and simplifies controller logic by automatically scoping queries to the current account. It also aligns with the intended UX, where managing users is a contextual action performed within the account’s workspace.
 PR4. [Adding a Subscription](https://github.com/develaper/simple-license-management-system/pull/7):
  This PR introduces the Subscription model, enabling accounts to subscribe to specific products with a defined number of licenses and validity period. Subscriptions are created within the account scope, reflecting the domain hierarchy and maintaining data isolation and clarity in the user flow.
 PR5. [Adding License Assignments](https://github.com/develaper/simple-license-management-system/pull/8):
  This PR introduces the ability to assign and unassign product licenses to users within an account. Since the specification doesn’t define a direct relationship between Subscription and LicenseAssignment, I added helper methods in Subscription to compute assigned and available licenses — though in a real-world scenario I’d prefer defining an explicit association between them.
  I placed the license assignments view inside the account’s show page to keep all related resources consistently grouped under Account.
  I briefly considered adding an active flag to license assignments, but decided against it. Without historical tracking, the existence of a record already represents an active assignment, so an extra flag felt redundant.
  I split the logic into separate services for assigning and unassigning licenses to keep responsibilities clean and avoid conditionals. I also introduced ObjectQueries to encapsulate query logic, and extracted shared examples and contexts to keep the specs lean and expressive.

## Technical Debt and Doubts

### License Assignment Update Validation
The `LicenseAssignment` model includes a uniqueness validation that prevents duplicate assignments for the same user and product. This validation could prevent updates to existing records, the addition of `where.not(id: id) if persisted?` to the validation query would prevent it.

**Current Decision**: I've chosen not to implement this change because:
1. The current business logic doesn't include any update operations for license assignments
2. Assignments are only created or deleted, never modified
3. The current validation accurately reflects our business rule: one license per user per product, no exceptions

**Future Considerations**:
- If updates become necessary, I would need to:
  - Define what "updating" a license assignment means in our domain
  - Add relevant attributes that could be modified
  - Adjust the validation accordingly with `where.not(id: id) if persisted?`
  - Add appropriate update actions to the controller

This decision aligns with YAGNI principles while keeping our code base focused on current requirements.


### Subscription and LicenseAssignment Relationship
The current implementation calculates assigned and available licenses through methods in the Subscription model, causing N+1 query problems and violating Single Responsibility Principle. A more optimal approach would be:

1. **Direct Association**: Establish a formal relationship between Subscription and LicenseAssignment through the product_id
2. **Counter Cache**: Implement a counter_cache to track assigned licenses efficiently
3. **Service Object**: Move calculation logic to a dedicated service (e.g., `LicenseAvailabilityService`)
4. **Denormalization**: Add assigned_licenses column to Subscription for fast querying

These changes would improve performance, maintain better separation of concerns, and make the codebase more maintainable. The current implementation was chosen to meet immediate requirements, but a production system would benefit from these optimizations.


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
