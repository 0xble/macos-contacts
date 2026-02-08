# macOS Contacts CLI

Manage your macOS Contacts from the terminal. Search, create, edit, and delete contacts. Returns structured JSON. Zero dependencies -- uses built-in macOS tools.

## Install

```bash
git clone https://github.com/your-user/macos-contacts.git
cd macos-contacts
sudo make install
```

On first run, macOS will ask for permission to access Contacts -- click **Allow**.

## Uninstall

```bash
sudo make uninstall
```

## Commands

### Search

```bash
contacts <query>
contacts search [--name | --number | --email] <query>
```

Search is the default command -- no subcommand needed. The search type is auto-detected:

| Input looks like          | Detected as |
|---------------------------|-------------|
| Contains `@` or a domain  | email       |
| Mostly digits (3+)        | number      |
| Anything else              | name        |

Override with a flag: `--name`, `--number`, or `--email`.

```bash
contacts "John Doe"
contacts "555-1234"
contacts --email "example.com"
```

### Add

```bash
contacts add --first <name> [--last <name>] [--company <name>] [--phone <num>] [--email <addr>]
```

```bash
contacts add --first John --last Doe --phone "555-1234" --email john@example.com
contacts add --first Jane --company "Acme Corp"
```

### Edit

```bash
contacts edit <query> [options]
```

Finds a contact by name, then applies changes. If multiple contacts match, lists them so you can be more specific.

| Option | Description |
|---|---|
| `--first <name>` | Set first name |
| `--last <name>` | Set last name |
| `--company <name>` | Set organization |
| `--add-phone <num>` | Add a phone number |
| `--add-email <addr>` | Add an email address |
| `--rm-phone <num>` | Remove a phone number |
| `--rm-email <addr>` | Remove an email address |

```bash
contacts edit "John Doe" --company "New Corp"
contacts edit "Jane" --add-phone "555-9999" --rm-email old@example.com
```

### Delete

```bash
contacts delete <query> [--yes]
```

Finds a contact by name and deletes it. Asks for confirmation unless `--yes` is passed.

```bash
contacts delete "John Doe"
contacts delete "John Doe" --yes
```

## Output

All commands return JSON:

```json
// search
[
  {
    "firstName": "John",
    "lastName": "Doe",
    "fullName": "John Doe",
    "organization": "Acme Corp",
    "phones": [{ "label": "Mobile", "value": "(555) 123-4567" }],
    "emails": [{ "label": "Work", "value": "john@acme.com" }],
    "addresses": [{ "street": "123 Main St", "city": "New York", "state": "NY", "zip": "10001", "country": "US" }]
  }
]

// add
{ "created": true, "fullName": "John Doe", ... }

// edit
{ "updated": true, "fullName": "John Doe", ... }

// delete
{ "deleted": true, "fullName": "John Doe" }
```
