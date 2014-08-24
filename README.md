## Anaphora

Anaphora is the anaphoric macro collection for [Elixir](https://github.com/elixir-lang/elixir/). An anaphoric macro is one that deliberately captures a variable from forms supplied to the macro.

### Getting Started

Just add the `anaphora` project to your mix file as a dependency. Then `use Anaphora` module.

### Provided API

#### alet

`alet` is basic anaphoric macro. It's not very useful in user code but other anaphoric macros are built on top of it. `alet` binds some expression to the `it` variable (via `case`) in the scope of the body:

```elixir
defmodule User
  use Anaphora
  
  ...
  def user_email(user_id) do
    alet fetch_user(user_id) do
      if it, do: it.email, else: raise "Failed to fetch user"
    end
  end
end
```

#### aif

Works like `if`, except that result of the condition is bound to `it` (via `alet`) for the scope of the then and else clauses:

```elixir
defmodule User
  use Anaphora
  
  ...
  def user_email(user_id) do
    aif fetch_user(user_id), do: it.email, else: raise "Failed to fetch user"
  end
end
```

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
