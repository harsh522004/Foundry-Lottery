### Events Testing --- `expectEmit`

**Purpose**\
`vm.expectEmit(...)` is used to verify that a specific event is emitted in the next function call.

**Pattern**

vm.expectEmit(...);\
emit MyEvent(...);\
contract.someFunction();

-   `expectEmit` → sets expectation
-   `emit` → defines expected event
-   function call → must emit that event

**Example**

event EnteredRaffle(address indexed player);

vm.expectEmit(true, false, false, false, address(raffle));\
emit EnteredRaffle(PLAYER);

raffle.enterRaffle{value: entranceFee}();

**Parameters**

vm.expectEmit(checkTopic1, checkTopic2, checkTopic3, checkData, emitter);

-   `checkTopic1/2/3` → indexed params
-   `checkData` → non-indexed params
-   `emitter` → contract address

**Mapping**

event EnteredRaffle(address indexed player);

-   `player` → Topic1

vm.expectEmit(true, false, false, false);

-   checks only `player`

**Rules**

-   Max 3 indexed parameters
-   Non-indexed params go into `data`
-   `checkData = true` → checks all non-indexed params
-   Cannot partially check non-indexed params

**Example with Data**

event Example(address indexed user, uint256 amount, uint256 fee);

vm.expectEmit(true, false, false, true);\
emit Example(USER, 100, 5);

**Key Idea**\
You decide what must match and what can be ignored.

**Tip**\
If a value needs individual testing, make it indexed:

event BetterEvent(address indexed user, uint256 indexed amount);

* * * * *

### Block & Time Control

#### `vm.roll`

Sets `block.number`.

vm.roll(uint256 newBlockNumber);

**Example**

vm.roll(100);\
assertEq(block.number, 100);

**Use cases**

-   block-based conditions
-   voting periods
-   delays

* * * * *

#### `vm.warp`

Sets `block.timestamp`.

vm.warp(uint256 newTimestamp);

**Example**

vm.warp(1 days);\
assertEq(block.timestamp, 1 days);

**Use cases**

-   time locks
-   deadlines
-   auctions
-   raffles

* * * * *

#### Difference

| Cheatcode | Affects | Use case |
| --- | --- | --- |
| `vm.roll` | block.number | block-based logic |
| `vm.warp` | block.timestamp | time-based logic |

**Mental Model**

-   `roll` → move blocks
-   `warp` → move time

**Notes**

-   Only affects test environment
-   Applies immediately
-   Can be reused multiple times

* * * * *

### Assertions --- `assertEq`

**Purpose**\
Checks if two values are equal.

assertEq(actual, expected);

**Examples**

assertEq(add(2, 3), 5);\
assertEq(myContract.value(), 10);\
assertEq(address(user).balance, 1 ether);

**With message**

assertEq(result, 5, "Result should be 5");

**Key Idea**\
Use for strict and clear equality checks.

* * * * *

### Cheatcodes & Utilities

#### `hoax`

Combination of `prank + deal`

hoax(address(i), SEND_VALUE);

* * * * *

#### Creating Test Addresses

address user = makeAddr("alice");           // readable\
address funder = address(uint160(1234));   // raw

* * * * *

#### `expectRevert`

Used to assert that a function call fails.

vm.expectRevert();\
contract.someFunction();

-   Reverts → test passes
-   Does not revert → test fails

* * * * *

### Debugging Commands

forge test -vv      # logs\
forge test -vvv     # traces\
forge test -vvvv    # full traces

* * * * *

### EVM & Gas Understanding

**Useful Tools**

-   EVM opcodes → <http://evm.codes/>
-   Bytecode → opcode → <https://etherscan.io/opcode-tool>
-   Function selector lookup → <https://4byte.sourcify.dev/>

**Get deployed bytecode**

cast code <contract_address>

* * * * *

#### Memory vs Storage

-   **Memory**
    -   Temporary
    -   Cleared after execution
    -   Like RAM
-   **Storage**
    -   Persistent
    -   Stored on-chain
    -   Expensive
    -   Like Hard Drive

**Insight**\
Accessing storage costs more gas than memory.

* * * * *

#### Gas Optimization Notes

-   Prefer memory over storage when possible
-   Use naming like:
    -   `s_` → storage
    -   `i_` → immutable

Reference:\
<https://updraft.cyfrin.io/courses/foundry/foundry-fund-me/optimise-solidity-function-gas-costs>

* * * * *

### Solidity Best Practices

-   Write strong NatSpec comments
-   Prefix custom errors with contract name

    error Raffle_NotEnoughEthSent();

-   Prefer `external` over `public` for gas efficiency
-   Use `revert` / custom errors instead of `require`
-   Use `indexed` for searchable event logs
-   `payable` arrays allow direct transfers

* * * * *

### Chainlink

-   VRF (randomness):\
    <https://docs.chain.link/vrf/v2/subscription/examples/get-a-random-number>
-   Security considerations:\
    <https://docs.chain.link/vrf/v2-5/security>
-   Automation:\
    <https://docs.chain.link/chainlink-automation/guides/compatible-contracts>\
    <https://docs.chain.link/chainlink-automation/guides/job-scheduler>

* * * * *

### Libraries & UI

-   Headers library:\
    <https://github.com/transmissions11/headers>
-   Svelte UI:\
    <https://svelte.dev/tutorial/svelte/welcome-to-svelte>