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

## Basic Setup

Run the following commands in your terminal:
```bash
bundle exec rails generate devise:install
bundle exec rails generate devise User
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

## Making Events / Questions belong to Users

Now that we require users to sign-in before asking questions or creating events, we should associate the users with their questions and events. We associated questions with events before, so you already have a bit of experience with this.

Add the following to `app/models/event.rb` and `app/models/question.rb`:
```ruby
belongs_to :user
```

Now, add the following to `app/models/user.rb`:
```ruby
has_many :questions
has_many :events
```

We'll need to add the `user_id` column to events and to questions, so that this association can be persisted in the database. Run the following commands in your terminal:
```bash
bundle exec rails g migration AddUserIDToQuestions user_id:integer
bundle exec rails g migration AddUserIDToEvents user_id:integer
bundle exec rake db:migrate
```

Now, we need to make sure new events / questions belong to the user that created them. To do this, we modify the event_params private method in `app/controllers/events_controller.rb` to look like this:
```ruby
# Only allow a trusted parameter "white list" through.
def event_params
  params.require(:event).permit(:name).merge(user_id: current_user.id)
end
```

We'll do the same to the `question_params` method in `app/controllers/questions_controller.rb`:
```ruby
# Only allow a trusted parameter "white list" through.
def question_params
  params.require(:question).permit(:question).merge(event_id: params[:event_id], user_id: current_user.id)
end
```

We want to ensure that questions are signed by the user that creates them. ActiveRecord associations makes this very easy. Open up `app/views/events/show.html.erb` and modify the loop that prints out questions to look like this:
```ruby
<% @questions.each do |question| %>
  <li>
    <p>
      Question: "<%= question.question %>"
    </p>
    Asked by: <%= question.user.email %>
  </li>
<% end %>
```

# Adding Voting

To keep it simple, we'll only allow users to create votes on questions. We won't build the functionality to allow users to change or delete votes.

Run the following in your terminal:
```bash
bundle exec rails generate model Vote user_id:integer question_id:integer score:string
bundle exec rails generate controller Votes upvote downvote
bundle exec rake db:migrate
```

We want to tell ActiveRecord about the association between our Vote, User, and Question model, so we open up `app/models/vote.rb` and add:
```ruby
belongs_to :user
belongs_to :question
```

Add the following to `app/models/question.rb` and `app/models/user.rb`:
```ruby
has_many :votes
```

Open up `app/controllers/votes_controller.rb` and make the file look like:
```ruby
class VotesController < ApplicationController
  before_action :load_question, :create_vote

  def upvote
  end

  def downvote
  end

  private

  def load_question
    @question = Question.find(params[:id])
  end

  def create_vote
    @question.votes.create!(user_id: current_user.id, score: action_name)
    redirect_to @question.event, notice: "#{action_name} created!"
  end
end
```

Open up `config/routes.rb`, and delete the following lines:
```ruby
get 'votes/upvote'
get 'votes/downvote'
```

Now, modify the `resources :questions` part to look like this:
```ruby
resources :questions, only: [:show, :new, :create] do
  member do
    get 'upvote', controller: 'votes'
    get 'downvote', controller: 'votes'
  end
end
```

Finally, to allow users to vote on questions, we need to add links to our new routes on the event page. Open up `app/views/events/show.html.erb` and add the following code after the `Asked by: ...` line:
```erb
<%= link_to "Upvote", upvote_event_question_path(@event, question) %>
<%= link_to "Downvote", downvote_event_question_path(@event, question) %>
```

You can now upvote and downvote questions from the event page! Give it a try. Notice that we are trusting our users to not create more than one vote on a question. This might be a bit of a leap of faith! If you're not trusting, you can add validations.



# Validations

I'll cover ActiveRecord validations, but you should really add database-level validations too. ActiveRecord validations are good for integrating tightly with your Rails app and can have more complex logic, but the database-level validations are the only way of guaranteeing the validations are run.

## Ensuring a user can only vote once

Open up `app/models/vote.rb` and add the following:
```ruby
validates_uniqueness_of :user, scope: :question, message: "can only vote once per question!"
```

There. Now users _should_ only be able to vote once. However, if you run your web application in more than one process, this is not the case.

Instead of an error page, we probably want to add a nice message if a user tries to vote more than once per question. To do this, open up `app/controllers/votes_controller.rb` and change the `create_vote` method to look like this:
```ruby
def create_vote
  @vote = @question.votes.new(user_id: current_user.id, score: action_name)

  if @vote.save
    flash[:notice] = "#{action_name} created!"
  else
    flash[:notice] = "Could not save vote: #{@vote.errors.full_messages.join(",")}"
  end

  redirect_to @question.event
end
```

Now we have a nice error message.

## Ensuring presence of a field

We have our Event and Question models that allow user input (event name and question to ask), so we should validate the presence of these fields. To do this, open up `app/models/event.rb` and add the following:
```ruby
validates_presence_of :name
```

Then open up `app/models/question.rb` and add:
```ruby
validates_presence_of :question
```

Now, if you try to create an event / question without their respective fields, you'll get a user-friendly error message.
