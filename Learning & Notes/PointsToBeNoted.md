### Mindset

Normally, when you start building a new project, you will write 1-2 functions and then try to compile it ... and BAM, it doesn't compile, you go and fix that and then you write a couple of tests to ensure the functionality you intend is there ... and some of these tests fail. Why do they fail? You go back to the code, make some changes, compile it again, test it again and hopefully everything passes. Amazing, you just wrote your first 1-2 functions, your project will most likely need 10 more. This might look cumbersome, but it's the best way to develop a smart contract, far better than trying to punch in 10 functions and then trying to find out where's the bug that prevents the contract from compiling. The reason why Patrick is not testing every single thing on every single step is, as you've guessed, the fact that the contract will be refactored over and over again, and testing a function that will be heavily modified two lessons from now is not that efficient.

> ***You won't develop smart contracts without setbacks. And that is ok!***
>
> ***Setbacks are not indicators of failure, they are signs of growth and learning***

~ words from Cyfrin Updrafts

### The CEI Pattern In Functions

The Checks-Effects-Interactions pattern is a crucial best practice in Solidity development aimed at enhancing the security of smart contracts, especially against reentrancy attacks. This pattern structures the code within a function into three distinct phases:

-   Checks: Validate inputs and conditions to ensure the function can execute safely. This includes checking permissions, input validity, and contract state prerequisites.
-   Effects: Modify the state of our contract based on the validated inputs. This phase ensures that all internal state changes occur before any external interactions.
-   Interactions: Perform external calls to other contracts or accounts. This is the last step to prevent reentrancy attacks, where an external call could potentially call back into the original function before it completes, leading to unexpected behavior. (More about reentrancy attacks on a later date)

### Error In Contract

Using a basic **`revert()`** statement may not provide evidence on why a transaction failed. A better approach is to define custom errors by combining the **contract name** with a **description**, such as **`Raffle__UpkeepNotNeeded()`**. Additionally, including **parameters** can offer more detailed information about the cause of the transaction failure.

### Fuzz testing

- Generally, fuzz testing, also known as fuzzing, is an automated software testing technique that involves injecting invalid, malformed, or unexpected inputs into a system to identify software defects and vulnerabilities. 
- This method helps in revealing issues that may lead to crashes, security breaches, or performance problems. Fuzz testing operates by feeding a program with large volumes of random data (referred to as "fuzz") to observe how the system handles such inputs. 
- If the system crashes or exhibits abnormal behavior, it indicates a potential vulnerability or defect that needs to be addressed.