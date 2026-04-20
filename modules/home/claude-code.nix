# Claude Code CLI configuration
#
# Nix manages the package and CLAUDE.md (via agent-instructions.nix).
# ~/.claude/settings.json is left to the CLI and org managed settings.
{ ... }:
{
  programs.claude-code = {
    enable = true;

    # settings intentionally left empty — the CLI owns settings.json so it
    # remains writable for interactive config changes and org policy merges.

    # memory — skipped; agent-instructions.nix owns ~/.claude/CLAUDE.md
    # mcpServers = { };   # add MCP servers here as needed
    # commands = { };     # add custom slash commands here as needed
    # skills = { };       # add skills here as needed
  };
}
