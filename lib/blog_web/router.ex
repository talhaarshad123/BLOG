defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BlogWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BlogWeb.Plugs.SetUser
    # plug BlogWeb.Plugs.NotLoggedIn
  end

  pipeline :auth do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BlogWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BlogWeb.Plugs.SetUser
    plug BlogWeb.Plugs.RequireAuth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth_api do
    plug BlogWeb.Plugs.AuthenticatedApi
  end

  scope "/", BlogWeb do
    pipe_through :browser
      live "/", Topic.ListAllBlogsLive
      live "/blog/:blog_id/comment", Comment.AddCommentLive
      live "/signup", User.UserRegistrationLive
      live "/login", User.UserAuthenticationLive
      get "/login/:token", ConfigUserSessionController, :login_user
      live "/my", TestLive
      live "/my/new", TestNewLive

    end

  scope "/auth", BlogWeb do
    pipe_through :auth
      live "/new", Topic.NewBlogLive
      live "/edit/:edit", Topic.EditBlogLive
      live "/delete/:blog_id", Topic.DeleteBlogLive
      live "/edit/:id/comment", Comment.EditCommentLive
      live "/delete/:id/comment", Comment.DeleteCommentLive
      live "/myposts", Topic.MyPostLive
      live "/profile", User.UserUpdateLive
      live "/delete", User.UserDeleteLive

      get "/signout", ConfigUserSessionController, :logout_user

  end

    # get "/", PageController, :home

  # Other scopes may use custom stacks.
  scope "/api", BlogWeb do
    pipe_through :api

    post "/accounts/create", UserController, :create
    post "/accounts/login", UserController, :login

    get "/blogs/:page", BlogController, :index
    get "/blog/:id", BlogController, :show
    get "/blog/:id/comments", BlogController, :blog_comments

  end

  scope "/api/:token", BlogWeb do
    pipe_through [:api, :auth_api]

    patch "/accounts/edit", UserController, :edit
    delete "/accounts/delete", UserController, :delete

    post "/blog/new", BlogController, :create
    patch "/blog/edit/:id", BlogController, :edit
    delete "/blog/delete/:id", BlogController, :delete


    post "/blog/comment/:blog_id/new", CommentController, :create
    patch "/blog/comment/:comment_id/edit", CommentController, :edit
    delete "/blog/comment/:comment_id/delete", CommentController, :delete

    post "/blog/like/:blog_id", LikeController, :like
    delete "/blog/unlike/:blog_id", LikeController, :unlike

  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:blog, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BlogWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
