## you went the wrong way

print "Who knows what dangers lurk this way"
print "Turn back!"

# JavaScript

"It's not a very good language"

## Intro

print "I've defined a `print` function that will write to this little output box."
print "Press ⌘↵ or ^↵ to run this code."
print "Press ^O to revert to the original code (if you make changes)."

## Objects and arrays

options =
  ports:
    dev: 3001
    prod: 90
  debug: false

print options['ports'].dev

print 3 / 2 # deal with it

print "debug mode is #{ if options.debug then "on" else "off" }"

`undefined = "#yolo"`

## Classes are weird

`
function Class() {

}
Class.prototype.someMethod = function() {
  print("I guess, like, I'm a method?");
}

instance = new Class()
instance.someMethod()
`

## this

someFunction = () ->
  print @foo

someFunction.call {foo: "call with anything you want"}
{foo: "using the dot accessor sets this", someFunction}.someFunction()

x = {foo: "this is legit", someFunction}
x.someFunction()
y = x.someFunction
y()
print "y == someFunction? #{y == someFunction}"

z = y.bind({foo: "bind creates a new function permanently bound to a given this"})
z()
print "z == someFunction? #{z == someFunction}"
x.z = z
x.z()

# CoffeeScript

"Way better than JavaScript"

## Actual classes! Sort of!

class Animal
  speak: ->
    print @word

class Horse extends Animal
  word: "neeeiiighh"

seabiscuit = new Horse()
seabiscuit.speak()

Horse::speak = -> print "whatever man, it's all dynamic in the end"

seabiscuit.speak()

## `constructor` is magic

class WhateverTheHell
  constructor: (something) ->
    console.log something

## Class methods

class Class
  @foo: "class attribute"
  foo: "instance attribute"

instance = new Class()
print Class.foo
print instance.foo

## debugging -- source maps; debugger statement

print "the debugger statement is cool but since this is being evaled it'll break everything"
print "source maps might be a thing now?"

## `super()` vs `super`

class Parent
  foo: (arg) ->
    print "hey you passed me #{ arg }"
  bar: (arg) ->
    print "hey you passed me #{ arg }"
  baz: (arg) ->
    print "hey you passed me #{ arg }"

class Child extends Parent
  foo: (arg) ->
    super
  bar: (arg) ->
    super()
  baz: (arg) ->
    super("another string")

x = new Child()
x.foo("a string")
x.bar("a string")
x.baz("a string")

## `in`/`of`

developers = ["Brett", "Daniel", "Babak", "Hamid", "Aaron", "Ian", "Doug"]
designers = ["Justin", "Bobby", "Tina"]

if "Ian" in developers
  print "Ian is a developer"

if "Aaron" not in designers
  print "Aaron is not a designer"

object = {foo: 1, bar: 2}

if 'foo' of object
  print "foo is a key of the object"

if 'baz' of object
  print "baz is a key of the object"

## `in`/`of` loops; `for own` loops

class SomeClass
  constructor: (@foo, @bar) ->
  method1: -> print "method1 called"
  method2: -> print "method2 called"

someInstance = new SomeClass(1, 2)

for key, value of someInstance
  print "#{ key }: #{ value }"

print "\nwhoa, what was that\n"

for own key, value of someInstance
  print "#{ key }: #{ value }"

print "\noh, got it\n"

if 'method1' of someInstance
  print "I can't decide if I like this"
else
  print "This would also be totally legit"

## `in`/`of` comprehensions

developers = ["Brett", "Daniel", "Babak", "Hamid", "Aaron", "Ian", "Doug"]
horribleMistakeThatYouWillAllMake = dev.toUpperCase() for dev in developers
angryDevs = (dev.toUpperCase() for dev in developers)

print horribleMistakeThatYouWillAllMake
print angryDevs

devMachines =
  "Aaron": "aarond"
  "Ian": "ian"
  "Doug": "justdoug"

machineNames = ("#{ hostname }.hq.fogcreek.com" for dev, hostname of devMachines)
print machineNames

## regular expression literals and `///`

for potentialEmail in ['foo@.com', '@example.com', '@.com', '@.', '', 'foo@example.com']
  if /^[^@]+@[^.]+\.[^.]/.test potentialEmail
    print "'#{ potentialEmail }' looks kinda like an email address"
  else
    print "'#{ potentialEmail }' ain't no email addy"

print()

perfectEmailRegex = ///
   ^     # don't forget your anchors
   [^@]+ # gimme some stuff before the @ sign
   @     # dat at
   [^.]+ # something before the dot
   \.    # oh yeah dot it up
   [^.]  # probably want a TLD up in here
///
if perfectEmailRegex.test('ian@fogcreek.com')
  print "100% of tests pass; ship it"

## `do` keyword for scoping woes

count = 5
msInterval = 50

for i in [0...count]
  setTimeout ->
    print i
  , i * msInterval

setTimeout ->
  print "---"
  for i in [0...5]
    do (i) ->
      setTimeout ->
        print i
      , i * msInterval
, msInterval * count

## Destructuring assignment

request = { url: 'https://example.org/examples', method: 'POST', body: { example: { foo: "bar" } } }
sendRequest = (request) ->
  {url, method, body} = request
  print "about to send a #{method} request to #{url} with body #{JSON.stringify(body)}"
  # exercise for the reader

## Destructuring assignment in parameters

options =
  ports:
    dev: 3001
    prod: 90
  debug: false

printOptionsTheCrappyWay = (options) ->
  print "dev port: #{ options.ports.dev }"
  print "production port: #{ options.ports.prod }"
  print "debug: #{ options.debug }"

printOptionsTheCrappyWay(options)

print "---"

printOptionsTheSexyWay = ({ ports: { dev: devPort, prod: prodPort }, debug }) ->
  print "dev port: #{ devPort }"
  print "production port: #{ prodPort }"
  print "debug: #{ debug}"

printOptionsTheSexyWay(options)

## Destructuring @assignment in parameters

class User
  constructor: ({@name, @age}) ->
  soundOff: ->
    print "#{ @name } reporting for duty"

ian = new User(name: "Ian Henry", age: 32)
ian.soundOff()

## Splats

ArrayToString = Array::toString
Array::toString = -> "[#{@join(', ')}]" # my favorite is Objective-C's `[NSString stringWithFormat:@"@%@", username]`

dummyList = [1, 2, 3, 4, 5, 6, 7]

[car, cdr...] = dummyList
print "#{ car } #{ cdr }"
[head, body..., tail] = dummyList
print "#{ head } #{ body } #{ tail }"

## Splats for n-ary functions

printEverything = (things...) ->
  for thing in things
    print thing

printEverything(1, 2, 3)
Array::toString = ArrayToString

## `?` operator

truthyTest = (foo) ->
  print "!!#{ JSON.stringify(foo) }   = #{ !!foo }"

questionMarkTest = (foo) ->
  print "  #{ JSON.stringify(foo) }?  = #{ foo? }"

for foo in [1, 0, [], null, "foo", "", {}, {}.bar]
  truthyTest(foo)
  questionMarkTest(foo)
  print()

## Object shorthand

startServer = ({port}) ->
  print "Server listening on port #{ port }"

port = 80
startServer { port }

## `->` vs `=>`

print "fuck it, we'll do it live"

## Dangling returns

someFunction = () ->
  limit = 5
  for i in [0...limit]
    print i
  return

someFunction()

## CoffeeScript has bad things

unless not yes
  print "wait what"

until false isnt true
  print "nooooo"

count = 0
loop
  print "because `while true` would be ridiculous"
  count++
  if count > 3
    break

print "yeah, this'll totally print, no big deal, why even wouldn't it" if off

even though 1 != 2, print "hey there"

# async.js

"we use it"

## Asynchronous style

print "there are callbacks"

## waterfall

print "waterfall is cool"

## parallel

print "use parallel too"

## map

print "I mean, it's not like list comprehensions are gonna work here"

## forEach

print "Guys I did not anticipate this taking as long as it did"

## auto

print "You'll see"
