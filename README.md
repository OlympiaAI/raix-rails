# Ruby AI eXtensions for Rails

## What's Raix for Rails?

Raix (pronounced "ray" because the x is silent) is a library that gives you everything you need to add discrete large-language model (LLM) AI components to your Rails applications. Raix consists of proven code that has been extracted from [Olympia](https://olympia.chat), the world's leading virtual AI team platform, and probably one of the biggest and most successful AI chat projects written completely in Ruby.

Understanding the how to use discrete AI components in otherwise normal code is key to productively leveraging Raix, and the subject of a book written by Raix's author Obie Fernandez, titled [Patterns of Application Development Using AI](https://leanpub.com/patterns-of-application-development-using-ai). You can easily support the ongoing development of this project by buying the book at Leanpub.

At the moment, Raix natively supports use of either OpenAI or OpenRouter as its underlying AI provider. Eventually you will be able to specify your AI provider via an adapter, kind of like ActiveRecord maps to databases. Note that you can also use Raix to add AI capabilities to non-Rails applications as long as you include ActiveSupport as a dependency. Extracting the base code to its own standalone library without Rails dependencies is on the roadmap, but not a high priority.

### Chat Completions

Raix consists of three modules that can be mixed in to Ruby classes to give them AI powers. The first (and mandatory) module is `ChatCompletion`, which provides a `chat_completion` method.

### Use of Tools/Functions

The second (optional) module that you can add to your Ruby classes after `ChatCompletion` is `FunctionDispatch`. It lets you declare and implement functions to be called at the AI's discretion as part of a chat completion "loop" in a declarative, Rails-like "DSL" fashion.

### Prompt Declarations

The third (also optional) module that you can add mix in along with `ChatCompletion` is `PromptDeclarations`. It provides the ability to declare a "Prompt Chain" (series of prompts to be called in a sequence), and also features a declarative, Rails-like "DSL" of its own. Prompts can be defined inline or delegate to callable prompt objects, which themselves implement `ChatCompletion`.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add raix-rails

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install raix-rails

## Usage

```ruby
class MeaningOfLife
  include Raix::ChatCompletion

  def initialize
    self.model = "meta-llama/llama-3-8b-instruct:free"
    transcript << { user: "What is the meaning of life?" }
  end
end

>> MeaningOfLife.new.chat_completion
=> "The meaning of life is a question that has puzzled philosophers, scientists, and thinkers for centuries.
There is no one definitive answer, as it is a deeply personal and subjective question that can vary..."
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Specs require `OR_ACCESS_TOKEN` and `OAI_ACCESS_TOKEN` environment variables, for access to OpenRouter and OpenAI, respectively. You can add those keys to a local unversionsed `.env` file and they will be picked up by the `dotenv` gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[OlympiaAI]/raix-rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[OlympiaAI]/raix-rails/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Raix::Rails project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[OlympiaAI]/raix-rails/blob/main/CODE_OF_CONDUCT.md).
