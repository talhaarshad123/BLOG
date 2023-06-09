defmodule Blog.BlogTest do
  use Blog.DataCase

  describe "topics" do

    alias Blog.Model.Topic
    import Blog.BlogFixture
    import Blog.UserFixture
    alias Blog.Topics
    alias Blog.Repo

    test "create_blog/2 with valid values" do
      IO.inspect("Running test -- create_blog/2 with valid values -- ...")

      user = user_fixtures()
      valid_values = %{title: "some title!", description: "some descrip!"}

      assert {:ok, %Topic{} = blog} = Topics.create_blog(valid_values, user.id)
      assert blog.title == valid_values.title
      assert blog.description == valid_values.description
      assert blog.user_id == user.id

    end

    test "create_blog/2  with invalid values" do

      IO.inspect("Running test -- create_blog/2  with invalid values -- ...")

      user = user_fixtures()
      invalid_values = %{title: nil, description: nil}

      assert {:error, %Ecto.Changeset{}} = Topics.create_blog(invalid_values, user.id)

    end

    test "list all topics with page number" do

      IO.inspect("Running test -- list all topics with page number -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      blog = Repo.preload(blog, :likes)

      assert [blog] == Topics.all_topics(1)

    end

    test "get_blog_by_id/1 with valid topic_id return changeset" do

      IO.inspect("Running test -- get_blog_by_id/1 with valid topic_id return changeset -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)

      assert blog == Topics.get_blog_by_id(blog.id)

    end

    test "get_blog_by_id/1 with invalid topic_id returns nil" do

      IO.inspect("Running test -- get_blog_by_id/1 with invalid topic_id returns nil -- ...")

      topic_id = -1

      assert nil == Topics.get_blog_by_id(topic_id)

    end

    test "update_blog/2 with valid values returns changeset" do

      IO.inspect("Running test -- update_blog/2 with valid values returns changeset -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      valid_data = %{
        title: "some updated title",
        description: "some updated description"
      }

      assert {:ok, %Topic{} = updated_blog} = Topics.update_blog(blog, valid_data)
      assert updated_blog.title == valid_data.title
      assert updated_blog.description == valid_data.description

    end

    test "update_blog/2 with invalid values returns error" do

      IO.inspect("Running test -- update_blog/2 with invalid values returns error -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      invalid_data = %{
        title: nil,
        description: nil
      }

      assert {:error, %Ecto.Changeset{}} = Topics.update_blog(blog, invalid_data)

    end

    test "get_user_posts/2 with user_id is found returns list of blogs" do

      IO.inspect("Running test -- get_user_posts/2 with user_id is found returns list of blogs -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      blog = Repo.preload(blog, :likes)

      assert [blog] == Topics.get_user_posts(1, user.id)

    end

    test "get_user_posts/2 with user_id is not found returns empty list" do

      IO.inspect("Running test -- get_user_posts/2 with user_id is not found returns empty list -- ...")

      assert [] == Topics.get_user_posts(1, -1)

    end

    test "delete_blog/1" do

      IO.inspect("Running test -- delete_blog/1 -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      assert {:ok, %Topic{}} = Topics.delete_blog(blog.id)

      assert nil == Topics.get_blog_by_id(blog.id)

    end
  end

end
