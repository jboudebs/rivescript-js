TestCase = require("./test-base")

################################################################################
# Reply Tests
################################################################################

exports.test_previous = (test) ->
  bot = new TestCase(test, """
    ! sub who's  = who is
    ! sub it's   = it is
    ! sub didn't = did not

    + knock knock
    - Who's there?

    + *
    % who is there
    - <sentence> who?

    + *
    % * who
    - Haha! <sentence>!

    + ask me a question
    - How many arms do I have?

    + [*] # [*]
    % how many arms do i have
    * <star> == 2 => Yes!
    - No!

    + *
    % how many arms do i have
    - That isn't a number.

    + *
    - I don't know.
  """)
  await bot.reply("knock knock", "Who's there?")
  await bot.reply("Canoe", "Canoe who?")
  await bot.reply("Canoe help me with my homework?", "Haha! Canoe help me with my homework!")
  await bot.reply("hello", "I don't know.")
  await bot.reply("Ask me a question", "How many arms do I have?")
  await bot.reply("1", "No!")
  await bot.reply("Ask me a question", "How many arms do I have?")
  await bot.reply("2", "Yes!")
  await bot.reply("Ask me a question", "How many arms do I have?")
  await bot.reply("lol", "That isn't a number.")
  test.done()

exports.test_random = (test) ->
  bot = new TestCase(test, """
    + test random response
    - One.
    - Two.

    + test random tag
    - This sentence has a random {random}word|bit{/random}.
  """)
  await bot.replyRandom("test random response", ["One.", "Two."])
  await bot.replyRandom("test random tag", [
    "This sentence has a random word.",
    "This sentence has a random bit.",
  ])
  test.done()

exports.test_continuations = (test) ->
  bot = new TestCase(test, """
    + tell me a poem
    - There once was a man named Tim,\\s
    ^ who never quite learned how to swim.\\s
    ^ He fell off a dock, and sank like a rock,\\s
    ^ and that was the end of him.
  """)
  await bot.reply("Tell me a poem.", "There once was a man named Tim,
      who never quite learned how to swim.
      He fell off a dock, and sank like a rock,
      and that was the end of him.")
  test.done()

exports.test_redirects = (test) ->
  bot = new TestCase(test, """
    + hello
    - Hi there!

    + hey
    @ hello

    // Test the {@} tag with and without spaces.
    + hi there
    - {@hello}

    + howdy
    - {@ hello}

    + hola
    - {@ hello }
  """)
  await bot.reply("hello", "Hi there!")
  await bot.reply("hey", "Hi there!")
  await bot.reply("hi there", "Hi there!")
  await bot.reply("howdy", "Hi there!")
  await bot.reply("hola", "Hi there!")
  test.done()

exports.test_conditionals = (test) ->
  bot = new TestCase(test, """
    + i am # years old
    - <set age=<star>>OK.

    + what can i do
    * <get age> == undefined => I don't know.
    * <get age> >  25 => Anything you want.
    * <get age> == 25 => Rent a car for cheap.
    * <get age> >= 21 => Drink.
    * <get age> >= 18 => Vote.
    * <get age> <  18 => Not much of anything.

    + am i your master
    * <get master> == true => Yes.
    - No.
  """)
  age_q = "What can I do?"
  await bot.reply(age_q, "I don't know.")

  ages =
      '16' : "Not much of anything."
      '18' : "Vote."
      '20' : "Vote."
      '22' : "Drink."
      '24' : "Drink."
      '25' : "Rent a car for cheap."
      '27' : "Anything you want."
  for age of ages
      if (!ages.hasOwnProperty(age))
          continue
      await bot.reply("I am " + age + " years old.", "OK.")
      await bot.reply(age_q, ages[age])

  await bot.reply("Am I your master?", "No.")
  bot.rs.setUservar(bot.username, "master", "true")
  await bot.reply("Am I your master?", "Yes.")
  test.done()

exports.test_embedded_tags = (test) ->
  bot = new TestCase(test, """
    + my name is *
    * <get name> != undefined => <set oldname=<get name>>I thought\\s
      ^ your name was <get oldname>?
      ^ <set name=<formal>>
    - <set name=<formal>>OK.

    + what is my name
    - Your name is <get name>, right?

    + html test
    - <set name=<b>Name</b>>This has some non-RS <em>tags</em> in it.
  """)
  await bot.reply("What is my name?", "Your name is undefined, right?")
  await bot.reply("My name is Alice.", "OK.")
  await bot.reply("My name is Bob.", "I thought your name was Alice?")
  await bot.reply("What is my name?", "Your name is Bob, right?")
  await bot.reply("HTML Test", "This has some non-RS <em>tags</em> in it.")
  test.done()

exports.test_set_uservars = (test) ->
  bot = new TestCase(test, """
    + what is my name
    - Your name is <get name>.

    + how old am i
    - You are <get age>.
  """)
  bot.rs.setUservars(bot.username, {
      "name": "Aiden",
      "age": 5,
  })
  await bot.reply("What is my name?", "Your name is Aiden.")
  await bot.reply("How old am I?", "You are 5.")
  test.done()

exports.test_questionmark = (test) ->
  bot = new TestCase(test, """
    + google *
    - <a href="https://www.google.com/search?q=<star>">Results are here</a>
  """)
  await bot.reply("google coffeescript",
    '<a href="https://www.google.com/search?q=coffeescript">Results are here</a>'
  )
  test.done()

exports.test_reply_arrays = (test) ->
  bot = new TestCase(test, """
    ! array greek = alpha beta gamma
    ! array test = testing trying
    ! array format = <uppercase>|<lowercase>|<formal>|<sentence>

    + test random array
    - Testing (@greek) array.

    + test two random arrays
    - {formal}(@test){/formal} another (@greek) array.

    + test nonexistant array
    - This (@array) does not exist.

    + test more arrays
    - I'm (@test) more (@greek) (@arrays).

    + test weird syntax
    - This (@ greek) shouldn't work, and neither should this @test.

    + random format *
    - (@format)
  """)
  await bot.replyRandom("test random array", [
    "Testing alpha array.", "Testing beta array.", "Testing gamma array.",
  ])
  await bot.replyRandom("test two random arrays", [
    "Testing another alpha array.", "Testing another beta array.",
    "Testing another gamma array.", "Trying another alpha array.",
    "Trying another beta array.", "Trying another gamma array.",
  ])
  await bot.reply("test nonexistant array", "This (@array) does not exist.")
  await bot.replyRandom("test more arrays", [
    "I'm testing more alpha (@arrays).", "I'm testing more beta (@arrays).",
    "I'm testing more gamma (@arrays).", "I'm trying more alpha (@arrays).",
    "I'm trying more beta (@arrays).", "I'm trying more gamma (@arrays)."
  ])
  await bot.reply("test weird syntax", "This (@ greek) shouldn't work, and neither should this @test.")
  await bot.replyRandom("random format hello world", [
    "HELLO WORLD", "hello world", "Hello World", "Hello world",
  ])
  test.done()
