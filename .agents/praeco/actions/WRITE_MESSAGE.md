# WRITE_MESSAGE

## Purpose
Write scoped outward-facing messaging tied to verified product behavior.

## When to Use
- The task is release notes, launch copy, or user-facing messaging

## Inputs
- Audience
- Verified shipped behavior
- Brand direction if available

## Constraints
- Do not invent features
- Keep copy aligned to actual behavior

## Process
1. Read the verified product changes.
2. Shape the message for the intended audience.
3. Return the copy artifact plus assumptions.

## Output
A structured specialist result containing copy artifacts and risks.

## Failure Modes
- Unverified feature claims: block or narrow scope
- Brand mismatch: recommend `signifer`

## Example
`praeco::WRITE_MESSAGE` to draft release notes for a new runtime feature.
