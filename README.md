## Anaphora

Anaphora is the anaphoric macro collection for Elixir

### Examples

```elixir
defmodule Notification
  use Anaphora
  
  ...
  def send_notification(user, message) do
    acond do
      user.email -> send_notification_by_email(it, message)
      user.phone -> send_notification_by_sms(it, message)
    end
  end
end
```
