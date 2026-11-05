# gcmai - Git Commit Message AI using local Ollama (gemma4:e4b)
gcmai() {
  # 1. Check if there are staged changes
  if ! git diff --cached --quiet 2>/dev/null; then
    :
  else
    echo "No staged changes found. Stage files with 'git add' first."
    return 1
  fi

  echo "Generating commit message with local gemma4:e4b..."
  local diff_content
  diff_content=$(git diff --cached | head -n 5000)

  local prompt="You are an expert software engineer. Analyze the following git diff and write a concise Conventional Commit message (e.g., feat(auth): add session expiry check).
RULES:
1. Output ONLY the raw commit message subject line (and optional short body if needed). Do NOT output markdown code blocks (no \`\`\` tags), no prefixes like 'Here is the commit message:', and no explanation.
2. Use Canadian English spelling (colour, behaviour, organisation).
3. NEVER use em dashes. Use colons, commas, or regular hyphens instead.
4. Do NOT include any AI attribution or trailers like Co-authored-by.

Git diff:
$diff_content"

  local msg
  msg=$(ollama run gemma4:e4b "$prompt" 2>/dev/null)

  # 2. Guardrail enforcement: strip <think> blocks, markdown code fences, em dashes, and attribution trailers
  msg=$(echo "$msg" | perl -0777 -pe 's/<think>.*?<\/think>//gs' | sed '/^```/d' | sed 's/—/-/g' | grep -v -i -E 'Co-authored-by:|Generated-by:' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  if [[ -z "$msg" ]]; then
    echo "Error: Failed to generate message from local Ollama."
    return 1
  fi

  # 3. Open git commit editor pre-populated for your final review
  git commit -e -m "$msg"
}
