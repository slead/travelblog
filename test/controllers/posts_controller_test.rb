require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    puts "\nTesting: Loading the posts index page"
    get posts_url
    assert_response :success, "Failed to load index page"
    assert_select 'h1', "Steve and Glo's travel blog", "Blog title not found"
  end

  test "should get index with pagination" do
    puts "\nTesting: Checking pagination on index page"
    get posts_url
    assert_response :success, "Failed to load index page"
    assert_select '.pagination', true, "Pagination controls not found"
  end

  test "should get index with header image" do
    puts "\nTesting: Verifying header image on index page"
    get posts_url
    assert_response :success, "Failed to load index page"
    assert_select '.masthead', true, "Header image container not found"
  end

  test "should get show" do
    puts "\nTesting: Loading individual post page"
    get post_url(@post)
    assert_response :success, "Failed to load post page"
    assert_select 'h1', @post.title, "Post title not found"
  end

  test "should get show with photos" do
    puts "\nTesting: Checking photo gallery on post page"
    get post_url(@post)
    assert_response :success, "Failed to load post page"
    assert_select '.lightboxpics', true, "Photo gallery container not found"
  end

  test "should get show with map" do
    puts "\nTesting: Verifying map on post page"
    get post_url(@post)
    assert_response :success, "Failed to load post page"
    assert_select '#map', true, "Map container not found"
  end

  test "should get new" do
    puts "\nTesting: Loading new post form"
    get new_post_url
    assert_response :success, "Failed to load new post form"
    assert_select 'form', true, "Post form not found"
  end

  test "should create post" do
    puts "\nTesting: Creating a new post"
    assert_difference('Post.count', 1, "Post count did not increase") do
      post posts_url, params: { 
        post: { 
          title: 'New Test Post',
          content: 'Test content',
          status: 'draft',
          placename: 'London, UK'
        } 
      }
    end

    assert_redirected_to post_url(Post.last), "Failed to redirect to new post"
  end

  test "should create post with flickr album" do
    puts "\nTesting: Creating post with Flickr album"
    assert_difference('Post.count', 1, "Post count did not increase") do
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

    assert_redirected_to post_url(Post.last), "Failed to redirect to new post"
    assert Post.last.photos.any?, "No photos were attached to the post"
  end

  test "should get edit" do
    puts "\nTesting: Loading edit post form"
    get edit_post_url(@post)
    assert_response :success, "Failed to load edit form"
    assert_select 'form', true, "Edit form not found"
  end

  test "should update post" do
    puts "\nTesting: Updating an existing post"
    patch post_url(@post), params: { 
      post: { 
        title: 'Updated Title',
        content: 'Updated content',
        status: 'published'
      } 
    }
    @post.reload
    assert_redirected_to post_url(@post.friendly_id), "Failed to redirect to updated post"
    assert_equal 'Updated Title', @post.title, "Post title was not updated"
  end

  test "should destroy post" do
    puts "\nTesting: Deleting a post"
    assert_difference('Post.count', -1, "Post count did not decrease") do
      delete post_url(@post)
    end

    assert_redirected_to posts_url, "Failed to redirect to posts index"
  end

  test "should handle non-existent post" do
    puts "\nTesting: Handling non-existent post"
    get post_url(id: 'non-existent')
    assert_redirected_to posts_url, "Failed to redirect to posts index"
    assert_equal 'Sorry, that post does not exist', flash[:notice], "Flash message not set"
  end

  test "should get index as json" do
    puts "\nTesting: Loading posts index as JSON"
    get posts_url(format: :json)
    assert_response :success, "Failed to load JSON index"
    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array), "Response is not an array"
    assert json_response.first.key?('id'), "Missing id in JSON response"
    assert json_response.first.key?('title'), "Missing title in JSON response"
    assert json_response.first.key?('photos'), "Missing photos in JSON response"
  end

  test "should get show as json" do
    puts "\nTesting: Loading post as JSON"
    get post_url(@post, format: :json)
    assert_response :success, "Failed to load JSON post"
    json_response = JSON.parse(response.body)
    assert json_response.key?('id'), "Missing id in JSON response"
    assert json_response.key?('title'), "Missing title in JSON response"
    assert json_response.key?('photos'), "Missing photos in JSON response"
  end
end
