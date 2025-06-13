#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "=== Starting Chama Testing ==="
echo "Current Date: 2025-06-12 18:48:43"
echo "Testing as user: Kellyjunior6387"
echo ""

# Test 1: Create a new Chama
echo "Test 1: Creating a new Chama"
CHAMA_ID=$(dfx canister call chama-app-backend createChama '("Test Chama")' | grep -oP '\d+')
if [ ! -z "$CHAMA_ID" ]; then
    echo -e "${GREEN}✓ Created Chama with ID: $CHAMA_ID${NC}"
else
    echo -e "${RED}✗ Failed to create Chama${NC}"
    exit 1
fi
echo ""

# Test 2: Get Chama details
echo "Test 2: Getting Chama details"
dfx canister call chama-app-backend getChama "($CHAMA_ID)"
echo ""

# Test 3: Join Chama
echo "Test 3: Joining Chama"
dfx canister call chama-app-backend joinChama "($CHAMA_ID)"
echo ""

# Test 4: Get contribution amount
echo "Test 4: Getting contribution amount"
dfx canister call chama-app-backend getContributionAmount
echo ""

# Test 5: Make a contribution
echo "Test 5: Making contribution"
dfx canister call chama-app-backend contribute "($CHAMA_ID)"
echo ""

# Test 6: Check contribution status
echo "Test 6: Checking contribution status"
CALLER=$(dfx identity get-principal)
dfx canister call chama-app-backend getContributionStatus "($CHAMA_ID, principal \"$CALLER\")"
echo ""

echo "=== Testing Complete ==="