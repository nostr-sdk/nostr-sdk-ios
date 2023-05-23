# Nostr SDK iOS Contributing Guide

Thank you for your interest in contributing to this Nostr SDK iOS library. We are currently not accepting external contributions (beyond core maintainers) at this time as we are in the early stages of bootstrapping the library. However, contributions will open up in the future, with the end goal of building a vibrant developer community.

## Core Principles

- Always scope declarations as tightly as possible. That means everything that CAN be marked private, should be marked private.
- No global functions. Everything should be encapsulated somehow. Swift's protocol extensions are a very lightweight and composable way to do this, though sometimes you will need a class.
- All deterministic functions should have good unit test coverage.
- Prefer newer patterns in Swift, such as async-await and Combine.
- Match terminology in the official [Nostr](https://github.com/nostr-protocol/nostr) repo and [NIPs](https://github.com/nostr-protocol/nips) as closely as possible.
- Make public interfaces as clean, simple, and readable as possible. Bury complexity that the call site doesn’t need. Apple does this very effectively with their APIs.
- Automate as much as possible (test execution, release process, building API documentation site).