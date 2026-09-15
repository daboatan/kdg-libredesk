import { test } from 'node:test'
import assert from 'node:assert/strict'
import { shouldStartFreshConversation } from './conversationInactivity.js'

const now = Date.parse('2026-09-15T12:00:00Z')
const config = {
  visitors: { allow_start_conversation: true, prevent_multiple_conversations: false },
  users: { allow_start_conversation: true, prevent_multiple_conversations: false }
}
const conversation = (createdAt) => ({ uuid: 'conversation-1', last_message: { created_at: createdAt } })

test('starts a fresh conversation after ten minutes while keeping the session', () => {
  assert.equal(shouldStartFreshConversation(conversation('2026-09-15T11:50:00Z'), config, true, now), true)
  assert.equal(shouldStartFreshConversation(conversation('2026-09-15T11:50:01Z'), config, true, now), false)
})

test('respects inbox restrictions on starting another conversation', () => {
  assert.equal(shouldStartFreshConversation(conversation('2026-09-15T11:00:00Z'), {
    visitors: { allow_start_conversation: true, prevent_multiple_conversations: true }
  }, true, now), false)
  assert.equal(shouldStartFreshConversation(conversation('2026-09-15T11:00:00Z'), {
    visitors: { allow_start_conversation: false, prevent_multiple_conversations: false }
  }, true, now), false)
})

test('does not treat missing activity as inactivity', () => {
  assert.equal(shouldStartFreshConversation(conversation(undefined), config, true, now), false)
  assert.equal(shouldStartFreshConversation(null, config, true, now), false)
})
