# Contributing Guide

Thank you for your interest in contributing to Nostr SDK for Apple Platforms.

If you would like to contribute code, please [fork](https://github.com/nostr-sdk/nostr-sdk-ios/fork) the repository on GitHub, apply your changes on your fork, and open a [pull request](https://github.com/nostr-sdk/nostr-sdk-ios/compare). Please ensure that the [core principles](#core-principles) are followed.

If you would like to report an issue, please file an [issue](https://github.com/nostr-sdk/nostr-sdk-ios/issues/new) in GitHub.

## Core Principles

- Always scope declarations as tightly as possible. That means everything that CAN be marked private, should be marked private.
- No global functions. Everything should be encapsulated somehow. Swift's protocol extensions are a very lightweight and composable way to do this, though sometimes you will need a class.
- All deterministic functions should have good unit test coverage.
- Prefer newer patterns in Swift, such as async-await and Combine.
- Match terminology in the official [Nostr](https://github.com/nostr-protocol/nostr) repo and [NIPs](https://github.com/nostr-protocol/nips) as closely as possible.
- Make public interfaces as clean, simple, and readable as possible. Bury complexity that the call site doesn’t need. Apple does this very effectively with their APIs.
- Automate as much as possible (test execution, release process, building API documentation site).