# Claude Code CLI configuration
{ ... }:
{
  programs.claude-code = {
    enable = true;

    settings = {
      permissions = {
        allow = [
          "Read"
          "Edit"
          "MultiEdit"
          "Write"
          "Glob"
          "Grep"
          "Bash(git diff:*)"
          "Bash(git log:*)"
          "Bash(git status:*)"
          "Bash(git add:*)"
          "Bash(git commit:*)"
          "Bash(rg:*)"
          "Bash(fd:*)"
          "Bash(eza:*)"
          "Bash(jq:*)"
          "Bash(nix fmt:*)"
          "Bash(nix flake:*)"
          "Bash(nix build:*)"
          "Bash(nix eval:*)"
        ];
        deny = [
          "Read(./.env)"
          "Read(./secrets/**)"
        ];
      };
      includeCoAuthoredBy = false;
    };

    # memory — skipped; agent-instructions.nix owns ~/.claude/CLAUDE.md
    # mcpServers = { };   # add MCP servers here as needed
    # commands = { };     # add custom slash commands here as needed
    # skills = { };       # add skills here as needed
  };
}
