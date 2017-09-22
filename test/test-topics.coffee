TestCase = require("./test-base")

################################################################################
# Topic Tests
################################################################################

exports.test_punishment_topic = (test) ->
  bot = new TestCase(test, """
    + hello
    - Hi there!

    + swear word
    - How rude! Apologize or I won't talk to you again.{topic=sorry}

    + *
    - Catch-all.

    > topic sorry
        + sorry
        - It's ok!{topic=random}

        + *
        - Say you're sorry!
    < topic
  """)
  await bot.reply("hello", "Hi there!")
  await bot.reply("How are you?", "Catch-all.")
  await bot.reply("Swear word!", "How rude! Apologize or I won't talk to you again.")
  await bot.reply("hello", "Say you're sorry!")
  await bot.reply("How are you?", "Say you're sorry!")
  await bot.reply("Sorry!", "It's ok!")
  await bot.reply("hello", "Hi there!")
  await bot.reply("How are you?", "Catch-all.")
  test.done()

exports.test_topic_inheritance = (test) ->
  RS_ERR_MATCH = "ERR: No Reply Matched"
  bot = new TestCase(test, """
    > topic colors
        + what color is the sky
        - Blue.

        + what color is the sun
        - Yellow.
    < topic

    > topic linux
        + name a red hat distro
        - Fedora.

        + name a debian distro
        - Ubuntu.
    < topic

    > topic stuff includes colors linux
        + say stuff
        - \"Stuff.\"
    < topic

    > topic override inherits colors
        + what color is the sun
        - Purple.
    < topic

    > topic morecolors includes colors
        + what color is grass
        - Green.
    < topic

    > topic evenmore inherits morecolors
        + what color is grass
        - Blue, sometimes.
    < topic
  """)
  bot.rs.setUservar(bot.username, "topic", "colors")
  await bot.reply("What color is the sky?", "Blue.")
  await bot.reply("What color is the sun?", "Yellow.")
  await bot.reply("What color is grass?", RS_ERR_MATCH)
  await bot.reply("Name a Red Hat distro.", RS_ERR_MATCH)
  await bot.reply("Name a Debian distro.", RS_ERR_MATCH)
  await bot.reply("Say stuff.", RS_ERR_MATCH)

  bot.rs.setUservar(bot.username, "topic", "linux")
  await bot.reply("What color is the sky?", RS_ERR_MATCH)
  await bot.reply("What color is the sun?", RS_ERR_MATCH)
  await bot.reply("What color is grass?", RS_ERR_MATCH)
  await bot.reply("Name a Red Hat distro.", "Fedora.")
  await bot.reply("Name a Debian distro.", "Ubuntu.")
  await bot.reply("Say stuff.", RS_ERR_MATCH)

  bot.rs.setUservar(bot.username, "topic", "stuff")
  await bot.reply("What color is the sky?", "Blue.")
  await bot.reply("What color is the sun?", "Yellow.")
  await bot.reply("What color is grass?", RS_ERR_MATCH)
  await bot.reply("Name a Red Hat distro.", "Fedora.")
  await bot.reply("Name a Debian distro.", "Ubuntu.")
  await bot.reply("Say stuff.", '"Stuff."')

  bot.rs.setUservar(bot.username, "topic", "override")
  await bot.reply("What color is the sky?", "Blue.")
  await bot.reply("What color is the sun?", "Purple.")
  await bot.reply("What color is grass?", RS_ERR_MATCH)
  await bot.reply("Name a Red Hat distro.", RS_ERR_MATCH)
  await bot.reply("Name a Debian distro.", RS_ERR_MATCH)
  await bot.reply("Say stuff.", RS_ERR_MATCH)

  bot.rs.setUservar(bot.username, "topic", "morecolors")
  await bot.reply("What color is the sky?", "Blue.")
  await bot.reply("What color is the sun?", "Yellow.")
  await bot.reply("What color is grass?", "Green.")
  await bot.reply("Name a Red Hat distro.", RS_ERR_MATCH)
  await bot.reply("Name a Debian distro.", RS_ERR_MATCH)
  await bot.reply("Say stuff.", RS_ERR_MATCH)

  bot.rs.setUservar(bot.username, "topic", "evenmore")
  await bot.reply("What color is the sky?", "Blue.")
  await bot.reply("What color is the sun?", "Yellow.")
  await bot.reply("What color is grass?", "Blue, sometimes.")
  await bot.reply("Name a Red Hat distro.", RS_ERR_MATCH)
  await bot.reply("Name a Debian distro.", RS_ERR_MATCH)
  await bot.reply("Say stuff.", RS_ERR_MATCH)

  test.done()
