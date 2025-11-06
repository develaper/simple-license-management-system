require 'rails_helper'

RSpec.describe "/products", type: :request do
  let(:valid_attributes) { { name: "Test Product", description: "Test Description" } }
  let(:invalid_attributes) { { name: "" } }
  let(:new_attributes) { { name: "Updated Product", description: "Updated Description" } }

  shared_examples "successful page load" do
    it "returns a successful response" do
      get path
      expect(response).to be_successful
    end
  end

  shared_examples "successful redirect with notice" do |action|
    it "redirects with success message" do
      expect(response).to redirect_to(redirect_path)
      follow_redirect!
      expect(flash[:notice]).to eq("Product was successfully #{action}.")
    end
  end

  shared_examples "renders unprocessable entity" do
    it "returns unprocessable entity status" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("error")
    end
  end

  describe "GET /index" do
    let(:path) { products_url }

    it_behaves_like "successful page load"

    context "with existing products" do
      let!(:product) { Product.create!(valid_attributes) }

      it "displays the product" do
        get path
        expect(response.body).to include(product.name)
      end
    end
  end

  describe "GET /show" do
    let!(:product) { Product.create!(valid_attributes) }
    let(:path) { product_url(product) }

    it_behaves_like "successful page load"

    it "displays the product details" do
      get path
      expect(response.body).to include(product.name)
      expect(response.body).to include(product.description)
    end

    context "when product does not exist" do
      it "redirects to index with alert" do
        get product_url("nonexistent")
        expect(response).to redirect_to(products_path)
        expect(flash[:alert]).to eq("Product not found.")
      end
    end
  end

  describe "GET /new" do
    let(:path) { new_product_url }
    it_behaves_like "successful page load"
  end

  describe "GET /edit" do
    let!(:product) { Product.create!(valid_attributes) }
    let(:path) { edit_product_url(product) }
    it_behaves_like "successful page load"
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:redirect_path) { product_url(Product.last) }

      it "creates a new Product" do
        expect { post products_url, params: { product: valid_attributes } }
          .to change(Product, :count).by(1)
      end

      context "after creation" do
        before do
          post products_url, params: { product: valid_attributes }
        end

        it_behaves_like "successful redirect with notice", "created"
      end
    end

    context "with invalid parameters" do
      let!(:initial_count) { Product.count }

      before do
        post products_url, params: { product: invalid_attributes }
      end

      it "does not create a new Product" do
        expect(Product.count).to eq(initial_count)
      end

      it_behaves_like "renders unprocessable entity"
    end
  end

  describe "PATCH /update" do
    let!(:product) { Product.create!(valid_attributes) }

    context "with valid parameters" do
      let(:redirect_path) { product_url(product) }

      before do
        patch product_url(product), params: { product: new_attributes }
      end

      it "updates the requested product" do
        product.reload
        expect(product.name).to eq(new_attributes[:name])
        expect(product.description).to eq(new_attributes[:description])
      end

      it_behaves_like "successful redirect with notice", "updated"
    end

    context "with invalid parameters" do
      before do
        patch product_url(product), params: { product: invalid_attributes }
      end

      it_behaves_like "renders unprocessable entity"
    end
  end

  describe "DELETE /destroy" do
    let!(:product) { Product.create!(valid_attributes) }
    let(:redirect_path) { products_url }

    it "destroys the requested product" do
      expect {
        delete product_url(product)
      }.to change(Product, :count).by(-1)
    end

    context "after deletion" do
      before do
        delete product_url(product)
      end

      it_behaves_like "successful redirect with notice", "deleted"
    end
  end
end
