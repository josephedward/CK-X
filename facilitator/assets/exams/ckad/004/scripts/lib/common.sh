#!/usr/bin/env bash

# Common functions for validation scripts

# Function to check if a resource exists
k_exists() {
    local kind=$1
    local name=$2
    local namespace=$3
    
    if [ -z "$namespace" ]; then
        kubectl get "$kind" "$name" >/dev/null 2>&1
    else
        kubectl get "$kind" "$name" -n "$namespace" >/dev/null 2>&1
    fi
    return $?
}

# Function to get JSON path value
jp() {
    local kind=$1
    local name=$2
    local namespace=$3
    local jsonpath=$4
    
    if [ -z "$namespace" ]; then
        kubectl get "$kind" "$name" -o jsonpath="$jsonpath" 2>/dev/null
    else
        kubectl get "$kind" "$name" -n "$namespace" -o jsonpath="$jsonpath" 2>/dev/null
    fi
}

# Function to check if two values are equal
expect_equals() {
    local actual=$1
    local expected=$2
    local success_msg=$3
    local failure_msg=$4
    
    if [ "$actual" = "$expected" ]; then
        echo "✓ $success_msg"
        return 0
    else
        echo "✗ $failure_msg"
        return 1
    fi
}

# Function to check if a string contains another string
expect_contains() {
    local haystack=$1
    local needle=$2
    local success_msg=$3
    local failure_msg=$4
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "✓ $success_msg"
        return 0
    else
        echo "✗ $failure_msg"
        return 1
    fi
}

# Function to output success
ok() {
    echo "✓ $1"
    exit 0
}

# Function to output failure
fail() {
    echo "✗ $1"
    exit 1
}