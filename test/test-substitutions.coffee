TestCase = require("./test-base")

################################################################################
# Substitution Tests
################################################################################

exports.test_substitutions = (test) ->
  bot = new TestCase(test, """
    + whats up
    - nm.

    + what is up
    - Not much.
  """)
  await bot.reply("whats up", "nm.")
  await bot.reply("what's up?", "nm.")
  await bot.reply("what is up?", "Not much.")

  bot.extend("""
    ! sub whats  = what is
    ! sub what's = what is
  """)
  await bot.reply("whats up", "Not much.")
  await bot.reply("what's up?", "Not much.")
  await bot.reply("What is up?", "Not much.")
  test.done()

exports.test_person_substitutions = (test) ->
  bot = new TestCase(test, """
    + say *
    - <person>
  """)
  await bot.reply("say I am cool", "i am cool")
  await bot.reply("say You are dumb", "you are dumb")

  bot.extend("""
      ! person i am    = you are
      ! person you are = I am
  """)
  await bot.reply("say I am cool", "you are cool")
  await bot.reply("say You are dumb", "I am dumb")
  test.done()
