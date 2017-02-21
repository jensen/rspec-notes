require 'rails_helper'

RSpec.feature "Visitor orders a product", type: :feature, js: true do

  before :each do
    @user = User.create!(
      name: 'First User',
      email: 'first@user.com',
      password: '123456',
      password_confirmation: '123456'
    )

    @category = Category.create! name: 'Apparel'
    @category.products.create!(
      name: 'Cool Shirt',
      description: 'A really cool shirt.',
      image: test.jpg,
      quantity: 3,
      price: 12.99
    )
  end

  def add_product_and_checkout
    first('article.product').find_link('Add').click

    visit '/cart'

    first('button.stripe-button-el').click

    within_frame 'stripe_checkout_app' do
      fill_in placeholder: 'Card number', with: '4242424242424242'
      fill_in placeholder: 'MM / YY', with: "01/#{Date.today.year + 1}"
      fill_in placeholder: 'CVC', with: '123'

      click_button 'Pay'
    end
  end

  scenario "They complete an order while logged in" do
    visit '/login'

    within 'form' do
      fill_in id: 'email', with: 'first@user.com'
      fill_in id: 'password', with: '123456'

      click_button 'Submit'
    end

    add_product_and_checkout

    expect(page).to have_content 'Thank you for your order first@user.com!'
  end

  scenario "They complete an order while not logged in" do
    visit root_path

    add_product_and_checkout

    expect(page).to have_content 'Thank you for your order!'
  end

end
