# Events

## Generate Event scaffolding

```bash
bundle exec rake db:migrate
bundle exec rake db:setup
bundle exec rails generate scaffold Event name:string
bundle exec rake db:migrate
```

Add to `config/routes.rb` (inside `Rails.application.routes.draw` do block):
```ruby
root 'events#index'
```

Refresh browser, you should see an event list. Create an event for funsies! Go back to the root page (`http://localhost:3000`) and see 
your shiny new event on the list page.

# Questions

## Generate Question scaffolding

```bash
bundle exec rails generate scaffold Question question:string event_id:integer
bundle exec rake db:migrate
```

## Making questions belong to events

Since we're being RESTful, we want the questions to belong to an event. To do this, add the following to `app/models/question.rb`:
```ruby
belongs_to :event
```
and add the following to `app/models/event.rb`:
```ruby
has_many :questions
```

When running the scaffolding command, your `config/routes.rb` file should have been automatically modified to have `resources :questions` added to it. Since the questions are going to belong to an event, we want to modify our routing to look like this instead:

```ruby
Rails.application.routes.draw do
  resources :events do
    resources :questions
  end

  root 'events#index'
end
```

Open up `app/views/questions/_form.html.erb` and modify the first line to look like this:
```erb
<%= form_for([@event, @question]) do |f| %>
```
and then delete the lines these lines:
```erb
<div class="field">
  <%= f.label :event_id %><br>
  <%= f.number_field :event_id %>
</div>
```

Then open up `app/views/questions/new.html.erb` and change the last line to look like this:
```erb
<%= link_to 'Back', event_questions_path(@event) %>
```

Now, open up `app/controllers/questions_controller.rb` and find the `new` method definition. Modify it to look like this:
```ruby
# GET /questions/new
def new
  @event = Event.find(params[:event_id])
  @question = Question.new
end
```

Then, modify the `question_params` method definition to look like this:
```ruby
# Only allow a trusted parameter "white list" through.
def question_params
  params.require(:question).permit(:question).merge(event_id: params[:event_id])
end
```

Add the following line after the existing `before_action`:
```ruby
before_action :set_event, only: [:new, :edit, :create, :update, :destroy]
```

Then add a new method definition to the private methods:
```ruby
def set_event
  @event = Event.find(params[:event_id])
end
```

Finally, modify all of the controllers calls to `redirect_to` to redirect to `@event`. You can do this by changing the first argument.

## Add link to ask new question on an event's page, and show all questions

Now, add the the following before the edit link in the `app/views/events/show.html.erb` file:
```erb
<%= link_to 'Ask New Question', new_event_question_path(@event) %> |
```

Then add the following before what you just added:
```erb
<ul>
  <% @questions.each do |question| %>
    <li>
      Question: <%= question.question %>
    </li>
  <% end %>
</ul>
```

Open up `app/controllers/events_controller.rb` and add the following to the `show` method definition.
```ruby
@questions = @event.questions
```

Now, go to your root page, create an event, and create a couple test questions for that event. They'll show up - magic!!
