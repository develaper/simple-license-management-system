# frozen_string_literal: true

RSpec.shared_context "with license assignment setup" do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:product) { create(:product) }
end

RSpec.shared_examples "a license service result" do |success: true, count: 1|
  it "returns expected result attributes" do
    result = subject.call

    expect(result).to have_attributes(
      success?: success,
      assignments_count: count,
      error_messages: success ? be_empty : be_present
    )
  end
end

RSpec.shared_examples "a transaction rollback" do
  it "rolls back the transaction" do
    expect { subject.call }.not_to change(::LicenseAssignment, :count)
  end
end
