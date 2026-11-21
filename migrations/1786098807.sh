echo "Relink agent skill symlinks to default/agents/skills/codeswot"

mkdir -p ~/.agents/skills ~/.claude/skills ~/.codex/skills ~/.pi/agent/skills
ln -sfn "$CODESWOT_PATH/default/agents/skills/codeswot" ~/.agents/skills/codeswot
ln -sfn "$CODESWOT_PATH/default/agents/skills/codeswot" ~/.claude/skills/codeswot
ln -sfn "$CODESWOT_PATH/default/agents/skills/codeswot" ~/.codex/skills/codeswot
ln -sfn "$CODESWOT_PATH/default/agents/skills/codeswot" ~/.pi/agent/skills/codeswot
