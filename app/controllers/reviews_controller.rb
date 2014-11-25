class ReviewsController < ApplicationController
  before_action :require_user

  def create
    @video = Video.find(params[:video_id])
    @review = @video.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to @video
    else
      flash.now[:danger] = "xxx"
      render 'videos/show'
    end
  end

  private

    def review_params
      params.require(:review).permit(:body, :rating)
    end

end