---
applyTo: "**"
---

# Build structured payloads with a serializer — never hand-concatenated JSON

When producing JSON (HTTP request/response bodies, event payloads, config, log records), build an **object/struct/dictionary** and hand it to the language's serializer. Never assemble JSON by string concatenation or interpolation — that route silently produces invalid JSON the moment a value contains a quote, brace, newline, Unicode, or null, and it skips the type/escaping guarantees the serializer gives you for free.

## Don't

```
# hand-concatenated — fragile, unescaped, breaks on any special character
payload = '{"status":"' + status + '","items":' + str(count) + '}'
```

## Do

```
# build a structured object, then serialize
payload = serialize({
    "status": status,
    "items": count,
})
```

## Rules

- Construct the payload as a typed object / map / record, then serialize it once at the boundary.
- **Wrap status fields explicitly** — set `status` (and similar enum-like fields) as a named property on the object, not by splicing a literal into a string. This keeps the field name, type, and value auditable and escaped.
- Deserialize the same way: parse into a known type, don't regex/substring JSON out of a string.
