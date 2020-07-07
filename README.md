An example of restoring pagination results and scroll position with Rails's default Turbolinks and HTML everything approach, which I wrote more about here: _[Pagination and Scroll Restoration with Turbolinks](http://blog.graykemmey.com/2020/07/07/pagination-and-scroll-restoration-with-turbolinks/)_.

![GIF of running app](./example.gif)

### Setup

1. `$ bundle exec install`
2. `$ yarn install`
3. `$ bundle exec rails db:setup`
4. `$ RAILS_ENV=development bundle exec rails db:fixtures:load`
5. `$ bundle exec rails server`
