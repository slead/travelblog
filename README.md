# Travelblog

This application can act like a standard blog, with a series of posts which are shown page-by-page.

![homepage](https://i.imgur.com/xy6xKRn.jpg)

The key difference is that the application calculates the latitude/longitude of each post based on its city name, such that the posts can be explored on a map.

A full-screen map is provided, allowing the user to explore all posts via the map. A smaller mini-map is also included on each post.

![map](https://i.imgur.com/gwP7wyD.png)

The blog is optimised for easy uploading of travel photos while on the road, so each post's photos should be bundled into a new Flickr album.

When creating a new post, simply specify the blog location using the city and country name, enter the ID of the Flickr album, and the rest is handled automatically. Posts may be set as Published or Draft (in which case only the administrator can see them).

![new post](https://i.imgur.com/gxG4kdf.png)

The first photo in the Flickr album is used as the header image. To change the order of the photos, edit an existing post and drag+drop the photos in the desired order.

### To use this application

#### Admin users

I haven't bothered to create a UI interface for creating users, and in fact the Devise routes for this have been removed. So the only way to create admin users is via Rails Console:

```
user = User.create(email: 'blah@gmail.com', password: 'qwerty')
user.save!
```

An admin user may sign in using the Devise routes <app>/users/sign_in or <app>/posts/new

#### Flickr API access

This application uses the [Flickraw](https://github.com/hanklords/flickraw) gem to access Flickr, so you need to [apply for your Flickr API keys](https://www.flickr.com/services/api/misc.api_keys.html).

You then need to set these in the environment variables `FlickRaw_api_key` and `FlickRaw_shared_secret`

#### Reset database

`bin/rails db:reset; bin/rails db:migrate RAILS_ENV=development`

#### Pre-compile assets

`RAILS_ENV=production bundle exec rails assets:precompile`
