Foundry `expectEmit` --- Simple Notes
-----------------------------------

### What `expectEmit` does

`vm.expectEmit(...)` tells Foundry:

"I expect the next function call to emit a specific event."

You then define that expected event using `emit` in the test.

* * * * *

### Basic Pattern

```
vm.expectEmit(...);
emit MyEvent(...);
contract.someFunction();

```

-   `expectEmit` → sets expectation

-   `emit` → defines what event should look like

-   function call → should emit that event

* * * * *

### Example

Event in contract:

```
event EnteredRaffle(address indexed player);

```

Test:

```
vm.expectEmit(true, false, false, false, address(raffle));
emit EnteredRaffle(PLAYER);

raffle.enterRaffle{value: entranceFee}();

```

* * * * *

### Meaning of Parameters

```
vm.expectEmit(checkTopic1, checkTopic2, checkTopic3, checkData, emitter);

```

-   `checkTopic1` → check first indexed parameter

-   `checkTopic2` → check second indexed parameter

-   `checkTopic3` → check third indexed parameter

-   `checkData` → check all non-indexed parameters

-   `emitter` → contract address that should emit event

* * * * *

### How it maps to event

```
event EnteredRaffle(address indexed player);

```

-   `player` → indexed → Topic 1

-   no other params → no data

So:

```
vm.expectEmit(true, false, false, false);

```

means:

-   check `player` value

-   ignore everything else

* * * * *

### Important Rules

1.  Max 3 indexed parameters

    -   Solidity does not allow more than 3

2.  Non-indexed parameters go into "data"

    -   Can be many

3.  `checkData` behavior

    -   `true` → checks all non-indexed params

    -   `false` → ignores all of them

    -   cannot check them individually

* * * * *

### Example with data

```
event Example(address indexed user, uint256 amount, uint256 fee);

```

Test:

```
vm.expectEmit(true, false, false, true);
emit Example(USER, 100, 5);

```

-   checks `user` (indexed)

-   checks both `amount` and `fee` together

* * * * *

### Key Idea

`expectEmit` lets you control:

-   which parts of the event must match

-   and which parts can be ignored

* * * * *

### Tip

If you want to test a value individually, make it `indexed`.

```
event BetterEvent(address indexed user, uint256 indexed amount);

```

Now both can be checked separately.

* * * * *