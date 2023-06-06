defmodule Blog.LikeTest do
  use Blog.DataCase

  describe "Likes" do
    import Blog.LikeFixture
    import Blog.UserFixture
    import Blog.BlogFixture
    alias Blog.Likes

    test "insert_like/2" do

      IO.inspect("Running test -- insert_like/2 -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)

      assert {:ok, %Blog.Model.Like{}=inserted_like} = Likes.insert_like(blog.id, user.id)
      assert blog.id == inserted_like.topic_id
      assert user.id == inserted_like.user_id

    end

    test "get_like_by_blog_user/2 with valid user and blog return like changeset" do

      IO.inspect("Running test -- get_like_by_blog_user/2 with valid user and blog -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      _like = like_fixture(blog.id, user.id)

      assert %Blog.Model.Like{} = Likes.get_like_by_blog_user(blog.id, user.id)

    end

    test "get_like_by_blog_user/2 with invalid user and blog return nil" do

      IO.inspect("Running test -- get_like_by_blog_user/2 with invalid user and blog -- ...")

      assert nil == Likes.get_like_by_blog_user(-1, -1)

    end

    test "delete_like/1 return like changeset" do

      IO.inspect("Running test -- delete_like/1 -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      like = like_fixture(blog.id, user.id)

      assert {:ok, %Blog.Model.Like{}} = Likes.delete_like(like)
      assert nil == Repo.get(Blog.Model.Like, like.id)

    end
  end

end
