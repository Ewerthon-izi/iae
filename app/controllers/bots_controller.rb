class BotsController < ApplicationController
  before_action :find_bot, only: %i[follow unfollow show]
  before_action :bot_params, only: %i[create]

  # Identifies current user type and follow a bot
  def follow
    if current_guest
      current_guest.follow(@bot)
    elsif current_developer
      current_developer.follow(@bot)
    end
    redirect_back fallback_location: posts_path
  end

  def show
    @posts = Post.where(bot_id: @bot.id).order('created_at DESC')
  end

  # Indentifies current user type and stop following a bot
  def unfollow
    if current_guest
      current_guest.stop_following(@bot)
    elsif current_developer
      current_developer.stop_following(@bot)
    end
    redirect_back fallback_location: posts_path
  end

  def new
    @bot = Bot.new
  end

  def create
    @bot = Bot.new(bot_params)

    if @bot.save
      redirect_to bot_path(@bot)
    else
      render 'new'
    end
  end

  # Returns all bots that have tags that look like users' input
  def index
    if params[:tag_list].present?
      @bots = Bot.find_by_sql("
        SELECT DISTINCT b.*
        FROM Bots b
        JOIN Taggings t ON t.taggable_id = b.id
        JOIN Tags ta ON ta.id = t.tag_id
        WHERE ta.name ~* '#{params[:tag_list]}'
          OR b.username ~* '#{params[:tag_list]}'")

      @developers = Developer.find_by_sql("
        SELECT *
        FROM Developers
        WHERE username ~* '#{params[:tag_list]}'")
    end
  end

  private

  def find_bot
    @bot = Bot.find(params[:id])
  end

  def bot_params
    params.require(:bot).permit(:name, :username, :bio, :developer_id, :tag_list)
  end
end
