defmodule Blog.CommentTest do
  use Blog.DataCase

  describe "comments" do
    import Blog.CommentFixture
    import Blog.UserFixture
    import Blog.BlogFixture
    alias Blog.Comments

    test "list of comments by blog" do

      IO.inspect("Running test -- list of comments by blog -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      _comment = comment_fixture(blog, user.id)

      %Blog.Model.Topic{comments: comment} = Repo.preload(blog, comments: [:user])
      assert %Blog.Model.Topic{comments: comments} = Comments.get_comments_by_blog(blog.id)
      assert comment == comments

    end

    test "insert_comment/3 with valid comment_content returns Comment changeset" do

      IO.inspect("Running test -- insert comment with valid comment_content -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      valid_data = %{content: "some comment content"}

      assert {:ok, %Blog.Model.Comment{} = comment} = Comments.insert_comment(blog, valid_data, user.id)
      assert comment.content == valid_data.content

    end

    test "insert_comment/3 with invalid comment_content returns error changeset" do

      IO.inspect("Running test -- insert comment with invalid comment_content -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      invalid_data = %{content: nil}

      assert {:error, %Ecto.Changeset{}} = Comments.insert_comment(blog, invalid_data, user.id)

    end

    test "get_comment_by_id/1 with valid comment id returns comment changeset" do

      IO.inspect("Running test -- get_comment_by_id/1 with valid comment id -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      comment = comment_fixture(blog, user.id)

      assert comment == Comments.get_comment_by_id(comment.id)

    end

    test "get_comment_by_id/1 with invalid comment id return nil" do

      IO.inspect("Running test -- get_comment_by_id/1 with invalid comment id -- ...")

      assert nil == Comments.get_comment_by_id(-1)

    end

    test "update_comment/2 with valid comment_content returns comment changeset" do

      IO.inspect("Running test -- update_comment/2 with valid comment_content -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      comment = comment_fixture(blog, user.id)
      valid_data = %{content: "some updated comment content"}

      assert {:ok, %Blog.Model.Comment{} = updated_comment} = Comments.update_comment(comment, valid_data)
      assert updated_comment.content == valid_data.content

    end

    test "update_comment/2 with invalid comment_content returns error changeset" do

      IO.inspect("Running test -- update_comment/2 with invalid comment_content -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      comment = comment_fixture(blog, user.id)
      invalid_data = %{content: nil}

      assert {:error, %Ecto.Changeset{}} = Comments.update_comment(comment, invalid_data)

    end

    test "get_comment_user/1 with valid comment returns preload user of given comment" do

      IO.inspect("Running test -- get_comment_user/1 with valid comment -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      comment = comment_fixture(blog, user.id)
      %Blog.Model.Comment{user: current_user} = Repo.preload(comment, :user)

      assert %Blog.Model.Comment{user: comment_owner} = Comments.get_comment_user(comment)
      assert current_user == comment_owner
    end

    test "get_comment_user/1 with invalid comment returns nil" do

      IO.inspect("Running test -- get_comment_user/1 with invalid comment -- ...")

      assert nil == Comments.get_comment_user(nil)

    end

    test "delete_comment/1 return comment changeset after delete" do

      IO.inspect("Running test -- delete_comment/1 -- ...")

      user = user_fixtures()
      blog = blog_fixture(user)
      comment = comment_fixture(blog, user.id)

      assert {:ok, %Blog.Model.Comment{}} = Comments.delete_comment(comment)
      assert nil == Comments.get_comment_by_id(comment.id)

    end

  end
end
