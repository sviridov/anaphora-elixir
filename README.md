## Anaphora

Anaphora is the anaphoric macro collection for [Elixir](https://github.com/elixir-lang/elixir/). An anaphoric macro is one that deliberately captures a variable from forms supplied to the macro.

### Getting Started

Just add the `anaphora` project to your mix file as a dependency. Then `use Anaphora` module.

### Provided API

#### acond

Works like `cond`, except that result of each condition is bound to `it` (via `alet`) for the scope of the corresponding body:

```elixir
defmodule Notification
  use Anaphora
  
  ...
  def send_notification(user, message) do
    acond do
      user.email -> send_notification_by_email(it, message)
      user.phone -> send_notification_by_sms(it, message)
      :else -> raise "Unable to send notification"
    end
  end
end
```
