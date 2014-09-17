First, get Ruby 2.0 installed. This is fairly easy on Mac and Linux, and isn't too bad on Windows. There are several good guides online.

Then, you'll want to install Ruby on Rails. To do this, you simply run the following in your console:
```
gem install rails
rails --version
```

The second command should output a version string if the install went well.

Now, you'll want to change to (or create) your code workspace, and run the following command:
```
rails new askify
cd askify
```

This will create a new project in your code workspace called `askify`, create the Rails project skeleton, and install all of the required [gems](http://en.wikipedia.org/wiki/RubyGems).

Use your favourite editor to change the gemfile to look exactly like [this](https://github.com/manygrams/intro_to_RoR_workshop/blob/85d827399cbfbd6606c1de5d27832f9629f25bd8/askify/Gemfile), and run the following command:
```
bundle install
```

The final preparation step is to run the Rails server, which can be done as such:
```
bundle exec rails server
```

If you open your favourite browser and go to `http://localhost:3000`, you should see the default Rails page!

If you have any problems setting up, feel free to [contact me](https://twitter.com/nicolas__evans) for help :)
