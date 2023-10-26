# 🦅PasswordStore

> Start Date: Oct 18th, 2023  
> End Date: Oct 25th, 2023


## Bug Leads

- Bug 1: `PasswordStore::setPassword()` has no access control allowing anyone to change the password
- Bug 2: Storing `PasswordStore::s_password` on change allows others to see password

&nbsp;
***
# `PasswordStore::setPassword()` lacks access control, enabling unauthorized password changes

&nbsp;
## Summary
The absence of access control in the `PasswordStore::setPassword()` function allows anyone to access and modify the password.

&nbsp;
## Vulnerability Details
When a `msg.sender` who is not the `PasswordStore::s_owner` attempts to change the password, the function currently permits it. To rectify this, we should restrict access to only the owner.

```diff
	function setPassword(string memory newPassword) external {
+	if(msg.sender != s_owner) revert("Caller not owner
!");
		s_password = newPassword;
        emit SetNetPassword();
    }

```

&nbsp;
## Proof of Concept
The test suite below illustrates the vulnerability's validity and severity.

### How to Run the Test

**Requirements**
- Install [Foundry](https://book.getfoundry.sh/getting-started/installation.html).
- Clone the project codebase into your local workspace.
- Add the tests from the Codebase section below to the `PasswordStore.t.sol` file in the test folder, placing it after line 33.

**Step-by-step Guide to Run the Test**
1. Ensure the above requirements are met.
2. Execute the following command in your terminal to run the test:

```bash
forge test --match-test "test_anyone_can_set_password"
```

> *Note: Refer to the test function comments to understand the cases being tested.*

### Codebase

The codebase below utilizes Foundry for testing.

**Test Cases**
```solidity
contract MorePasswordStoreTest is Test {
    PasswordStore public passwordStore;
    DeployPasswordStore public deployer;
    address public owner;
    address public notOwner;

    function setUp() public {
        deployer = new DeployPasswordStore();
        passwordStore = deployer.run();
        owner = msg.sender;
        notOwner = address(1);
        string memory expectedPassword = "originalPassword";
        passwordStore.setPassword(expectedPassword);
    }

    /** @notice This test checks if other users who are not owner can set a new password. */
    function test_anyone_can_set_password() public {
        // Start Prank passes calls to another user -- notOwner
        // notOwner changes the password
        vm.startPrank(notOwner);
        string memory changedPassword = "newPassword";
        passwordStore.setPassword(changedPassword);

        // Control is passed by back to owner to be able to call getPassword
        vm.startPrank(owner);
        string memory currentPassword = passwordStore.getPassword();

        // This assert tests that the password was changed
        // and that the current password is changedPassword
        assertEq(currentPassword, changedPassword);
    }
}
```

## Impact

### Implications

Passing the above tests implies that the vulnerability:

- Allows anyone to negatively affect the UX experience of the protocol.
- Compromises the protocol's integrity.
- Exposes users to potential application crashes.

**Exploit Scenario**

John sets a password as the account owner, but Sarah changes the password. As a result, applications receive different values when attempting to retrieve the password, potentially leading to application crashes.

## Tools Used

- Foundry

## Recommendations

To fix this bug, add a `require` statement that only allows the owner to successfully call the `setPassword()` function.

```diff
    function setPassword(string memory newPassword) external {
+		require(msg.sender == s_owner, "Caller not owner!"); // Add this line
        s_password = newPassword;
        emit SetNetPassword();
    }
```

&nbsp;
&nbsp;
* * *
# Exposing `PasswordStore::s_password` as an on-chain string allows unauthorized access

## Summary

Declaring `PasswordStore::s_password()` as private does not guarantee that it cannot be accessed on-chain. Attackers can inspect contract transactions to retrieve values stored in the contract's state.

## Vulnerability Details

Any user can make an RPC call to access this slot in the contract and retrieve the stored value.

```diff
- string private s_password;
```

## Proof of Concept (PoC)

The script and commands below demonstrates the validity and severity of the vulnerability.

### How to Run the PoC

**Requirements**
- Install [Foundry](https://book.getfoundry.sh/getting-started/installation.html).
- Clone the project codebase to your local workspace.
- Create a .env file in your root folder and add the required variables.
- The .env file should follow this format:

```env
RPC_URL=
PRIVATE_KEY=
ETHERSCAN_API_KEY=
```

**Step-by-step Guide to Run the PoC**
1. Ensure the above requirements are met.
2. Load .env variables into the terminal by running `source .env`.
3. Deploy the contracts by executing the following command in your terminal:

```bash
forge script script/DeployPasswordStore.s.sol:DeployPasswordStore --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast -vv
```

4. Copy the contract address into a notepad.
5. Note that `s_password` is set as "myPassword" in the deploy script.
6. Read the `s_password` value from the contract storage by running:

```bash
cast storage 0xPasswordStoreContractAddress 1 --rpc-url $RPC_URL
```

   - Note:
     - Replace `0xPasswordStoreContractAddress` with the corresponding PasswordStore contract address.
     - The return value is in byte32 format.

7. Copy the returned data value to your notes.
8. Finally, read the data by converting it from byte32 to ASCII using the following command:

```bash
cast --to-ascii 0xReturnedByte32Data
```

   - Note:
     - Replace `0xReturnedByte32Data` with the corresponding byte data from your previous execution.

   The return value should be "myPassword", which proves that `s_password` can be read from storage.

## Impact

### Implications

Exposing user passwords can compromise network security, as attackers can easily gain unauthorized access to user accounts. This poses a significant threat to user experience and general security.

**Exploit Scenario**

John sets a password for his account, believing that the protocol guarantees the security of his information. However, Sarah, a more technically inclined user, reads the value of John's password, effectively gaining access to his account.

## Tools Used

- Foundry

## Recommendations

Private data should not be stored unencrypted in contract code or state. Instead, consider encrypting it or storing it off-chain to enhance security and protect user information.
