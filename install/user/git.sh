# Set identification from install inputs
if [[ -n ${CODESWOT_USER_NAME//[[:space:]]/} ]]; then
  git config --global user.name "$CODESWOT_USER_NAME"
fi

if [[ -n ${CODESWOT_USER_EMAIL//[[:space:]]/} ]]; then
  git config --global user.email "$CODESWOT_USER_EMAIL"
fi
