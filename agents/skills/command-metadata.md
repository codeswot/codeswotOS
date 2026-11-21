# Command Metadata

Read this before adding or changing commands in `bin/`.

Commands in `bin/` can declare CLI metadata in comments near the top of the
file. `bin/codeswot` scans the first 80 lines, and tests expect command metadata
to remain valid.

Supported metadata keys:

- `# codeswot:group=...` - override the command group inferred from the filename
- `# codeswot:name=...` - override the command name inferred from the filename
- `# codeswot:summary=...` - short help text
- `# codeswot:args=...` - usage arguments
- `# codeswot:examples=...` - examples separated with ` | `
- `# codeswot:alias=...` / `# codeswot:aliases=...` - alternate routes
- `# codeswot:hidden=true` - hide from default command listings
- `# codeswot:requires-sudo=true` - mark commands that require sudo

Only use `codeswot:examples` where there are args that need explaining.

Prefer explicit metadata for user-facing commands. Keep routes consistent with
the filename unless there is a deliberate alias or compatibility route.

Example:

```bash
# codeswot:summary=Take a screenshot
# codeswot:args=[smart|region|windows|fullscreen] [slurp|copy]
# codeswot:examples=codeswot screenshot | codeswot capture screenshot region
```
