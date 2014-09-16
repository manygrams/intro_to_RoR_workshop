# Events

```
bundle exec rake db:migrate
bundle exec rake db:setup
rails generate scaffold Event name:string
bundle exec rake db:migrate
```

Add to `config/routes.rb` (inside `Rails.application.routes.draw` do block):
```
root 'events#index'
```

Refresh browser, you should see an event list. Create an event for funsies! Go back to the root page (`http://localhost:3000`) and see 
your shiny new event on the list page.
