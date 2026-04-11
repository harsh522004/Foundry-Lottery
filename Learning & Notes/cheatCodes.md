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
Foundry Cheatcodes --- `vm.roll` and `vm.warp`
--------------------------------------------

### `vm.roll`

#### What it does

`vm.roll(blockNumber)` sets the **block number** (`block.number`) in your test.

* * * * *

#### Syntax

```
vm.roll(uint256 newBlockNumber);

```

* * * * *

#### Example

```
function testBlockNumberChange() public {
    vm.roll(100);

    assertEq(block.number, 100);
}

```

* * * * *

#### When to use

Use `vm.roll` when your contract logic depends on:

-   `block.number`

-   things like block-based delays

-   voting periods

-   block-based conditions

* * * * *

#### Example use case

```
function isFinished() public view returns (bool) {
    return block.number > endBlock;
}

```

Test:

```
vm.roll(endBlock + 1);
assertTrue(contract.isFinished());

```

* * * * *

* * * * *

### `vm.warp`

#### What it does

`vm.warp(timestamp)` sets the **block timestamp** (`block.timestamp`) in your test.

* * * * *

#### Syntax

```
vm.warp(uint256 newTimestamp);

```

* * * * *

#### Example

```
function testTimeChange() public {
    vm.warp(1 days);

    assertEq(block.timestamp, 1 days);
}

```

* * * * *

#### When to use

Use `vm.warp` when your contract logic depends on:

-   time (`block.timestamp`)

-   time locks

-   deadlines

-   auctions

-   raffles / randomness timing

* * * * *

#### Example use case

```
function canWithdraw() public view returns (bool) {
    return block.timestamp >= unlockTime;
}

```

Test:

```
vm.warp(unlockTime);
assertTrue(contract.canWithdraw());

```

* * * * *

* * * * *

### Key Difference

| Cheatcode | Changes | Used for |
| --- | --- | --- |
| `vm.roll` | `block.number` | block-based logic |
| `vm.warp` | `block.timestamp` | time-based logic |

* * * * *

* * * * *

### Important Notes

1.  These only affect the test environment

    -   They do not exist on real blockchain

2.  They apply immediately

    -   No mining required

3.  You can use them multiple times in one test

* * * * *

* * * * *

### Quick Mental Model

-   `vm.roll` → "move blocks forward"

-   `vm.warp` → "move time forward"

* * * * *