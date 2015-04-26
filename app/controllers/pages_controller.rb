class PagesController < ApplicationController
  skip_filter :authenticate_user!

  layout 'front'

  def welcome
  end
end
