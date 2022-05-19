class PostsController < ApplicationController

  before_action :login_user
  before_action :correct_user, only: [:edit, :update, :destroy]

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user_id = session[:user_id]
    if @post.save
      flash[:notice] = "アイデアを投稿しました！"
      redirect_to post_url(@post)
    else
      render "new"
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      flash[:notice] = "変更を保存しました"
      redirect_to post_url(@post)
    else
      flash[:dangerous] = "保存に失敗しました"
      render "edit"
    end
  end

  def destroy
    Post.find_by(params[:id]).destroy
    session[:post_id] = nil
    flash[:notice] = "投稿を削除しました"
    redirect_to posts_url
  end

  def show
    session[:post_id] = params[:id]
    @post = Post.find_by(id: params[:id])
    @like = Like.find_by(user_id: session[:user_id], post_id: session[:post_id])
    @likes = Like.where(post_id: session[:post_id])
    @comment = Comment.new
    @comments = Comment.where(post_id: session[:post_id])
  end

  def index
    @posts = Post.all
  end

  private

    def post_params
      params.require(:post).permit(:title, :category, :content)
    end

    def login_user
      if session[:user_id].nil?
        flash[:dangerous] = "ログインしてください"
        redirect_to login_url
      end
    end

    def correct_user
      post = Post.find(params[:id])
      if post.user_id != session[:user_id]
        flash[:dangerous] = "権限がありません"
        redirect_to posts_url
      end
    end
end