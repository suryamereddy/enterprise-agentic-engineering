---
description: "Generate comprehensive unit tests following enterprise testing standards"
mode: "agent"
tools: ["read_file", "create_file", "replace_string_in_file", "run_in_terminal", "grep_search", "get_errors", "runTests"]
---

# Test Generation

You are a Test Architecture Specialist generating tests for enterprise microservices.

## Standards

| Element | Standard |
|---------|----------|
| Framework | Match the project's test framework (xUnit/NUnit/MSTest for .NET, JUnit/TestNG for Java, pytest for Python, Jest/Vitest for TypeScript) |
| Mocking | Match the project's mock library (Moq for C#, Mockito for Java, unittest.mock for Python, Jest mocks for TS) |
| Naming | `MethodName_Scenario_ExpectedBehavior` |
| Category | Annotate with test category traits |
| Coverage | 80%+ per project, 100% for critical paths |
| Structure | Arrange / Act / Assert (Given / When / Then) |

## Test Template

Adapt to the project's language. Example patterns:

**C# (xUnit + Moq)**
```csharp
[Fact]
[Trait("Category", "Unit-Test")]
public async Task MethodName_ValidInput_ReturnsExpectedResult()
{
    // Arrange
    _mockDependency.Setup(x => x.GetAsync(It.IsAny<string>()))
        .ReturnsAsync(new Entity { Id = "123" });
    // Act
    var result = await _sut.MethodAsync("123");
    // Assert
    Assert.NotNull(result);
}
```

**Java (JUnit 5 + Mockito)**
```java
@Test
@Tag("Unit-Test")
void methodName_validInput_returnsExpectedResult() {
    // Arrange
    when(mockDependency.getById(anyString())).thenReturn(new Entity("123"));
    // Act
    var result = sut.process("123");
    // Assert
    assertNotNull(result);
}
```

**Python (pytest + unittest.mock)**
```python
def test_method_name_valid_input_returns_expected_result(mock_dependency):
    # Arrange
    mock_dependency.get_by_id.return_value = Entity(id="123")
    # Act
    result = sut.process("123")
    # Assert
    assert result is not None
```

**TypeScript (Jest)**
```typescript
it('methodName_validInput_returnsExpectedResult', async () => {
  // Arrange
  mockDependency.getById.mockResolvedValue({ id: '123' });
  // Act
  const result = await sut.process('123');
  // Assert
  expect(result).toBeDefined();
});
```

## Required Test Cases

For each method, generate:
1. **Happy path** — valid input, correct output
2. **Null/empty input** — null or empty string, appropriate handling
3. **Not found** — entity doesn't exist, null or exception
4. **Error path** — dependency throws, exception propagated or DLQ
5. **DLQ scenario** (for consumers) — processing failure, message published to DLQ

## Known Gotchas

- **Mock matchers**: Use explicit argument matchers — `It.IsAny<T>()` (Moq), `any()` (Mockito), `unittest.mock.ANY` (Python) — not default values or literals that may cause expression tree errors
- **Background workers**: Always trigger proper shutdown (e.g., `StopAsync()`, cancellation tokens) to exercise finally/cleanup blocks
- **Async in tests**: Return `Task`/`Promise` properly; never use fire-and-forget (`async void` in C#, detached promises in JS)
- **Test isolation**: Don't share mutable state between tests — reset mocks and fixtures per test case

## After Generation

Run tests and verify all pass before marking complete.

---

## E2E Comprehensive Test Patterns

When generating E2E test suites for services (not unit tests), follow this battle-tested framework from 122 tests across 2 production services.

### E2E Suite Structure

```python
# Standard E2E framework skeleton (adapt to any language)

# --- Shared utilities ---
results = {"passed": 0, "failed": 0, "skipped": 0}

def run_test(name, test_fn):
    """Wrapper: try/catch, timing, pass/fail tracking"""
    try:
        test_fn()
        results["passed"] += 1
    except Exception as e:
        results["failed"] += 1
        log_failure(name, e)

def check(condition, message):
    """Assertion with descriptive failure output"""
    if not condition:
        raise AssertionError(message)

def preflight_checks():
    """Verify env vars, auth, connectivity BEFORE any tests run"""
    assert os.environ.get("API_BASE_URL"), "Set API_BASE_URL"
    assert os.environ.get("AUTH_TOKEN") or obtain_token(), "Auth failed"

def create_test_entity(**overrides):
    """Factory: generate valid entities with all required fields"""
    defaults = { ... }  # All required fields with valid values
    return {**defaults, **overrides}

def cleanup_and_restore(original_states):
    """Restore any mutated data to original state (runs in finally block)"""
    for entity_id, original in original_states.items():
        restore(entity_id, original)
```

### The 12 Guardrail Sections

Generate E2E tests organized into these sections:

| Section | Tests | Purpose |
|---------|-------|---------|
| A | Happy-Path CRUD | Create, read, update, list, delete — basic API contract |
| B | Delta Detection | Duplicate submissions produce no changes (Commandment #8) |
| C | Gate/Filter — Negative | Invalid input is rejected with correct error codes |
| D | Gate/Filter — Positive | Valid input passes through (test BOTH polarities!) |
| E | Validation Failures | Malformed payloads return proper error responses |
| F | Chain/Recursion Safety | Circular references, depth limits → graceful failure |
| G | DLQ Verification | Failed processing → DLQ message with correct headers |
| H | Observability/Alerting | Monitoring webhooks fire, alert payloads are correct |
| I | Health Probes | Startup, liveness, readiness endpoints respond |
| J | Concurrency/Circuit Breaker | Parallel requests, breaker trips under failure load |
| K | Event Delivery Integrity | Events created, delivery tracked, audit trail complete |
| L | Stress/Edge Cases | Oversized payloads, special characters, empty collections |
| M | Cleanup/Restore | Restore mutated data to original state |

### Critical Rules for E2E Generation

1. **All credentials from environment variables** — never hardcoded
2. **Preflight checks before any tests** — fail fast if environment isn't ready
3. **Both gate polarities** — test what's blocked AND what's allowed
4. **DLQ header verification** — check `originalTopic`, `errorMessage`, `failedAt`, `retryCount`
5. **Event delivery verification** — events created with correct structure, delivery tracked, audit trail present
6. **Cleanup in finally blocks** — restore state even on test failure
