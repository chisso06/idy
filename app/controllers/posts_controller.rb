class PostsController < ApplicationController

  before_action :login_user, only: [:new, :create, :edit, :update, :destroy, :show]
  before_action :correct_user, only: [:edit, :update, :destroy]
  before_action :get_post, only: [:edit, :update, :destroy, :show]

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user_id = @current_user.id
    if @post.save
      flash[:notice] = SUCCESSFUL_POST_MESSAGE
      redirect_to post_url(@post)
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      flash[:notice] = SAVE_MESSAGE
      redirect_to post_url(@post)
    else
      flash[:dangerous] = CANNOT_SAVE_MESSAGE
      render "edit"
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = DESTROY_POST_MESSAGE
    redirect_to posts_url
  end

  def show
    @like = Like.find_by(user_id: @current_user.id, post_id: params[:id])
    @likes = Like.where(post_id: params[:id])
    @comment = Comment.new
    @comments = Comment.where(post_id: params[:id])
  end

  def index
    @posts = Post.all
  end

  private

    def post_params
      params.require(:post).permit(:title, :content)
    end

    def login_user
      if @current_user.nil?
        flash[:dangerous] = NEED_LOGIN_MESSAGE
        redirect_to login_url
      end
    end

    def correct_user
      post = Post.find_by(id: params[:id])
      if post.user_id != @current_user.id && !@current_user.admin?
        flash[:dangerous] = NO_AUTHORITY_MESSAGE
        redirect_back(fallback_location: posts_path)
      end
    end

    def get_post
      @post = Post.find_by(id: params[:id])
      if @post.nil?
        flash[:notice] = NOT_EXIST_POST_MESSAGE
        redirect_back(fallback_location: posts_path)
      end
    end
end