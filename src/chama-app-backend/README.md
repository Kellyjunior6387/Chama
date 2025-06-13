# Chama Smart Contract API Documentation

Current Version: 1.0.0  
Last Updated: 2025-06-13 11:54:23 UTC  
Author: Kellyjunior6387

## Table of Contents
- [Overview](#overview)
- [Types](#types)
- [Core Functions](#core-functions)
- [Contribution Management](#contribution-management)
- [Query Functions](#query-functions)
- [Error Handling](#error-handling)
- [Usage Examples](#usage-examples)

## Overview

This API documentation covers the smart contract functions for the Chama (Investment Group) system. The contract handles member management, contributions, and round-based payouts.

## Types

### DateInfo
```typescript
type DateInfo = {
    year: Nat;
    month: Nat;
    day: Nat;
    hour: Nat;
    minute: Nat;
    second: Nat;
};
```

### ReceiverInfo
```typescript
type ReceiverInfo = {
    principal: Principal;
    expectedAmount: Nat;
    dueDate: DateInfo;
    status: Text;
};
```

### ContributionResult
```typescript
type ContributionResult = {
    status: Text;
    contributionAmount: Nat;
    receiver: ?Principal;
    nextPayoutDate: ?Int;
    transactionId: ?Text;
};
```

### RoundStatus
```typescript
type RoundStatus = {
    currentRound: Nat;
    totalContributions: Nat;
    expectedContributions: Nat;
    roundStartDate: DateInfo;
    daysRemaining: Int;
};
```

## Core Functions

### createChama
Creates a new Chama group.

```typescript
createChama: (name: Text) -> async Nat
```

**Parameters:**
- `name`: Name of the Chama group

**Returns:**
- Chama ID (Nat)

**Example:**
```javascript
const chamaId = await chamaActor.createChama("My Investment Group");
```

### joinChama
Join an existing Chama group.

```typescript
joinChama: (chamaId: Nat) -> async Text
```

**Parameters:**
- `chamaId`: ID of the Chama to join

**Returns:**
- Success/Error message

**Example:**
```javascript
const result = await chamaActor.joinChama(chamaId);
```

## Contribution Management

### contribute
Make a contribution to the current round.

```typescript
contribute: (chamaId: Nat) -> async Result<ContributionResult, Text>
```

**Parameters:**
- `chamaId`: ID of the Chama

**Returns:**
- ContributionResult or error message

**Important Notes:**
- Minimum 2 members required for contributions
- Current receiver cannot contribute
- Amount is fixed at 1 ICP (100_000_000 e8s)

**Example:**
```javascript
const result = await chamaActor.contribute(chamaId);
if (result.ok) {
    const {
        status,
        contributionAmount,
        receiver,
        nextPayoutDate,
        transactionId
    } = result.ok;
    // Handle successful contribution
}
```

## Query Functions

### getNextPayoutInfo
Get information about the next scheduled payout.

```typescript
getNextPayoutInfo: (chamaId: Nat) -> async Result<ReceiverInfo, Text>
```

**Returns:**
```typescript
{
    principal: Principal;    // Receiver's principal
    expectedAmount: Nat;    // Total expected contribution
    dueDate: DateInfo;      // Due date for contributions
    status: Text;           // Current status
}
```

**Example:**
```javascript
const payoutInfo = await chamaActor.getNextPayoutInfo(chamaId);
if (payoutInfo.ok) {
    const {
        principal,
        expectedAmount,
        dueDate,
        status
    } = payoutInfo.ok;
    
    // Format date
    const formattedDate = `${dueDate.year}-${String(dueDate.month).padStart(2, '0')}-${String(dueDate.day).padStart(2, '0')}`;
}
```

### getCurrentReceiverDetails
Get details about the current receiver.

```typescript
getCurrentReceiverDetails: (chamaId: Nat) -> async Result<ReceiverInfo, Text>
```

**Example:**
```javascript
const receiverDetails = await chamaActor.getCurrentReceiverDetails(chamaId);
```

### getRoundStatus
Get the current round's status.

```typescript
getRoundStatus: (chamaId: Nat) -> async Result<RoundStatus, Text>
```

**Example:**
```javascript
const roundStatus = await chamaActor.getRoundStatus(chamaId);
if (roundStatus.ok) {
    const {
        currentRound,
        totalContributions,
        expectedContributions,
        roundStartDate,
        daysRemaining
    } = roundStatus.ok;
}
```

## Error Handling

All functions return a Result type that can contain either success data or an error message:

```typescript
type Result<Ok, Err> = {
    #ok: Ok;
    #err: Err;
};
```

Common error cases:
- Chama not found
- Not enough members
- Current receiver cannot contribute
- Round not active
- Invalid contribution amount

Example error handling:
```javascript
try {
    const result = await chamaActor.contribute(chamaId);
    if (result.ok) {
        // Handle success
        console.log("Contribution successful:", result.ok);
    } else {
        // Handle error
        console.error("Contribution failed:", result.err);
    }
} catch (error) {
    console.error("Transaction error:", error);
}
```

## Usage Examples

### Complete Contribution Flow
```javascript
async function handleContribution(chamaId) {
    try {
        // 1. Check round status
        const roundStatus = await chamaActor.getRoundStatus(chamaId);
        if (roundStatus.err) {
            throw new Error(roundStatus.err);
        }

        // 2. Get current receiver
        const receiverInfo = await chamaActor.getCurrentReceiverDetails(chamaId);
        if (receiverInfo.err) {
            throw new Error(receiverInfo.err);
        }

        // 3. Make contribution
        const contribution = await chamaActor.contribute(chamaId);
        if (contribution.ok) {
            const {
                status,
                contributionAmount,
                receiver,
                nextPayoutDate,
                transactionId
            } = contribution.ok;

            // 4. Update UI
            updateContributionStatus(status);
            updateNextPayout(nextPayoutDate);
            showTransactionConfirmation(transactionId);
        } else {
            throw new Error(contribution.err);
        }
    } catch (error) {
        handleError(error);
    }
}
```

### Display Round Information
```javascript
async function displayRoundInfo(chamaId) {
    const roundStatus = await chamaActor.getRoundStatus(chamaId);
    if (roundStatus.ok) {
        const {
            currentRound,
            totalContributions,
            expectedContributions,
            roundStartDate,
            daysRemaining
        } = roundStatus.ok;

        document.getElementById('roundNumber').textContent = currentRound;
        document.getElementById('progress').textContent = 
            `${totalContributions}/${expectedContributions}`;
        document.getElementById('timeRemaining').textContent = 
            `${daysRemaining} days remaining`;
    }
}
```