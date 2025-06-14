#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "=== Starting Chama Testing ==="
echo "Current Date: 2025-06-12 18:48:43"
dfx identity use TEST
echo "Testing as user: TEST"
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

#Join chama with user NYAMS
echo "Switching to NYAMS"
dfx identity use NYAMS
dfx canister call chama-app-backend joinChama "($CHAMA_ID)"
echo ""

#Join chama with user ICP
echo "Switching to ICP"
dfx identity use ICP
dfx canister call chama-app-backend joinChama "($CHAMA_ID)"
echo ""

# Test 2: Get Chama details
echo "Test 2: Getting Chama details"
dfx canister call chama-app-backend getChama "($CHAMA_ID)"
echo ""

# Test 5: Make a contribution as NYAMS
echo "Test 5: Making contribution as NYAMS"
dfx identity use NYAMS
dfx canister call chama-app-backend contribute "($CHAMA_ID)"
echo ""

# Test 5: Make a contribution as NYAMS
echo "Test 5: Making contribution as ICP"
dfx identity use ICP
dfx canister call chama-app-backend contribute "($CHAMA_ID)"
echo ""

# Test 6: Check contribution history
echo "Test 6: Checking Transcation history"
dfx canister call chama-app-backend getTransactionHistory "($CHAMA_ID)"
echo ""

# Test 6: Check Formatted LLM history
echo "Test 7: Checking LLM Transcation history"
dfx canister call chama-app-backend getFormattedTransactionsForLLM "($CHAMA_ID)"
echo ""


echo "=== Testing Complete ==="