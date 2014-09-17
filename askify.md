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
before_action :set_event, only: [:new, :create]
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

# Cleanup

At this point, we should clean up our application. We don't want people to be able to change or delete events once they are created, so we'll remove the edit, update, and destroy actions on the EventsController and disable the routes.

To remove the actions from the EventsController, you simply delete the functions. Remove the following code from `app/controllers/events_controller.rb`:
```ruby
# GET /events/1/edit
def edit
end
...
# PATCH/PUT /events/1
def update
  if @event.update(event_params)
    redirect_to @event, notice: 'Event was successfully updated.'
  else
    render :edit
  end
end
...
# DELETE /events/1
def destroy
  @event.destroy
  redirect_to events_url, notice: 'Event was successfully destroyed.'
end
```

Modify the `before_action` callback to look like this:
```ruby
before_action :set_event, only: :show
```

In `config/routes.rb`, modify your `resources :events do` line to look like this:
```ruby
resources :events, only: [:index, :show, :new, :create] do
```

Since we removed the edit / delete route, our app will no longer know about the corresponding paths, so we'll have to remove the references from our index and show pages. In `app/views/events/index.html.erb`, Delete the lines that say:
```erb
<td><%= link_to 'Edit', edit_event_path(event) %></td>
<td><%= link_to 'Destroy', event, method: :delete, data: { confirm: 'Are you sure?' } %></td>
```

In `app/views/events/show.html.erb`, delete the line that says:
```erb
<%= link_to 'Edit', edit_event_path(@event) %> |
```

We also don't want people to be able to change or delete questions, so we should remove these actions too. As before, we can simply delete the method definitions from the QuestionsController and modify the routing accordingly. We also don't have a use for the QuestionsController#index action, so we can safely delete that too.

Delete the folllowing code from `app/controllers/questions_controller.rb`:
```ruby
# GET /questions
def index
  @questions = Question.all
end
...
# GET /questions/1/edit
def edit
end
...
# PATCH/PUT /questions/1
def update
  if @question.update(question_params)
    redirect_to @event, notice: 'Question was successfully updated.'
  else
    render :edit
  end
end
...
# DELETE /questions/1
def destroy
  @question.destroy
  redirect_to @event, notice: 'Question was successfully destroyed.'
end
```

Modify the `before_action :set_question` line to look like this:
```ruby
before_action :set_question, only: :show
```

Again, modify the corresponding `config/routes.rb` line:
```ruby
resources :questions, only: [:show, :new, :create]
```

In our `app/views/questions/new.html.erb`, we have a reference to the `event_questions_path(@event)`, which no longer exists (because we deleted our QuestionsController#index path), so we'll have to change that line to:
```erb
<%= link_to 'Back', event_path(@event) %>
```

Finally, we can delete the views for all of these actions to keep the codebase simple. Delete the following files:
- `app/views/events/edit.html.erb`
- `app/views/questions/index.html.erb`
- `app/views/questions/edit.html.erb`
- `app/views/questions/show.html.erb`

Now our app's code is much cleaner, and users can't modify existing events / questions. Now, we want to make our users have to login before they ask questions or create events.

# Adding Users

Run the following commands in your terminal:
```bash
rails generate devise:install
rails generate devise User
bundle exec rake db:migrate
```

Cool. We have users now. What good is it doing? Well, not too much. We want force users to be logged in before they ask questions or create events. To do this, add the following to your `app/controllers/events_controller.rb` and `app/controllers/questions_controller.rb`:
```ruby
before_action :authenticate_user!, only: [:new, :create]
```

Now, you will be forced to sign-in / log-in before creating events or questions.

To add a sign-out link, open up `app/views/layout/application.html.erb` and add the following below the line with `<%= yield %>`:
```erb
<% if user_signed_in? %>
  <p>
    <%= link_to "Sign Out", destroy_user_session_path, method: :delete %>
  </p>
<% end %>
```
