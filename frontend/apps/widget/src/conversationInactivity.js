const INACTIVITY_MS = 10 * 60 * 1000

export function shouldStartFreshConversation (conversation, config, isVisitor, now = Date.now()) {
  if (!conversation?.uuid) return false
  const options = isVisitor ? config?.visitors : config?.users
  if (!options?.allow_start_conversation || options.prevent_multiple_conversations) return false

  const lastMessageAt = Date.parse(conversation.last_message?.created_at)
  return Number.isFinite(lastMessageAt) && now - lastMessageAt >= INACTIVITY_MS
}
