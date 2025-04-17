require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get posts_url
    assert_response :success
    assert_select 'h1', 'Posts'
  end

  test "should get index with pagination" do
    get posts_url
    assert_response :success
    assert_select '.pagination'
  end

  test "should get index with header image" do
    get posts_url
    assert_response :success
    assert_select '.header-image'
  end

  test "should get show" do
    get post_url(@post)
    assert_response :success
    assert_select 'h1', @post.title
  end

  test "should get show with photos" do
    get post_url(@post)
    assert_response :success
    assert_select '.pswp-gallery'
  end

  test "should get show with map" do
    get post_url(@post)
    assert_response :success
    assert_select '#map'
  end

  test "should get new" do
    get new_post_url
    assert_response :success
    assert_select 'form'
  end

  test "should create post" do
    assert_difference('Post.count') do
      post posts_url, params: { 
        post: { 
          title: 'New Test Post',
          content: 'Test content',
          status: 'draft',
          placename: 'London, UK'
        } 
      }
    end

    assert_redirected_to post_url(Post.last)
  end

  test "should create post with flickr album" do
    assert_difference('Post.count') do
      post posts_url, params: { 
        post: { 
          title: 'New Test Post with Photos',
          content: 'Test content',
          status: 'draft',
          placename: 'London, UK',
          flickr_album: '72177720324909924'
        } 
      }
    end

    assert_redirected_to post_url(Post.last)
    assert Post.last.photos.any?
  end

  test "should get edit" do
    get edit_post_url(@post)
    assert_response :success
    assert_select 'form'
  end

  test "should update post" do
    patch post_url(@post), params: { 
      post: { 
        title: 'Updated Title',
        content: 'Updated content',
        status: 'published'
      } 
    }
    assert_redirected_to post_url(@post)
    @post.reload
    assert_equal 'Updated Title', @post.title
  end

  test "should destroy post" do
    assert_difference('Post.count', -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
  end

  test "should handle non-existent post" do
    get post_url(id: 'non-existent')
    assert_redirected_to posts_url
    assert_equal 'Sorry, that post does not exist', flash[:notice]
  end

  test "should get index as json" do
    get posts_url(format: :json)
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
    assert json_response.first.key?('id')
    assert json_response.first.key?('title')
    assert json_response.first.key?('photos')
  end

  test "should get show as json" do
    get post_url(@post, format: :json)
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.key?('id')
    assert json_response.key?('title')
    assert json_response.key?('photos')
  end
end
