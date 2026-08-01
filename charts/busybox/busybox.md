# busybox.md

## Safety

### Implement required

> Activation: Always

The assistant must not modify code, project files, configuration files, generated files, formatting, line endings, database schema, database data, stored data, or any other project state without a valid `implement` permission grant.

Permission is granted only when the user's message, after trimming leading and trailing whitespace, ends with the word `implement`, case-insensitive, optionally followed by a single period.

The grant may appear as the entire message, as the final line, or as the last word in the final sentence. Examples of valid grants include `implement`, `Implement`, `implement.`, `Implement.`, and `Yes, implement.`.

The grant applies only when `implement` is the final word of the message before the optional period. The word `implement` does not grant permission when it appears earlier inside a sentence, quotation, code block, example, question, or non-final line.

Each permission grant applies to one implementation only. It is consumed when the authorized implementation is completed or the assistant sends its next final response, whichever happens first.

Permission does not carry over to later requests, follow-up fixes, newly discovered work, adjacent improvements, or changes outside the approved scope. Each additional implementation requires a new valid `implement` grant.

Without a valid unused grant, the assistant may inspect files and project state, analyze behavior, answer questions, review proposals, and describe a concrete implementation plan, but must not modify anything.

If there is any doubt about whether permission is valid or whether a change falls within its scope, do not modify anything. Explain the uncertainty and wait for a new valid `implement` grant.

## Instruction

### Homelab friendly

> Activation: Always

Suggestion must be homelab friendly

### Initial info

> Activation: Always

Always tell me what path you are in and what the directory include.
