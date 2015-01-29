### Contents

* [Usage](?#usage)
* [Methods](?#methods)
* [Class Methods](?#class-methods)
* [Accessors](?#accessors)

### Usage

The ProMotion logger handles debugging and informational output to the REPL. It is accessible from ProMotion.logger or PM.logger. You can also set a new logger by setting `PM.logger = MyLogger.new`.

```ruby
def some_method
  PM.logger.error "My error"
  PM.logger.deprecated "Deprecation warning"
  PM.logger.warn "My warning"
  PM.logger.debug @some_object
  PM.logger.info "Some info #{@object}"
  PM.logger.log("My Custom Error", "My Message", :red)
end
```

### Methods

#### log(label, message_text, color)

Output a colored console message.

```ruby
PM.logger.log("TESTING", "This is red!", :red)
```

#### error(message)

Output a red colored console error.

```ruby
PM.logger.error("This is an error")
```

#### deprecated(message)

Output a yellow colored console deprecated.

```ruby
PM.logger.deprecated("This is a deprecation warning.")
```

#### warn(message)

Output a yellow colored console warning.

```ruby
PM.logger.warn("This is a warning")
```

#### debug(message)

Output a purple colored console debug message.

```ruby
PM.logger.debug(@some_var)
```

#### info(message)

Output a green colored console info message.

```ruby
PM.logger.info("This is an info message")
```

### Class Methods

**None.**

### Accessors

**None.**
